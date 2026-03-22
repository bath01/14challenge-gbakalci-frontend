import 'track.dart';
import 'playlist.dart';

// Enum pour le mode repeat
// none = pas de répétition
// one = répète le morceau actuel
// all = répète toute la playlist
enum RepeatMode { none, one, all }

// Enum pour l'état de lecture
enum PlayingStatus { stopped, playing, paused, loading, error }

class PlayerState {
  final Track? currentTrack;        // morceau en cours (null si rien)
  final PlayingStatus status;       // état actuel du lecteur
  final Duration currentTime;       // position actuelle
  final double volume;              // volume entre 0.0 et 1.0
  final bool shuffle;               // mode aléatoire
  final RepeatMode repeatMode;      // mode répétition
  final Playlist? currentPlaylist;  // playlist en cours
  final int currentIndex;           // index du morceau dans la playlist
  final List<double> frequencyData; // données pour visualisation audio

  const PlayerState({
    this.currentTrack,
    this.status = PlayingStatus.stopped,
    this.currentTime = Duration.zero,
    this.volume = 1.0,
    this.shuffle = false,
    this.repeatMode = RepeatMode.none,
    this.currentPlaylist,
    this.currentIndex = 0,
    this.frequencyData = const [],
  });

  // État initial — lecteur vide au démarrage
  factory PlayerState.initial() {
    return const PlayerState(
      status: PlayingStatus.stopped,
      currentTime: Duration.zero,
      volume: 1.0,
      shuffle: false,
      repeatMode: RepeatMode.none,
      currentIndex: 0,
    );
  }

  // ——— GETTERS utilitaires ———

  // Vrai si en lecture
  bool get isPlaying => status == PlayingStatus.playing;

  // Vrai si en pause
  bool get isPaused => status == PlayingStatus.paused;

  // Vrai si en chargement
  bool get isLoading => status == PlayingStatus.loading;

  // Vrai si arrêté
  bool get isStopped => status == PlayingStatus.stopped;

  // Durée totale du morceau actuel
  Duration get totalDuration {
    if (currentTrack == null) return Duration.zero;
    return Duration(seconds: currentTrack!.duration);
    // ! signifie "je garantis que ce n'est pas null"
  }

  // Progression entre 0.0 et 1.0 pour la barre de progression
  double get progress {
    if (totalDuration.inSeconds == 0) return 0.0;
    return currentTime.inSeconds / totalDuration.inSeconds;
    // clamp s'assure que la valeur reste entre 0.0 et 1.0
  }

  // Temps restant
  Duration get remainingTime => totalDuration - currentTime;

  // Prochain morceau dans la playlist
  Track? get nextTrack {
    if (currentPlaylist == null || currentPlaylist!.isEmpty) return null;
    if (shuffle) {
      // mode aléatoire — on retourne un index random
      final randomIndex = DateTime.now().millisecondsSinceEpoch %
          currentPlaylist!.trackCount;
      return currentPlaylist!.tracks[randomIndex];
    }
    final nextIndex = currentIndex + 1;
    if (nextIndex >= currentPlaylist!.trackCount) {
      // fin de playlist
      return repeatMode == RepeatMode.all
          ? currentPlaylist!.tracks.first  // retour au début
          : null;                           // arrêt
    }
    return currentPlaylist!.tracks[nextIndex];
  }

  // Morceau précédent
  Track? get previousTrack {
    if (currentPlaylist == null || currentPlaylist!.isEmpty) return null;
    final prevIndex = currentIndex - 1;
    if (prevIndex < 0) {
      return repeatMode == RepeatMode.all
          ? currentPlaylist!.tracks.last
          : null;
    }
    return currentPlaylist!.tracks[prevIndex];
  }

  // Libellé du mode repeat pour l'affichage
  String get repeatModeLabel {
    switch (repeatMode) {
      case RepeatMode.none: return 'Pas de répétition';
      case RepeatMode.one:  return 'Répéter ce morceau';
      case RepeatMode.all:  return 'Répéter la playlist';
    }
  }

  // Copie avec modification
  PlayerState copyWith({
    Track? currentTrack,
    PlayingStatus? status,
    Duration? currentTime,
    double? volume,
    bool? shuffle,
    RepeatMode? repeatMode,
    Playlist? currentPlaylist,
    int? currentIndex,
    List<double>? frequencyData,
    bool clearCurrentTrack = false, // flag spécial pour mettre currentTrack à null
  }) {
    return PlayerState(
      currentTrack: clearCurrentTrack ? null : (currentTrack ?? this.currentTrack),
      status: status ?? this.status,
      currentTime: currentTime ?? this.currentTime,
      volume: volume ?? this.volume,
      shuffle: shuffle ?? this.shuffle,
      repeatMode: repeatMode ?? this.repeatMode,
      currentPlaylist: currentPlaylist ?? this.currentPlaylist,
      currentIndex: currentIndex ?? this.currentIndex,
      frequencyData: frequencyData ?? this.frequencyData,
    );
  }

  @override
  String toString() {
    return 'PlayerState(status: $status, track: ${currentTrack?.title}, '
        'time: $currentTime, volume: $volume, shuffle: $shuffle, repeat: $repeatMode)';
  }
}