import 'package:flutter/foundation.dart';
import '../models/track.dart';
import '../services/download_service.dart';

class DownloadState {
  final String trackId;
  final double progress;
  final bool isDownloading;
  final bool isDownloaded;
  final String? error;

  const DownloadState({
    required this.trackId,
    this.progress = 0.0,
    this.isDownloading = false,
    this.isDownloaded = false,
    this.error,
  });
}

class DownloadProvider extends ChangeNotifier {
  final DownloadService _downloadService;

  final Map<String, DownloadState> _states = {};
  List<Track> _downloadedTracks = [];
  double _totalSize = 0.0;
  bool _isLoading = false;

  List<Track> get downloadedTracks => _downloadedTracks;
  double get totalSize => _totalSize;
  bool get isLoading => _isLoading;
  int get downloadCount => _downloadedTracks.length;

  DownloadProvider({required DownloadService downloadService})
      : _downloadService = downloadService {
    loadDownloadedTracks();
  }

  DownloadState getState(String trackId) {
    return _states[trackId] ?? DownloadState(trackId: trackId);
  }

  bool isDownloading(String trackId) =>
      _states[trackId]?.isDownloading ?? false;

  bool isDownloaded(String trackId) =>
      _states[trackId]?.isDownloaded ??
          _downloadedTracks.any((t) => t.id == trackId);

  double getProgress(String trackId) =>
      _states[trackId]?.progress ?? 0.0;

  // ——— CHARGEMENT ———

  Future<void> loadDownloadedTracks() async {
    _isLoading = true;
    notifyListeners();

    try {
      _downloadedTracks = await _downloadService.getAllDownloadedTracks();
      _totalSize = await _downloadService.getTotalDownloadSize();

      for (final track in _downloadedTracks) {
        _states[track.id] = DownloadState(
          trackId: track.id,
          isDownloaded: true,
          progress: 1.0,
        );
      }

      debugPrint('[DownloadProvider] ${_downloadedTracks.length} tracks chargés');
    } catch (e) {
      debugPrint('[DownloadProvider] Erreur chargement: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ——— RÉCUPÉRATION BDD ———

  // ← Méthode ajoutée — utilisée par PlayerProvider
  Future<Track?> getDownloadedTrack(String trackId) async {
    debugPrint('[DownloadProvider.getDownloadedTrack] Recherche id: $trackId');
    final track = await _downloadService.getDownloadedTrack(trackId);
    debugPrint('[DownloadProvider.getDownloadedTrack] Résultat: ${track?.audioUrl}');
    return track;
  }

  // ——— TÉLÉCHARGEMENT ———

  Future<Track?> downloadTrack(Track track) async {
    if (isDownloading(track.id)) {
      debugPrint('[DownloadProvider] Déjà en cours: ${track.title}');
      return null;
    }

    debugPrint('[DownloadProvider] Début téléchargement: ${track.title}');

    _states[track.id] = DownloadState(
      trackId: track.id,
      isDownloading: true,
      progress: 0.0,
    );
    notifyListeners();

    try {
      final downloadedTrack = await _downloadService.downloadTrack(
        track,
        onProgress: (progress) {
          _states[track.id] = DownloadState(
            trackId: track.id,
            isDownloading: true,
            progress: progress,
          );
          notifyListeners();
        },
      );

      _states[track.id] = DownloadState(
        trackId: track.id,
        isDownloaded: true,
        progress: 1.0,
      );

      _downloadedTracks = [downloadedTrack, ..._downloadedTracks];
      _totalSize = await _downloadService.getTotalDownloadSize();

      debugPrint('[DownloadProvider] ✅ Téléchargé: ${track.title}');
      notifyListeners();
      return downloadedTrack;

    } catch (e) {
      debugPrint('[DownloadProvider] ❌ Erreur: $e');
      _states[track.id] = DownloadState(
        trackId: track.id,
        error: e.toString(),
      );
      notifyListeners();
      return null;
    }
  }

  // ——— SUPPRESSION ———

  Future<void> deleteDownload(String trackId) async {
    debugPrint('[DownloadProvider] Suppression: $trackId');
    try {
      await _downloadService.deleteDownloadedTrack(trackId);
      _downloadedTracks.removeWhere((t) => t.id == trackId);
      _states.remove(trackId);
      _totalSize = await _downloadService.getTotalDownloadSize();
      debugPrint('[DownloadProvider] ✅ Supprimé');
      notifyListeners();
    } catch (e) {
      debugPrint('[DownloadProvider] ❌ Erreur suppression: $e');
    }
  }

  Future<void> deleteAllDownloads() async {
    debugPrint('[DownloadProvider] Suppression de tout...');
    try {
      await _downloadService.deleteAllDownloads();
      _downloadedTracks = [];
      _states.clear();
      _totalSize = 0;
      debugPrint('[DownloadProvider] ✅ Tout supprimé');
      notifyListeners();
    } catch (e) {
      debugPrint('[DownloadProvider] ❌ Erreur: $e');
    }
  }

  @override
  void dispose() {
    _downloadService.close();
    super.dispose();
  }
}