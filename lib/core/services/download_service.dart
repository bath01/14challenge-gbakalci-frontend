import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import '../models/track.dart';

class DownloadService {
  static const String _baseUrl = 'https://gbakalci.chalenge14.com/api';
  static const String _dbName = 'gbakalci.db';
  static const String _tableName = 'downloaded_tracks';

  late final Dio _dio;
  Database? _db;

  DownloadService() {
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 60),
    ));
  }

  // ——— INITIALISATION BDD ———

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDatabase();
    return _db!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, _dbName);

    debugPrint('[DownloadService] Initialisation BDD: $path');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        debugPrint('[DownloadService] Création table $_tableName');
        await db.execute('''
          CREATE TABLE $_tableName (
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            artist TEXT NOT NULL,
            album TEXT NOT NULL,
            coverUrl TEXT,
            duration INTEGER NOT NULL,
            genre TEXT,
            localPath TEXT NOT NULL,
            downloadedAt INTEGER NOT NULL
          )
        ''');
        debugPrint('[DownloadService] Table créée avec succès');
      },
      onUpgrade: (db, oldVersion, newVersion) {
        debugPrint('[DownloadService] Mise à jour BDD v$oldVersion → v$newVersion');
      },
    );
  }

  // ——— TÉLÉCHARGEMENT ———

  // Télécharge un morceau et le stocke dans la BDD
  Future<Track> downloadTrack(
      Track track, {
        Function(double progress)? onProgress,
      }) async {
    debugPrint('[DownloadService.downloadTrack] Début téléchargement: ${track.title}');

    // Vérifie si déjà téléchargé
    final existing = await getDownloadedTrack(track.id);
    if (existing != null) {
      debugPrint('[DownloadService.downloadTrack] Déjà téléchargé: ${track.title}');
      return existing;
    }

    try {
      // Dossier de destination
      final dir = await _getAudioDirectory();
      final fileName = 'track_${track.id}.mp3';
      final filePath = p.join(dir.path, fileName);

      debugPrint('[DownloadService.downloadTrack] URL: $_baseUrl/Tracks/${track.id}/audio');
      debugPrint('[DownloadService.downloadTrack] Destination: $filePath');

      // Téléchargement avec progression
      await _dio.download(
        '/Tracks/${track.id}/audio',
        filePath,
        onReceiveProgress: (received, total) {
          if (total > 0) {
            final progress = received / total;
            debugPrint('[DownloadService] Progression: ${(progress * 100).toStringAsFixed(1)}%');
            onProgress?.call(progress);
          }
        },
      );

      debugPrint('[DownloadService.downloadTrack] ✅ Fichier téléchargé: $filePath');

      // Crée le Track avec le chemin local
      final downloadedTrack = track.copyWith(
        audioUrl: filePath,
        isLocal: true,
      );

      // Sauvegarde dans la BDD
      await _saveToDatabase(downloadedTrack, filePath);
      debugPrint('[DownloadService.downloadTrack] ✅ Sauvegardé en BDD');

      return downloadedTrack;

    } on DioException catch (e) {
      debugPrint('[DownloadService.downloadTrack] ❌ DioException: ${e.message}');
      throw Exception('Erreur téléchargement: ${e.message}');
    } catch (e) {
      debugPrint('[DownloadService.downloadTrack] ❌ Exception: $e');
      throw Exception('Erreur inattendue: $e');
    }
  }

  // ——— BDD ———

  // Sauvegarde un track téléchargé dans la BDD
  Future<void> _saveToDatabase(Track track, String localPath) async {
    final db = await database;
    debugPrint('[DownloadService._saveToDatabase] Sauvegarde: ${track.title}');

    await db.insert(
      _tableName,
      {
        'id': track.id,
        'title': track.title,
        'artist': track.artist,
        'album': track.album,
        'coverUrl': track.coverUrl,
        'duration': track.duration,
        'genre': track.genre,
        'localPath': localPath,
        'downloadedAt': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
      // replace = si le track existe déjà → on le remplace
    );
  }

  // Récupère tous les tracks téléchargés
  Future<List<Track>> getAllDownloadedTracks() async {
    final db = await database;
    debugPrint('[DownloadService.getAllDownloadedTracks] Chargement...');

    final maps = await db.query(
      _tableName,
      orderBy: 'downloadedAt DESC',
      // les plus récents en premier
    );

    debugPrint('[DownloadService.getAllDownloadedTracks] ${maps.length} tracks trouvés');

    final tracks = <Track>[];
    for (final map in maps) {
      final localPath = map['localPath'] as String;
      final file = File(localPath);

      // Vérifie que le fichier existe encore
      if (await file.exists()) {
        tracks.add(_mapToTrack(map));
      } else {
        // Fichier supprimé → on nettoie la BDD
        debugPrint('[DownloadService] Fichier manquant: $localPath — suppression BDD');
        await _deleteFromDatabase(map['id'] as String);
      }
    }

    return tracks;
  }

  // Récupère un track téléchargé par son id
  Future<Track?> getDownloadedTrack(String trackId) async {
    final db = await database;
    final maps = await db.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [trackId],
      limit: 1,
    );

    if (maps.isEmpty) return null;

    final localPath = maps.first['localPath'] as String;
    final file = File(localPath);

    if (!await file.exists()) {
      debugPrint('[DownloadService.getDownloadedTrack] Fichier manquant: $localPath');
      await _deleteFromDatabase(trackId);
      return null;
    }

    return _mapToTrack(maps.first);
  }

  // Vérifie si un track est téléchargé
  Future<bool> isDownloaded(String trackId) async {
    final track = await getDownloadedTrack(trackId);
    return track != null;
  }

  // Supprime un track téléchargé
  Future<void> deleteDownloadedTrack(String trackId) async {
    debugPrint('[DownloadService.deleteDownloadedTrack] Suppression: $trackId');

    final track = await getDownloadedTrack(trackId);
    if (track == null) return;

    // Supprime le fichier
    final file = File(track.audioUrl!);
    if (await file.exists()) {
      await file.delete();
      debugPrint('[DownloadService.deleteDownloadedTrack] ✅ Fichier supprimé');
    }

    // Supprime de la BDD
    await _deleteFromDatabase(trackId);
    debugPrint('[DownloadService.deleteDownloadedTrack] ✅ BDD nettoyée');
  }

  Future<void> _deleteFromDatabase(String trackId) async {
    final db = await database;
    await db.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [trackId],
    );
  }

  // Taille totale des téléchargements en Mo
  Future<double> getTotalDownloadSize() async {
    final tracks = await getAllDownloadedTracks();
    double totalBytes = 0;

    for (final track in tracks) {
      if (track.audioUrl != null) {
        final file = File(track.audioUrl!);
        if (await file.exists()) {
          final stat = await file.stat();
          totalBytes += stat.size;
        }
      }
    }

    final totalMb = totalBytes / (1024 * 1024);
    debugPrint('[DownloadService.getTotalDownloadSize] Total: ${totalMb.toStringAsFixed(1)} Mo');
    return totalMb;
  }

  // Supprime tous les téléchargements
  Future<void> deleteAllDownloads() async {
    debugPrint('[DownloadService.deleteAllDownloads] Suppression de tout...');
    final tracks = await getAllDownloadedTracks();

    for (final track in tracks) {
      if (track.audioUrl != null) {
        final file = File(track.audioUrl!);
        if (await file.exists()) await file.delete();
      }
    }

    final db = await database;
    await db.delete(_tableName);
    debugPrint('[DownloadService.deleteAllDownloads] ✅ Tout supprimé');
  }

  // ——— UTILITAIRES ———

  // Dossier de stockage des audios
  Future<Directory> _getAudioDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final audioDir = Directory(p.join(appDir.path, 'audio'));
    if (!await audioDir.exists()) {
      await audioDir.create(recursive: true);
      debugPrint('[DownloadService] Dossier créé: ${audioDir.path}');
    }
    return audioDir;
  }

  // Convertit une Map BDD en Track
  Track _mapToTrack(Map<String, dynamic> map) {
    return Track(
      id: map['id'] as String,
      title: map['title'] as String,
      artist: map['artist'] as String,
      album: map['album'] as String,
      coverUrl: map['coverUrl'] as String? ?? '',
      duration: map['duration'] as int,
      genre: map['genre'] as String?,
      audioUrl: map['localPath'] as String,
      isLocal: true,
    );
  }

  // Ferme la BDD proprement
  Future<void> close() async {
    final db = _db;
    if (db != null) {
      await db.close();
      _db = null;
    }
  }
}