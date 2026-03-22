import 'package:flutter/foundation.dart';
import '../models/playlist.dart';
import '../models/track.dart';
import '../services/playlist_service.dart';
import '../services/api_service.dart';
import '../models/category.dart';

// Enum pour l'état de chargement
enum LoadingStatus { idle, loading, success, error }

class PlaylistProvider extends ChangeNotifier {

  final PlaylistService _playlistService;
  final ApiService _apiService;
  List<MusicCategory> _categories = [];
  LoadingStatus _categoriesStatus = LoadingStatus.idle;
  // ——— ÉTAT INTERNE ———

  List<Playlist> _playlists = [];
  List<Track> _allTracks = [];
  LoadingStatus _playlistsStatus = LoadingStatus.idle;
  LoadingStatus _tracksStatus = LoadingStatus.idle;
  String? _errorMessage;
  String? _selectedPlaylistId;

  // ——— GETTERS PUBLICS ———

  List<Playlist> get playlists => _playlists;
  List<Track> get allTracks => _allTracks;
  LoadingStatus get playlistsStatus => _playlistsStatus;
  LoadingStatus get tracksStatus => _tracksStatus;
  String? get errorMessage => _errorMessage;
  List<MusicCategory> get categories => _categories;
  bool get isLoadingCategories => _categoriesStatus == LoadingStatus.loading;
  // Playlist actuellement sélectionnée
  Playlist? get selectedPlaylist {
    if (_selectedPlaylistId == null) return null;
    try {
      return _playlists.firstWhere((p) => p.id == _selectedPlaylistId);
    } catch (_) {
      return null;
    }
  }

  // Vrai si les playlists sont en chargement
  bool get isLoadingPlaylists => _playlistsStatus == LoadingStatus.loading;

  // Vrai si les morceaux sont en chargement
  bool get isLoadingTracks => _tracksStatus == LoadingStatus.loading;

  // Nombre total de playlists
  int get playlistCount => _playlists.length;

  // Nombre total de morceaux dans la bibliothèque
  int get trackCount => _allTracks.length;

  PlaylistProvider({
    required PlaylistService playlistService,
    required ApiService apiService,
  })  : _playlistService = playlistService,
        _apiService = apiService {
    // Charge les données au démarrage
    //loadAll();
  }

  Future<void> loadCategories() async {
    _categoriesStatus = LoadingStatus.loading;
    notifyListeners();

    try {
      _categories = await _apiService.getCategories();
      debugPrint('[PlaylistProvider] ${_categories.length} catégories chargées');
      _categoriesStatus = LoadingStatus.success;
    } catch (e) {
      debugPrint('[PlaylistProvider] Erreur catégories: $e');
      _categoriesStatus = LoadingStatus.error;
    }

    notifyListeners();
  }

  // ================================================
  // CHARGEMENT
  // ================================================

  // Charge playlists et morceaux en parallèle
  Future<void> loadAll() async {
    await Future.wait([
      loadPlaylists(),
      loadTracks(),
      loadCategories(),
    ]);
    // Future.wait = exécute les deux futures en parallèle
    // plus rapide qu'attendre l'un après l'autre
  }

  // Charge toutes les playlists
  Future<void> loadPlaylists({bool forceRefresh = false}) async {
    _setPlaylistsStatus(LoadingStatus.loading);
    _clearError();

    try {
      final playlists = await _playlistService.getPlaylists(
        forceRefresh: forceRefresh,
      );
      _playlists = playlists;
      _setPlaylistsStatus(LoadingStatus.success);
    } catch (e) {
      _setError('Erreur chargement playlists : $e');
      _setPlaylistsStatus(LoadingStatus.error);
    }
  }

  // Charge tous les morceaux depuis l'API
  Future<void> loadTracks() async {
    _setTracksStatus(LoadingStatus.loading);

    try {
      final tracks = await _apiService.getTracks();
      _allTracks = tracks;
      _setTracksStatus(LoadingStatus.success);
    } catch (e) {
      _setError('Erreur chargement morceaux : $e');
      _setTracksStatus(LoadingStatus.error);
    }
  }

  // ================================================
  // SÉLECTION
  // ================================================

  // Sélectionne une playlist pour l'afficher en détail
  void selectPlaylist(String playlistId) {
    _selectedPlaylistId = playlistId;
    notifyListeners();
  }

  // Désélectionne la playlist
  void clearSelection() {
    _selectedPlaylistId = null;
    notifyListeners();
  }

  // ================================================
  // CRÉATION
  // ================================================

