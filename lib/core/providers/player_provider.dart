import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart' as just_audio;
import '../models/track.dart';
import '../models/playlist.dart';
import '../models/PlayerState.dart';
import '../services/player_service.dart';
import '../services/download_service.dart';
import 'dart:math';
import 'dart:async';

class PlayerProvider extends ChangeNotifier {

  final PlayerService _playerService;
  final DownloadService _downloadService;
  Timer? _vizTimer;
  final Random _random = Random();
  PlayerState _state = PlayerState.initial();

  PlayerState get state => _state;

  PlayerProvider({
    required PlayerService playerService,
    required DownloadService downloadService,
  })  : _playerService = playerService,
        _downloadService = downloadService {
    _init();
  }

  // ——— INITIALISATION ———

  Future<void> _init() async {
    await _playerService.init();
    _listenToStreams();
  }

  void _listenToStreams() {

    _playerService.playerStateStream.listen((audioState) {
      final isPlaying = audioState.playing;
      final processingState = audioState.processingState;

      PlayingStatus status;

      switch (processingState) {
        case just_audio.ProcessingState.idle:
          status = PlayingStatus.stopped;
          break;
        case just_audio.ProcessingState.loading:
        case just_audio.ProcessingState.buffering:
          status = PlayingStatus.loading;
          break;
        case just_audio.ProcessingState.ready:
          status = isPlaying ? PlayingStatus.playing : PlayingStatus.paused;
          break;
        case just_audio.ProcessingState.completed:
          status = PlayingStatus.stopped;
          _onTrackCompleted();
          break;
      }

      _updateState(_state.copyWith(status: status));

      // ——— Démarre ou arrête le visualiseur ———
      if (isPlaying) {
        _startVisualizer();
      } else {
        _stopVisualizer();
      }
    });

    _playerService.positionStream.listen((position) {
      _updateState(_state.copyWith(currentTime: position));
    });

    _playerService.volumeStream.listen((volume) {
      _updateState(_state.copyWith(volume: volume));
    });
  }

  // ——— VISUALISEUR ———

  void _startVisualizer() {
    _vizTimer?.cancel();
    _vizTimer = Timer.periodic(
      const Duration(milliseconds: 150),
          (_) => _updateFrequencyData(),
    );
  }

  void _stopVisualizer() {
    _vizTimer?.cancel();
    _updateState(_state.copyWith(
      frequencyData: List.filled(20, 0.05),
    ));
  }

  void _updateFrequencyData() {
    if (!_state.isPlaying) return;

    final time = DateTime.now().millisecondsSinceEpoch / 1000.0;

    final frequencies = List.generate(20, (i) {
      // Courbe de base — plus haute au milieu (forme de cloche)
      final base = sin(i * pi / 20) * 0.6;
      // Variation temporelle — ondulation progressive
      final wave = sin(time * 3 + i * 0.5) * 0.2;
      // Bruit aléatoire — donne l'aspect "vivant"
      final noise = _random.nextDouble() * 0.3;
      // Combine et limite entre 0.05 et 1.0
      return (base + wave + noise).clamp(0.05, 1.0);
    });

    _updateState(_state.copyWith(frequencyData: frequencies));
  }

  // ——— CONTROLES DE LECTURE ———

  Future<void> playTrack(Track track) async {
    try {
      debugPrint('[PlayerProvider.playTrack] Track: ${track.title}');
      debugPrint('[PlayerProvider.playTrack] audioUrl: ${track.audioUrl}');
      debugPrint('[PlayerProvider.playTrack] isLocal: ${track.isLocal}');

      _updateState(_state.copyWith(
        currentTrack: track,
        status: PlayingStatus.loading,
        currentTime: Duration.zero,
      ));

      Track trackToPlay = track;

      if (track.audioUrl == null || track.audioUrl!.isEmpty) {
        debugPrint('[PlayerProvider.playTrack] audioUrl manquant → vérification BDD...');

        final cached = await _downloadService.getDownloadedTrack(track.id);

        if (cached != null) {
          debugPrint('[PlayerProvider.playTrack] ✅ Trouvé en BDD: ${cached.audioUrl}');
          trackToPlay = cached;
        } else {
          debugPrint('[PlayerProvider.playTrack] Pas en BDD → téléchargement...');
          trackToPlay = await _downloadService.downloadTrack(track);
          debugPrint('[PlayerProvider.playTrack] ✅ Téléchargé: ${trackToPlay.audioUrl}');
        }
      }

      _updateState(_state.copyWith(currentTrack: trackToPlay));

      debugPrint('[PlayerProvider.playTrack] Lecture: ${trackToPlay.audioUrl}');
      await _playerService.playTrack(trackToPlay);

    } catch (e) {
      debugPrint('[PlayerProvider.playTrack] ❌ Erreur: $e');
      _updateState(_state.copyWith(status: PlayingStatus.error));
    }
  }

