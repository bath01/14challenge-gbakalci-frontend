import 'package:flutter/cupertino.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import '../models/track.dart';
import '../models/PlayerState.dart' as app_state;

class PlayerService {
  final AudioPlayer _audioPlayer = AudioPlayer();

  Future<void> init() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());

    session.interruptionEventStream.listen((event) {
      if (event.begin) {
        pause();
      } else {
        if (event.type == AudioInterruptionType.pause) {
          play();
        }
      }
    });
  }

  // ——— STREAMS ———

  Stream<PlayerState> get playerStateStream => _audioPlayer.playerStateStream;

  Stream<Duration> get positionStream => _audioPlayer.positionStream;

  Stream<Duration?> get durationStream => _audioPlayer.durationStream;

  Stream<double> get volumeStream => _audioPlayer.volumeStream;

  bool get isPlaying => _audioPlayer.playing;

  Duration get currentPosition => _audioPlayer.position;

  double get currentVolume => _audioPlayer.volume;

  // ——— CONTROLES DE LECTURE ———

  /*Future<void> playTrack(Track track) async {
    try {
      if (track.audioUrl == null || track.audioUrl!.isEmpty) {
        throw Exception('URL audio manquante pour ${track.title}');
      }
      await _audioPlayer.setUrl(track.audioUrl!);
      await _audioPlayer.play();
    } catch (e) {
      throw Exception('Erreur lors de la lecture de ${track.title}: $e');
    }
  }**/
  Future<void> playTrack(Track track) async {
    debugPrint('[PlayerService.playTrack] Track: ${track.title}');
    debugPrint('[PlayerService.playTrack] audioUrl: ${track.audioUrl}');
    debugPrint('[PlayerService.playTrack] isLocal: ${track.isLocal}');

    if (track.audioUrl == null || track.audioUrl!.isEmpty) {
      debugPrint('[PlayerService.playTrack] ❌ audioUrl manquant !');
      throw Exception('URL audio manquante pour ${track.title}');
    }

    try {
      if (track.isLocal) {
        debugPrint('[PlayerService.playTrack] → setFilePath (local)');
        await _audioPlayer.setFilePath(track.audioUrl!);
      } else {
        debugPrint('[PlayerService.playTrack] → setUrl (distant)');
        await _audioPlayer.setUrl(track.audioUrl!);
      }
      await _audioPlayer.play();
      debugPrint('[PlayerService.playTrack] ✅ Lecture lancée');
    } catch (e) {
      debugPrint('[PlayerService.playTrack] ❌ Erreur: $e');
      throw Exception('Erreur lecture ${track.title}: $e');
    }
  }

  Future<void> play() async {
    await _audioPlayer.play();
  }

  Future<void> pause() async {
    await _audioPlayer.pause();
  }

  Future<void> stop() async {
    await _audioPlayer.stop();
    await _audioPlayer.seek(Duration.zero);
  }

  // ——— NAVIGATION ———

  Future<void> seekTo(Duration position) async {
    await _audioPlayer.seek(position);
  }

  Future<void> seekForward(int seconds) async {
    final newPosition = _audioPlayer.position + Duration(seconds: seconds);
    final duration = _audioPlayer.duration ?? Duration.zero;
    final clamped = newPosition > duration ? duration : newPosition;
    await _audioPlayer.seek(clamped);
  }

  Future<void> seekBackward(int seconds) async {
    final newPosition = _audioPlayer.position - Duration(seconds: seconds);
    final clamped = newPosition < Duration.zero ? Duration.zero : newPosition;
    await _audioPlayer.seek(clamped);
  }

  // ——— VOLUME ———

  Future<void> setVolume(double volume) async {
    await _audioPlayer.setVolume(volume.clamp(0.0, 1.0));
  }

  // ——— MODE DE LECTURE ———

  Future<void> setShuffle(bool enabled) async {
    await _audioPlayer.setShuffleModeEnabled(enabled);
  }

  Future<void> setRepeatMode(app_state.RepeatMode mode) async {
    switch (mode) {
      case app_state.RepeatMode.none:
        await _audioPlayer.setLoopMode(LoopMode.off);
        break;
      case app_state.RepeatMode.one:
        await _audioPlayer.setLoopMode(LoopMode.one);
        break;
      case app_state.RepeatMode.all:
        await _audioPlayer.setLoopMode(LoopMode.all);
        break;
    }
  }

  // ——— PLAYLIST ———

  Future<void> loadPlaylist(List<Track> tracks, {int initialIndex = 0}) async {
    final playlist = ConcatenatingAudioSource(
      children: tracks
          .where((t) => t.audioUrl != null && t.audioUrl!.isNotEmpty)
          .map((t) => AudioSource.uri(Uri.parse(t.audioUrl!)))
          .toList(),
    );

    await _audioPlayer.setAudioSource(
      playlist,
      initialIndex: initialIndex,
      initialPosition: Duration.zero,
    );
  }

  Future<void> skipToNext() async {
    await _audioPlayer.seekToNext();
  }

  Future<void> skipToPrevious() async {
    if (_audioPlayer.position.inSeconds > 3) {
      await _audioPlayer.seek(Duration.zero);
    } else {
      await _audioPlayer.seekToPrevious();
    }
  }

  // ——— NETTOYAGE ———

  Future<void> dispose() async {
    await _audioPlayer.dispose();
  }
}