  Future<Playlist?> createPlaylist({
    required String name,
    List<Track> tracks = const [],
  }) async {
    try {
      final newPlaylist = await _playlistService.createPlaylist(
        name: name,
        tracks: tracks,
      );

      // Ajoute au début de la liste locale
      _playlists = [newPlaylist, ..._playlists];
      notifyListeners();

      return newPlaylist;
    } catch (e) {
      _setError('Erreur création playlist : $e');
      return null;
    }
  }

  // ================================================
  // GESTION DES MORCEAUX
  // ================================================

  // Ajoute un morceau à une playlist
  Future<bool> addTrackToPlaylist({
    required String playlistId,
    required Track track,
  }) async {
    try {
      final updatedPlaylist = await _playlistService.addTrack(
        playlistId: playlistId,
        track: track,
      );

      _updatePlaylistInList(updatedPlaylist);
      return true; // succès

    } catch (e) {
      _setError('$e'); // le message vient déjà du service
      return false; // échec
    }
  }

  // Retire un morceau d'une playlist
  Future<bool> removeTrackFromPlaylist({
    required String playlistId,
    required String trackId,
  }) async {
    try {
      final updatedPlaylist = await _playlistService.removeTrack(
        playlistId: playlistId,
        trackId: trackId,
      );

      _updatePlaylistInList(updatedPlaylist);
      return true;

    } catch (e) {
      _setError('Erreur suppression morceau : $e');
      return false;
    }
  }

  // ================================================
  // RÉORDONNANCEMENT
  // ================================================

  // Réordonnancement optimiste — UI mise à jour immédiatement
  // puis synchronisation avec l'API en arrière-plan
  Future<void> reorderTrack({
    required String playlistId,
    required int oldIndex,
    required int newIndex,
  }) async {
    // 1. Mise à jour immédiate de l'UI (optimiste)
    final optimisticPlaylist = _playlistService.reorderTrackOptimistic(
      playlistId: playlistId,
      oldIndex: oldIndex,
      newIndex: newIndex,
    );
    _updatePlaylistInList(optimisticPlaylist);

    // 2. Synchronisation avec l'API en arrière-plan
    try {
      final confirmedPlaylist = await _playlistService.reorderTrack(
        playlistId: playlistId,
        oldIndex: oldIndex,
        newIndex: newIndex,
      );
      _updatePlaylistInList(confirmedPlaylist);
    } catch (e) {
      // Si l'API échoue → on recharge pour revenir à l'état serveur
      _setError('Erreur réordonnancement : $e');
      await loadPlaylists(forceRefresh: true);
    }
  }

  // ================================================
  // RECHERCHE ET FILTRAGE
  // ================================================

  // Recherche des morceaux par titre ou artiste
  List<Track> searchTracks(String query) {
    if (query.isEmpty) return _allTracks;
    final lowerQuery = query.toLowerCase();
    return _allTracks.where((track) {
      return track.title.toLowerCase().contains(lowerQuery) ||
          track.artist.toLowerCase().contains(lowerQuery) ||
          track.album.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  // Filtre les morceaux par artiste
  List<Track> getTracksByArtist(String artist) {
    return _allTracks
        .where((t) => t.artist.toLowerCase() == artist.toLowerCase())
        .toList();
  }

  // Retourne tous les artistes uniques
  List<String> get uniqueArtists {
    return _allTracks.map((t) => t.artist).toSet().toList()..sort();
    // .toSet() supprime les doublons
    // ..sort() trie alphabétiquement (cascade notation)
  }

  // Vérifie si un morceau est dans une playlist
  bool isTrackInPlaylist({
    required String playlistId,
    required String trackId,
  }) {
    return _playlistService.isTrackInPlaylist(
      playlistId: playlistId,
      trackId: trackId,
    );
  }

  // Retourne les playlists qui contiennent un morceau
  List<Playlist> getPlaylistsForTrack(String trackId) {
    return _playlistService.getPlaylistsContainingTrack(trackId);
  }

  // ================================================
  // MÉTHODES PRIVÉES
  // ================================================

  // Met à jour une playlist dans la liste locale
  void _updatePlaylistInList(Playlist updatedPlaylist) {
    _playlists = _playlists.map((p) {
      return p.id == updatedPlaylist.id ? updatedPlaylist : p;
    }).toList();
    notifyListeners();
  }

  void _setPlaylistsStatus(LoadingStatus status) {
    _playlistsStatus = status;
    notifyListeners();
  }

  void _setTracksStatus(LoadingStatus status) {
    _tracksStatus = status;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    debugPrint('[PlaylistProvider] Erreur: $message');
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  // ================================================
  // NETTOYAGE
  // ================================================

  @override
  void dispose() {
    _playlistService.clearCache();
    super.dispose();
  }
}