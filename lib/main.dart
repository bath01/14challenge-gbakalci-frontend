import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/services/api_service.dart';
import 'core/services/player_service.dart';
import 'core/services/playlist_service.dart';
import 'core/providers/player_provider.dart';
import 'core/providers/playlist_provider.dart';
import 'app.dart';
import 'core/services/download_service.dart';
import 'core/providers/download_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final apiService      = ApiService();
  final playerService   = PlayerService();
  final playlistService = PlaylistService(apiService: apiService);
  final downloadService = DownloadService();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => PlayerProvider(
            playerService: playerService,
            downloadService: downloadService, // ← ajouté
          ),
        ),
        ChangeNotifierProvider(
          create: (_) {
            final provider = PlaylistProvider(
              playlistService: playlistService,
              apiService: apiService,
            );
            provider.loadAll();
            return provider;
          },
        ),
        ChangeNotifierProvider(
          create: (_) => DownloadProvider(downloadService: downloadService),
        ),
      ],
      child: const MusicApp(),
    ),
  );
}