  Future<void> playPlaylist(Playlist playlist, {int startIndex = 0}) async {
    try {
      debugPrint('[PlayerProvider.playPlaylist] Playlist: ${playlist.name} — index: $startIndex');

      final track = playlist.tracks[startIndex];

      _updateState(_state.copyWith(
        currentPlaylist: playlist,
        currentIndex: startIndex,
        currentTrack: track,
        status: PlayingStatus.loading,
        currentTime: Duration.zero,
      ));

      final List<Track> tracksToPlay = [];

      for (final t in playlist.tracks) {
        if (t.audioUrl == null || t.audioUrl!.isEmpty) {
          final cached = await _downloadService.getDownloadedTrack(t.id);
          if (cached != null) {
            tracksToPlay.add(cached);
          } else {
            debugPrint('[PlayerProvider.playPlaylist] Téléchargement: ${t.title}');
            final downloaded = await _downloadService.downloadTrack(t);
            tracksToPlay.add(downloaded);
          }
        } else {
          tracksToPlay.add(t);
        }
      }

      debugPrint('[PlayerProvider.playPlaylist] ✅ ${tracksToPlay.length} morceaux prêts');

      await _playerService.loadPlaylist(
        tracksToPlay,
        initialIndex: startIndex,
      );

      await _playerService.play();

    } catch (e) {
      debugPrint('[PlayerProvider.playPlaylist] ❌ Erreur: $e');
      _updateState(_state.copyWith(status: PlayingStatus.error));
    }
  }

  Future<void> togglePlayPause() async {
    if (_state.isPlaying) {
      await _playerService.pause();
    } else {
      await _playerService.play();
    }
  }

  Future<void> stop() async {
    await _playerService.stop();
    _stopVisualizer();
    _updateState(_state.copyWith(
      status: PlayingStatus.stopped,
      currentTime: Duration.zero,
    ));
  }

  // ——— NAVIGATION ———

  Future<void> seekTo(Duration position) async {
    await _playerService.seekTo(position);
    _updateState(_state.copyWith(currentTime: position));
  }

  Future<void> seekToProgress(double progress) async {
    final totalSeconds = _state.currentTrack?.duration ?? 0;
    final targetSeconds = (totalSeconds * progress).round();
    await seekTo(Duration(seconds: targetSeconds));
  }

  Future<void> skipToNext() async {
    if (_state.currentPlaylist == null) return;

    final nextTrack = _state.nextTrack;
    if (nextTrack == null) {
      await stop();
      return;
    }

    final nextIndex = _state.repeatMode == RepeatMode.all &&
        _state.currentIndex >= _state.currentPlaylist!.trackCount - 1
        ? 0
        : _state.currentIndex + 1;

    _updateState(_state.copyWith(
      currentTrack: nextTrack,
      currentIndex: nextIndex,
      currentTime: Duration.zero,
    ));

    await _playerService.skipToNext();
  }

  Future<void> skipToPrevious() async {
    if (_state.currentPlaylist == null) return;

    final prevTrack = _state.previousTrack;
    if (prevTrack == null) {
      await seekTo(Duration.zero);
      return;
    }

    final prevIndex = _state.currentIndex > 0
        ? _state.currentIndex - 1
        : _state.currentPlaylist!.trackCount - 1;

    _updateState(_state.copyWith(
      currentTrack: prevTrack,
      currentIndex: prevIndex,
      currentTime: Duration.zero,
    ));

    await _playerService.skipToPrevious();
  }

  // ——— VOLUME ———

  Future<void> setVolume(double volume) async {
    await _playerService.setVolume(volume);
    _updateState(_state.copyWith(volume: volume));
  }

  Future<void> increaseVolume() async {
    final newVolume = (_state.volume + 0.1).clamp(0.0, 1.0);
    await setVolume(newVolume);
  }

  Future<void> decreaseVolume() async {
    final newVolume = (_state.volume - 0.1).clamp(0.0, 1.0);
    await setVolume(newVolume);
  }

  // ——— MODE DE LECTURE ———

  Future<void> toggleShuffle() async {
    final newShuffle = !_state.shuffle;
    await _playerService.setShuffle(newShuffle);
    _updateState(_state.copyWith(shuffle: newShuffle));
  }

  Future<void> cycleRepeatMode() async {
    final RepeatMode newMode;

    switch (_state.repeatMode) {
      case RepeatMode.none:
        newMode = RepeatMode.one;
        break;
      case RepeatMode.one:
        newMode = RepeatMode.all;
        break;
      case RepeatMode.all:
        newMode = RepeatMode.none;
        break;
    }

    await _playerService.setRepeatMode(newMode);
    _updateState(_state.copyWith(repeatMode: newMode));
  }

  // ——— GESTION FIN DE MORCEAU ———

  void _onTrackCompleted() {
    switch (_state.repeatMode) {
      case RepeatMode.one:
        seekTo(Duration.zero);
        _playerService.play();
        break;
      case RepeatMode.all:
      case RepeatMode.none:
        skipToNext();
        break;
    }
  }

  // ——— MÉTHODE PRIVÉE ———

  void _updateState(PlayerState newState) {
    _state = newState;
    notifyListeners();
  }

  // ——— NETTOYAGE ———

  @override
  Future<void> dispose() async {
    _vizTimer?.cancel();
    await _playerService.dispose();
    super.dispose();
  }
}