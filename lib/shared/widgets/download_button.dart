import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../../core/models/track.dart';
import '../../core/providers/download_provider.dart';
import '../../core/providers/player_provider.dart';
import '../theme.dart';

class DownloadButton extends StatelessWidget {
  final Track track;
  final double size;

  const DownloadButton({
    super.key,
    required this.track,
    this.size = 32,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<DownloadProvider>(
      builder: (context, download, _) {
        final isDownloading = download.isDownloading(track.id);
        final isDownloaded = download.isDownloaded(track.id);
        final progress = download.getProgress(track.id);

        return GestureDetector(
          onTap: () async {
            if (isDownloaded) {
              // ✅ Récupère le track avec son chemin local depuis la BDD
              final downloadedTrack = download.downloadedTracks.firstWhere(
                    (t) => t.id == track.id,
                orElse: () => track,
              );

              debugPrint('[DownloadButton] Lecture locale: ${downloadedTrack.audioUrl}');
              debugPrint('[DownloadButton] isLocal: ${downloadedTrack.isLocal}');

              if (context.mounted) {
                context.read<PlayerProvider>().playTrack(downloadedTrack);
              }

            } else if (!isDownloading) {
              debugPrint('[DownloadButton] Début téléchargement: ${track.title}');
              await download.downloadTrack(track);
            }
          },
          onLongPress: isDownloaded
              ? () => _confirmDelete(context, download)
              : null,
          child: SizedBox(
            width: size,
            height: size,
            child: isDownloading
                ? Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: size,
                  height: size,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 2,
                    backgroundColor: ciOrange.withOpacity(0.2),
                    valueColor: const AlwaysStoppedAnimation(ciOrange),
                  ),
                ),
                Icon(
                  Icons.download,
                  color: ciOrange,
                  size: size * 0.45,
                ),
              ],
            )
                : Icon(
              isDownloaded
                  ? Icons.download_done
                  : Icons.download_outlined,
              color: isDownloaded ? ciGreen : textS,
              size: size * 0.6,
            ),
          ),
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, DownloadProvider download) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A22),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Supprimer le téléchargement ?',
          style: TextStyle(color: Colors.white, fontSize: 15),
        ),
        content: Text(
          '${track.title} sera supprimé de votre appareil.',
          style: const TextStyle(color: Colors.white54, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Annuler',
              style: TextStyle(color: Colors.white54),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              download.deleteDownload(track.id);
            },
            child: const Text(
              'Supprimer',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}