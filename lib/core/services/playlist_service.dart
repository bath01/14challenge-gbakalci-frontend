import '../models/playlist.dart';
import '../models/track.dart';
import 'api_service.dart';

class PlaylistService {
  final ApiService _apiService;

  // Le service dépend de ApiService — injection de dépendance
  PlaylistService({required ApiService apiService})
      : _apiService = apiService;

  // Cache local des playlists pour éviter des appels API inutiles
  List<Playlist> _cachedPlaylists = [];

  // ================================================
  // LECTURE
  // ================================================

  // Récupère toutes les playlists depuis l'API
  Future<List<Playlist>> getPlaylists({bool forceRefresh = false}) async {
    // Si on a déjà des données en cache et qu'on ne force pas le refresh
    // on retourne le cache directement sans appel API
    if (_cachedPlaylists.isNotEmpty && !forceRefresh) {
      return _cachedPlaylists;
    }

    final playlists = await _apiService.getPlaylists();
    _cachedPlaylists = playlists; // on met à jour le cache
    return playlists;
  }

  // Récupère une playlist par son id depuis le cache
  Playlist? getPlaylistById(String id) {
    try {
      // firstWhere lève une exception si aucun élément ne correspond
      return _cachedPlaylists.firstWhere((p) => p.id == id);
    } catch (_) {
      return null; // retourne null si introuvable
    }
  }

  // ================================================
  // CRÉATION
  // ================================================

  // Crée une nouvelle playlist
  Future<Playlist> createPlaylist({
    required String name,
    List<Track> tracks = const [],
  }) async {
    // On envoie uniquement les ids des morceaux à l'API
    final trackIds = tracks.map((t) => t.id).toList();

    final newPlaylist = await _apiService.createPlaylist(
      name: name,
      trackIds: trackIds,
    );

    // On ajoute la nouvelle playlist au cache local
    _cachedPlaylists = [..._cachedPlaylists, newPlaylist];

    return newPlaylist;
  }

  // ================================================
  // GESTION DES MORCEAUX
  // ================================================

  // Ajoute un morceau à une playlist
  Future<Playlist> addTrack({
    required String playlistId,
    required Track track,
  }) async {
    // Vérifie si la playlist existe dans le cache
    final playlist = getPlaylistById(playlistId);
    if (playlist == null) {
      throw Exception('Playlist $playlistId introuvable');
    }

    // Vérifie si le morceau est déjà dans la playlist
    if (playlist.tracks.any((t) => t.id == track.id)) {
      throw Exception('${track.title} est déjà dans la playlist');
    }

    final updatedPlaylist = await _apiService.addTrackToPlaylist(
      playlistId: playlistId,
      trackId: track.id,
    );

    // Met à jour le cache
    _updateCache(updatedPlaylist);

    return updatedPlaylist;
  }

  // Retire un morceau d'une playlist
  Future<Playlist> removeTrack({
    required String playlistId,
    required String trackId,
  }) async {
    final playlist = getPlaylistById(playlistId);
    if (playlist == null) {
      throw Exception('Playlist $playlistId introuvable');
    }

    final updatedPlaylist = await _apiService.removeTrackFromPlaylist(
      playlistId: playlistId,
      trackId: trackId,
    );

    _updateCache(updatedPlaylist);

    return updatedPlaylist;
  }

  // ================================================
  // RÉORDONNANCEMENT
  // ================================================

  // Déplace un morceau dans la playlist
  // oldIndex = position actuelle, newIndex = nouvelle position
  Future<Playlist> reorderTrack({
    required String playlistId,
    required int oldIndex,
    required int newIndex,
  }) async {
    final playlist = getPlaylistById(playlistId);
    if (playlist == null) {
      throw Exception('Playlist $playlistId introuvable');
    }

    // On calcule le nouvel ordre localement d'abord
    final reordered = playlist.reorderTrack(oldIndex, newIndex);

    // On envoie le nouvel ordre à l'API
    final updatedPlaylist = await _apiService.reorderPlaylist(
      playlistId: playlistId,
      trackIds: reordered.tracks.map((t) => t.id).toList(),
    );

    _updateCache(updatedPlaylist);

    return updatedPlaylist;
  }

  // Réordonnancement optimiste — met à jour le cache AVANT l'appel API
  // L'UI est mise à jour immédiatement sans attendre la réponse serveur
  Playlist reorderTrackOptimistic({
    required String playlistId,
    required int oldIndex,
    required int newIndex,
  }) {
    final playlist = getPlaylistById(playlistId);
    if (playlist == null) {
      throw Exception('Playlist $playlistId introuvable');
    }

    final reordered = playlist.reorderTrack(oldIndex, newIndex);
    _updateCache(reordered); // mise à jour immédiate du cache
    return reordered;
  }

  // ================================================
  // UTILITAIRES
  // ================================================

  // Vérifie si un morceau est dans une playlist
  bool isTrackInPlaylist({
    required String playlistId,
    required String trackId,
  }) {
    final playlist = getPlaylistById(playlistId);
    if (playlist == null) return false;
    return playlist.tracks.any((t) => t.id == trackId);
  }

  // Retourne toutes les playlists qui contiennent un morceau
  List<Playlist> getPlaylistsContainingTrack(String trackId) {
    return _cachedPlaylists
        .where((p) => p.tracks.any((t) => t.id == trackId))
        .toList();
  }

  // Durée totale de toutes les playlists
  int get totalLibraryDuration {
    return _cachedPlaylists.fold(
      0,
          (sum, playlist) => sum + playlist.totalDuration,
    );
  }

  // Vide le cache — utile pour forcer un rechargement
  void clearCache() {
    _cachedPlaylists = [];
  }

  // ================================================
  // MÉTHODES PRIVÉES
  // ================================================

  // Met à jour une playlist dans le cache
  void _updateCache(Playlist updatedPlaylist) {
    _cachedPlaylists = _cachedPlaylists.map((p) {
      // Si c'est la playlist modifiée → on la remplace
      // Sinon → on garde l'ancienne
      return p.id == updatedPlaylist.id ? updatedPlaylist : p;
    }).toList();
  }
}