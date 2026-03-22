class Track {
  final String id;
  final String title;
  final String artist;
  final String album;
  final String coverUrl;
  final int duration;
  final String? audioUrl;
  final String? genre;
  final bool isLocal;   // ← nouveau
  final int? localId;   // ← nouveau — id on_audio_query pour l'artwork

  const Track({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.coverUrl,
    required this.duration,
    this.audioUrl,
    this.genre,
    this.isLocal = false,  // ← false par défaut
    this.localId,
  });

  factory Track.fromJson(Map<String, dynamic> json) {
    return Track(
      id: json['id'].toString(),
      title: json['title'] ?? 'Titre inconnu',
      artist: json['artist'] ?? 'Artiste inconnu',
      album: json['album'] ?? 'Album inconnu',
      coverUrl: json['coverUrl'] ?? '',
      duration: json['duration'] ?? 0,
      audioUrl:  json['audioUrl'],
      genre: json['categoryName'] ?? json['genre'],
      isLocal: false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'album': album,
      'coverUrl': coverUrl,
      'duration': duration,
      'audioUrl': audioUrl,
      'genre': genre,
    };
  }

  String get formattedDuration {
    final minutes = duration ~/ 60;
    final seconds = duration % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Track copyWith({
    String? id,
    String? title,
    String? artist,
    String? album,
    String? coverUrl,
    int? duration,
    String? audioUrl,
    String? genre,
    bool? isLocal,
    int? localId,
  }) {
    return Track(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      coverUrl: coverUrl ?? this.coverUrl,
      duration: duration ?? this.duration,
      audioUrl: audioUrl ?? this.audioUrl,
      genre: genre ?? this.genre,
      isLocal: isLocal ?? this.isLocal,
      localId: localId ?? this.localId,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Track && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'Track(id: $id, title: $title, artist: $artist, isLocal: $isLocal)';
}