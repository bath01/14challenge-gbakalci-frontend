import 'track.dart';

class Playlist {
  final String id;
  final String name;
  final List<Track> tracks;

  const Playlist({
    required this.id,
    required this.name,
    required this.tracks,
  });

  // Durée totale calculée automatiquement depuis les tracks
  int get totalDuration {
    return tracks.fold(0, (sum, track) => sum + track.duration);
    // fold = réduit une liste à une seule valeur
    // part de 0, additionne duration de chaque track
  }

  // Durée totale formatée en hh:mm:ss ou mm:ss
  String get formattedTotalDuration {
    final total = totalDuration;
    final hours = total ~/ 3600;
    final minutes = (total % 3600) ~/ 60;
    final seconds = total % 60;

    if (hours > 0) {
      return '${hours}h ${minutes.toString().padLeft(2, '0')}min';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // Nombre de morceaux
  int get trackCount => tracks.length;

  // Vérifie si la playlist est vide
  bool get isEmpty => tracks.isEmpty;

  // Convertit un JSON en Playlist
  factory Playlist.fromJson(Map<String, dynamic> json) {
    return Playlist(
      id: json['id'].toString(),
      name: json['name'] ?? 'Playlist sans nom',
      tracks: (json['tracks'] as List<dynamic>? ?? [])
          .map((t) => Track.fromJson(t as Map<String, dynamic>))
          .toList(),
      // on transforme chaque élément JSON en objet Track
    );
  }

  // Convertit une Playlist en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'tracks': tracks.map((t) => t.toJson()).toList(),
    };
  }

  // Ajoute un morceau et retourne une nouvelle Playlist
  Playlist addTrack(Track track) {
    // on vérifie que le morceau n'est pas déjà dans la playlist
    if (tracks.any((t) => t.id == track.id)) return this;
    return copyWith(tracks: [...tracks, track]);
  }

  // Retire un morceau par son id
  Playlist removeTrack(String trackId) {
    return copyWith(
      tracks: tracks.where((t) => t.id != trackId).toList(),
    );
  }

  // Réordonne les morceaux — déplace un morceau d'un index à un autre
  Playlist reorderTrack(int oldIndex, int newIndex) {
    final updatedTracks = List<Track>.from(tracks);
    final track = updatedTracks.removeAt(oldIndex);
    // si on déplace vers le bas, on ajuste l'index
    final adjustedIndex = newIndex > oldIndex ? newIndex - 1 : newIndex;
    updatedTracks.insert(adjustedIndex, track);
    return copyWith(tracks: updatedTracks);
  }

  // Copie avec modification
  Playlist copyWith({
    String? id,
    String? name,
    List<Track>? tracks,
  }) {
    return Playlist(
      id: id ?? this.id,
      name: name ?? this.name,
      tracks: tracks ?? this.tracks,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Playlist && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Playlist(id: $id, name: $name, tracks: ${tracks.length})';
}