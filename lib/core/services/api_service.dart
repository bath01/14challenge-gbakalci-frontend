import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/track.dart';
import '../models/playlist.dart';
import 'mock_data.dart';
import '../models/category.dart';

class ApiService {
  late final Dio _dio;

  static const bool _useMock = false;
  static const String _baseUrl = 'https://gbakalci.chalenge14.com/api';

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          debugPrint('┌─────────────────────────────────────');
          debugPrint('│ [API REQUEST]');
          debugPrint('│ Méthode  : ${options.method}');
          debugPrint('│ URL      : ${options.baseUrl}${options.path}');
          debugPrint('│ Headers  : ${options.headers}');
          if (options.data != null) {
            debugPrint('│ Body     : ${options.data}');
          }
          if (options.queryParameters.isNotEmpty) {
            debugPrint('│ Params   : ${options.queryParameters}');
          }
          debugPrint('└─────────────────────────────────────');
          handler.next(options);
        },
        onResponse: (response, handler) {
          debugPrint('┌─────────────────────────────────────');
          debugPrint('│ [API RESPONSE] ✅');
          debugPrint('│ URL      : ${response.requestOptions.path}');
          debugPrint('│ Status   : ${response.statusCode}');
          debugPrint('│ Type     : ${response.data.runtimeType}');
          // Affiche les données — tronque si trop long
          final dataStr = response.data.toString();
          if (dataStr.length > 500) {
            debugPrint('│ Data     : ${dataStr.substring(0, 500)}...[tronqué]');
          } else {
            debugPrint('│ Data     : $dataStr');
          }
          debugPrint('└─────────────────────────────────────');
          handler.next(response);
        },
        onError: (error, handler) {
          debugPrint('┌─────────────────────────────────────');
          debugPrint('│ [API ERROR] ❌');
          debugPrint('│ URL      : ${error.requestOptions.baseUrl}${error.requestOptions.path}');
          debugPrint('│ Type     : ${error.type}');
          debugPrint('│ Status   : ${error.response?.statusCode}');
          debugPrint('│ Message  : ${error.message}');
          debugPrint('│ Response : ${error.response?.data}');
          debugPrint('└─────────────────────────────────────');
          handler.next(error);
        },
      ),
    );

    debugPrint('[ApiService] Initialisé — baseUrl: $_baseUrl');
    debugPrint('[ApiService] Mode mock: $_useMock');
  }

  // ——— TRACKS ———

  Future<List<Track>> getTracks() async {
    debugPrint('[ApiService.getTracks] Début — useMock: $_useMock');

    if (_useMock) {
      debugPrint('[ApiService.getTracks] Mode mock → retourne ${MockData.tracks.length} morceaux');
      await Future.delayed(const Duration(milliseconds: 500));
      return MockData.tracks;
    }

    try {
      debugPrint('[ApiService.getTracks] Appel API GET /tracks...');
      final response = await _dio.get('/tracks');

      debugPrint('[ApiService.getTracks] Réponse reçue — type: ${response.data.runtimeType}');

      if (response.data == null) {
        debugPrint('[ApiService.getTracks] ⚠️ response.data est null !');
        return [];
      }

      final List<dynamic> data = response.data as List<dynamic>;
      debugPrint('[ApiService.getTracks] Nombre d\'éléments JSON: ${data.length}');

      if (data.isEmpty) {
        debugPrint('[ApiService.getTracks] ⚠️ Liste vide retournée par l\'API');
        return [];
      }

      // Log du premier élément pour vérifier la structure
      debugPrint('[ApiService.getTracks] Premier élément: ${data.first}');

      final tracks = data.map((json) {
        try {
          return Track.fromJson(json as Map<String, dynamic>);
        } catch (e) {
          debugPrint('[ApiService.getTracks] ❌ Erreur parsing track: $e');
          debugPrint('[ApiService.getTracks] JSON problématique: $json');
          rethrow;
        }
      }).toList();

      debugPrint('[ApiService.getTracks] ✅ ${tracks.length} morceaux parsés avec succès');
      debugPrint('[ApiService.getTracks] Titres: ${tracks.map((t) => t.title).join(', ')}');

      return tracks;

    } on DioException catch (e) {
      debugPrint('[ApiService.getTracks] ❌ DioException: ${e.type} — ${e.message}');
      debugPrint('[ApiService.getTracks] Fallback sur mock data');
      // Fallback sur mock si API indisponible
      return MockData.tracks;
    } catch (e) {
      debugPrint('[ApiService.getTracks] ❌ Exception inattendue: $e');
      return MockData.tracks;
    }
  }

  Future<Track> getTrackById(String id) async {
    debugPrint('[ApiService.getTrackById] id: $id — useMock: $_useMock');

    if (_useMock) {
      debugPrint('[ApiService.getTrackById] Mode mock → recherche id=$id');
      await Future.delayed(const Duration(milliseconds: 200));
      final track = MockData.tracks.firstWhere(
            (t) => t.id == id,
        orElse: () {
          debugPrint('[ApiService.getTrackById] ⚠️ Track id=$id introuvable dans mock');
          return MockData.tracks.first;
        },
      );
      debugPrint('[ApiService.getTrackById] ✅ Track trouvé: ${track.title}');
      return track;
    }

    try {
      debugPrint('[ApiService.getTrackById] Appel API GET /tracks/$id...');
      final response = await _dio.get('/tracks/$id');
      debugPrint('[ApiService.getTrackById] Réponse: ${response.data}');
      final track = Track.fromJson(response.data as Map<String, dynamic>);
      debugPrint('[ApiService.getTrackById] ✅ Track parsé: ${track.title}');
      return track;
    } on DioException catch (e) {
      debugPrint('[ApiService.getTrackById] ❌ DioException: ${e.message}');
      throw _handleError(e);
    } catch (e) {
      debugPrint('[ApiService.getTrackById] ❌ Exception: $e');
      rethrow;
    }
  }

  // ——— PLAYLISTS ———

  Future<List<Playlist>> getPlaylists() async {
    debugPrint('[ApiService.getPlaylists] Début — useMock: $_useMock');

    if (_useMock) {
      debugPrint('[ApiService.getPlaylists] Mode mock → retourne ${MockData.playlists.length} playlists');
      await Future.delayed(const Duration(milliseconds: 500));
      return MockData.playlists;
    }

    try {
      debugPrint('[ApiService.getPlaylists] Appel API GET /playlists...');
      final response = await _dio.get('/playlists');

      debugPrint('[ApiService.getPlaylists] Réponse — type: ${response.data.runtimeType}');

      if (response.data == null) {
        debugPrint('[ApiService.getPlaylists] ⚠️ response.data est null → fallback mock');
        return MockData.playlists;
      }

      final List<dynamic> data = response.data as List<dynamic>;
      debugPrint('[ApiService.getPlaylists] Nombre de playlists: ${data.length}');

      if (data.isNotEmpty) {
        debugPrint('[ApiService.getPlaylists] Première playlist: ${data.first}');
      }

      final playlists = data.map((json) {
        try {
          return Playlist.fromJson(json as Map<String, dynamic>);
        } catch (e) {
          debugPrint('[ApiService.getPlaylists] ❌ Erreur parsing playlist: $e');
          debugPrint('[ApiService.getPlaylists] JSON problématique: $json');
          rethrow;
        }
      }).toList();

      debugPrint('[ApiService.getPlaylists] ✅ ${playlists.length} playlists parsées');
      debugPrint('[ApiService.getPlaylists] Noms: ${playlists.map((p) => p.name).join(', ')}');

      return playlists;

    } on DioException catch (e) {
      debugPrint('[ApiService.getPlaylists] ❌ DioException: ${e.type} — ${e.message}');
      debugPrint('[ApiService.getPlaylists] Fallback sur mock data');
      return MockData.playlists;
    } catch (e) {
      debugPrint('[ApiService.getPlaylists] ❌ Exception: $e');
      return MockData.playlists;
    }
  }

  Future<Playlist> createPlaylist({
    required String name,
    required List<String> trackIds,
  }) async {
    debugPrint('[ApiService.createPlaylist] name: $name — trackIds: $trackIds');

    if (_useMock) {
      debugPrint('[ApiService.createPlaylist] Mode mock → création locale');
      await Future.delayed(const Duration(milliseconds: 300));
      final playlist = Playlist(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        tracks: MockData.tracks.where((t) => trackIds.contains(t.id)).toList(),
      );
      debugPrint('[ApiService.createPlaylist] ✅ Playlist créée: ${playlist.name} (${playlist.trackCount} morceaux)');
      return playlist;
    }

    try {
      debugPrint('[ApiService.createPlaylist] Appel API POST /playlists...');
      final body = {'name': name, 'tracks': trackIds};
      debugPrint('[ApiService.createPlaylist] Body: $body');

      final response = await _dio.post('/playlists', data: body);
      debugPrint('[ApiService.createPlaylist] Réponse: ${response.data}');

      final playlist = Playlist.fromJson(response.data as Map<String, dynamic>);
      debugPrint('[ApiService.createPlaylist] ✅ Playlist créée: ${playlist.name}');
      return playlist;

    } on DioException catch (e) {
      debugPrint('[ApiService.createPlaylist] ❌ DioException: ${e.message}');
      throw _handleError(e);
    } catch (e) {
      debugPrint('[ApiService.createPlaylist] ❌ Exception: $e');
      rethrow;
    }
  }

  Future<Playlist> reorderPlaylist({
    required String playlistId,
    required List<String> trackIds,
  }) async {
    debugPrint('[ApiService.reorderPlaylist] playlistId: $playlistId');
    debugPrint('[ApiService.reorderPlaylist] Nouvel ordre: $trackIds');

    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 200));
      final playlist = MockData.playlists.firstWhere((p) => p.id == playlistId);
      final reordered = trackIds
          .map((id) => playlist.tracks.firstWhere((t) => t.id == id))
          .toList();
      debugPrint('[ApiService.reorderPlaylist] ✅ Mock reorder OK');
      return playlist.copyWith(tracks: reordered);
    }

    try {
      debugPrint('[ApiService.reorderPlaylist] Appel API PUT /playlists/$playlistId/reorder...');
      final response = await _dio.put(
        '/playlists/$playlistId/reorder',
        data: {'tracks': trackIds},
      );
      debugPrint('[ApiService.reorderPlaylist] Réponse: ${response.data}');
      final playlist = Playlist.fromJson(response.data as Map<String, dynamic>);
      debugPrint('[ApiService.reorderPlaylist] ✅ Reorder OK');
      return playlist;
    } on DioException catch (e) {
      debugPrint('[ApiService.reorderPlaylist] ❌ DioException: ${e.message}');
      throw _handleError(e);
    } catch (e) {
      debugPrint('[ApiService.reorderPlaylist] ❌ Exception: $e');
      rethrow;
    }
  }

  Future<Playlist> addTrackToPlaylist({
    required String playlistId,
    required String trackId,
  }) async {
    debugPrint('[ApiService.addTrackToPlaylist] playlistId: $playlistId — trackId: $trackId');

    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 200));
      final playlist = MockData.playlists.firstWhere((p) => p.id == playlistId);
      final track = MockData.tracks.firstWhere((t) => t.id == trackId);
      debugPrint('[ApiService.addTrackToPlaylist] ✅ Mock ajout: ${track.title}');
      return playlist.addTrack(track);
    }

    try {
      debugPrint('[ApiService.addTrackToPlaylist] Appel API POST /Playlists/$playlistId/tracks/$trackId...');
      final response = await _dio.post('/Playlists/$playlistId/tracks/$trackId');
      debugPrint('[ApiService.addTrackToPlaylist] Réponse: ${response.data}');
      final playlist = Playlist.fromJson(response.data as Map<String, dynamic>);
      debugPrint('[ApiService.addTrackToPlaylist] ✅ Ajout OK');
      return playlist;
    } on DioException catch (e) {
      debugPrint('[ApiService.addTrackToPlaylist] ❌ DioException: ${e.message}');
      throw _handleError(e);
    } catch (e) {
      debugPrint('[ApiService.addTrackToPlaylist] ❌ Exception: $e');
      rethrow;
    }
  }

  Future<Playlist> removeTrackFromPlaylist({
    required String playlistId,
    required String trackId,
  }) async {
    debugPrint('[ApiService.removeTrackFromPlaylist] playlistId: $playlistId — trackId: $trackId');

    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 200));
      final playlist = MockData.playlists.firstWhere((p) => p.id == playlistId);
      debugPrint('[ApiService.removeTrackFromPlaylist] ✅ Mock suppression OK');
      return playlist.removeTrack(trackId);
    }

    try {
      debugPrint('[ApiService.removeTrackFromPlaylist] Appel API DELETE /Playlists/$playlistId/tracks/$trackId...');
      final response = await _dio.delete('/Playlists/$playlistId/tracks/$trackId');
      debugPrint('[ApiService.removeTrackFromPlaylist] Réponse: ${response.data}');
      final playlist = Playlist.fromJson(response.data as Map<String, dynamic>);
      debugPrint('[ApiService.removeTrackFromPlaylist] ✅ Suppression OK');
      return playlist;
    } on DioException catch (e) {
      debugPrint('[ApiService.removeTrackFromPlaylist] ❌ DioException: ${e.message}');
      throw _handleError(e);
    } catch (e) {
      debugPrint('[ApiService.removeTrackFromPlaylist] ❌ Exception: $e');
      rethrow;
    }
  }

  // ——— CATEGORIES ———

  Future<List<MusicCategory>> getCategories() async {
    debugPrint('[ApiService.getCategories] Début — useMock: $_useMock');

    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 300));
      return [
        const MusicCategory(id: 1, name: 'Zouglou', trackCount: 0),
        const MusicCategory(id: 2, name: 'Coupé-Décalé', trackCount: 0),
        const MusicCategory(id: 3, name: 'Rap Ivoire', trackCount: 1),
      ];
    }

    try {
      debugPrint('[ApiService.getCategories] Appel API GET /Categories...');
      final response = await _dio.get('/Categories');

      debugPrint('[ApiService.getCategories] Réponse: ${response.data}');

      final List<dynamic> data = response.data as List<dynamic>;
      final categories = data
          .map((json) => MusicCategory.fromJson(json as Map<String, dynamic>))
          .toList();

      debugPrint('[ApiService.getCategories] ✅ ${categories.length} catégories');
      return categories;

    } on DioException catch (e) {
      debugPrint('[ApiService.getCategories] ❌ DioException: ${e.message}');
      throw _handleError(e);
    } catch (e) {
      debugPrint('[ApiService.getCategories] ❌ Exception: $e');
      rethrow;
    }
  }

  /*Future<Playlist> addTrackToPlaylist({
    required String playlistId,
    required String trackId,
  }) async {
    debugPrint('[ApiService.addTrackToPlaylist] playlistId: $playlistId — trackId: $trackId');

    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 200));
      final playlist = MockData.playlists.firstWhere((p) => p.id == playlistId);
      final track = MockData.tracks.firstWhere((t) => t.id == trackId);
      debugPrint('[ApiService.addTrackToPlaylist] ✅ Mock ajout: ${track.title} → ${playlist.name}');
      return playlist.addTrack(track);
    }

    try {
      debugPrint('[ApiService.addTrackToPlaylist] Appel API POST /playlists/$playlistId/tracks...');
      final response = await _dio.post(
        '/Playlists/$playlistId/tracks/$trackId',
      );
      debugPrint('[ApiService.addTrackToPlaylist] Réponse: ${response.data}');
      final playlist = Playlist.fromJson(response.data as Map<String, dynamic>);
      debugPrint('[ApiService.addTrackToPlaylist] ✅ Ajout OK — playlist: ${playlist.name} (${playlist.trackCount} morceaux)');
      return playlist;
    } on DioException catch (e) {
      debugPrint('[ApiService.addTrackToPlaylist] ❌ DioException: ${e.message}');
      throw _handleError(e);
    } catch (e) {
      debugPrint('[ApiService.addTrackToPlaylist] ❌ Exception: $e');
      rethrow;
    }
  }

  Future<Playlist> removeTrackFromPlaylist({
    required String playlistId,
    required String trackId,
  }) async {
    debugPrint('[ApiService.removeTrackFromPlaylist] playlistId: $playlistId — trackId: $trackId');

    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 200));
      final playlist = MockData.playlists.firstWhere((p) => p.id == playlistId);
      debugPrint('[ApiService.removeTrackFromPlaylist] ✅ Mock suppression OK');
      return playlist.removeTrack(trackId);
    }

    try {
      debugPrint('[ApiService.removeTrackFromPlaylist] Appel API DELETE /playlists/$playlistId/tracks/$trackId...');
      final response = await _dio.delete('/playlists/$playlistId/tracks/$trackId');
      debugPrint('[ApiService.removeTrackFromPlaylist] Réponse: ${response.data}');
      final playlist = Playlist.fromJson(response.data as Map<String, dynamic>);
      debugPrint('[ApiService.removeTrackFromPlaylist] ✅ Suppression OK');
      return playlist;
    } on DioException catch (e) {
      debugPrint('[ApiService.removeTrackFromPlaylist] ❌ DioException: ${e.message}');
      throw _handleError(e);
    } catch (e) {
      debugPrint('[ApiService.removeTrackFromPlaylist] ❌ Exception: $e');
      rethrow;
    }
  }**/

  // ——— ERREURS ———

  Exception _handleError(DioException e) {
    debugPrint('[ApiService._handleError] Type: ${e.type}');
    debugPrint('[ApiService._handleError] Status: ${e.response?.statusCode}');
    debugPrint('[ApiService._handleError] Response data: ${e.response?.data}');
    debugPrint('[ApiService._handleError] Message: ${e.message}');

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        debugPrint('[ApiService._handleError] → Timeout connexion');
        return Exception('Délai de connexion dépassé');
      case DioExceptionType.receiveTimeout:
        debugPrint('[ApiService._handleError] → Timeout réception');
        return Exception('Délai de réception dépassé');
      case DioExceptionType.connectionError:
        debugPrint('[ApiService._handleError] → Erreur connexion (serveur inaccessible ?)');
        return Exception('Impossible de contacter le serveur');
      case DioExceptionType.badResponse:
        final code = e.response?.statusCode;
        debugPrint('[ApiService._handleError] → Réponse HTTP $code');
        switch (code) {
          case 400: return Exception('Requête invalide (400)');
          case 401: return Exception('Non autorisé (401)');
          case 403: return Exception('Accès refusé (403)');
          case 404: return Exception('Ressource introuvable (404)');
          case 422: return Exception('Données invalides (422)');
          case 500: return Exception('Erreur serveur (500)');
          case 503: return Exception('Service indisponible (503)');
          default:  return Exception('Erreur HTTP $code');
        }
      case DioExceptionType.cancel:
        debugPrint('[ApiService._handleError] → Requête annulée');
        return Exception('Requête annulée');
      default:
        debugPrint('[ApiService._handleError] → Erreur inconnue: ${e.message}');
        return Exception('Erreur inattendue: ${e.message}');
    }
  }
}
