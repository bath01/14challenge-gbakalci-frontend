import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/track.dart';

class LocalAudioService {

  static const List<String> _supportedFormats = [
    'mp3', 'mp4', 'm4a', 'aac', 'ogg',
    'wav', 'flac', 'wma', 'opus',
  ];

  // ——— PERMISSIONS ———

  Future<bool> requestPermission() async {
    PermissionStatus status = await Permission.audio.request();
    if (status.isGranted) return true;

    status = await Permission.storage.request();
    if (status.isPermanentlyDenied) {
      await openAppSettings();
      return false;
    }
    return status.isGranted;
  }

  Future<bool> hasPermission() async {
    return await Permission.audio.isGranted ||
        await Permission.storage.isGranted;
  }

  // ——— SCAN DES FICHIERS ———

  Future<List<Track>> getLocalTracks() async {
    final granted = await requestPermission();
    if (!granted) {
      throw Exception('Permission refusée');
    }

    final List<Track> tracks = [];

    try {
      final dirs = await _getMusicDirectories();

      for (final dir in dirs) {
        if (await dir.exists()) {
          await _scanDirectory(dir, tracks);
        }
      }

      // Tri par titre alphabétique
      tracks.sort((a, b) => a.title.compareTo(b.title));
      return tracks;

    } catch (e) {
      debugPrint('[LocalAudioService] Erreur: $e');
      return [];
    }
  }

  // Scanne un dossier récursivement
  Future<void> _scanDirectory(Directory dir, List<Track> tracks) async {
    try {
      final entities = dir.listSync(recursive: true);
      for (final entity in entities) {
        if (entity is File) {
          final ext = entity.path.split('.').last.toLowerCase();
          if (_supportedFormats.contains(ext)) {
            final track = await _fileToTrack(entity);
            if (track != null) tracks.add(track);
          }
        }
      }
    } catch (e) {
      debugPrint('[LocalAudioService] Erreur scan dossier: $e');
    }
  }

  // Retourne les dossiers musique selon la plateforme
  Future<List<Directory>> _getMusicDirectories() async {
    final List<Directory> dirs = [];

    if (Platform.isAndroid) {
      // Dossiers standard Android
      final androidDirs = [
        '/storage/emulated/0/Music',
        '/storage/emulated/0/Download',
        '/storage/emulated/0/Downloads',
        '/storage/emulated/0/DCIM',
      ];

      for (final path in androidDirs) {
        dirs.add(Directory(path));
      }

      // Stockage externe (carte SD)
      try {
        final externalDirs = await getExternalStorageDirectories();
        if (externalDirs != null) {
          for (final dir in externalDirs) {
            final root = dir.path.split('Android').first;
            dirs.add(Directory('${root}Music'));
            dirs.add(Directory('${root}Download'));
          }
        }
      } catch (_) {}

    } else if (Platform.isIOS) {
      final docs = await getApplicationDocumentsDirectory();
      dirs.add(docs);
    }

    return dirs;
  }

  // Convertit un File en Track
  Future<Track?> _fileToTrack(File file) async {
    try {
      final stat = await file.stat();

      // Ignore les fichiers trop petits (sons système < 500KB)
      if (stat.size < 512 * 1024) return null;

      final fileName = file.path.split('/').last;
      final nameWithoutExt = fileName.contains('.')
          ? fileName.substring(0, fileName.lastIndexOf('.'))
          : fileName;

      // Essaie de parser "Artiste - Titre" depuis le nom de fichier
      String title = nameWithoutExt;
      String artist = 'Artiste inconnu';

      if (nameWithoutExt.contains(' - ')) {
        final parts = nameWithoutExt.split(' - ');
        if (parts.length >= 2) {
          artist = parts[0].trim();
          title = parts.sublist(1).join(' - ').trim();
        }
      }

      return Track(
        id: 'local_${file.path.hashCode.abs()}',
        title: title,
        artist: artist,
        album: _extractAlbumFromPath(file.path),
        coverUrl: '',
        duration: 0, // durée inconnue sans métadonnées
        audioUrl: file.path,
        genre: null,
        isLocal: true,
        localId: file.path.hashCode.abs(),
      );
    } catch (e) {
      return null;
    }
  }

  // Extrait le nom du dossier parent comme nom d'album
  // ex: "/storage/Music/Mon Album/chanson.mp3" → "Mon Album"
  String _extractAlbumFromPath(String path) {
    final parts = path.split('/');
    if (parts.length >= 2) {
      return parts[parts.length - 2];
    }
    return 'Album inconnu';
  }

  // Pas d'artwork sans on_audio_query
  Future<Uint8List?> getArtwork(int localId) async => null;
}