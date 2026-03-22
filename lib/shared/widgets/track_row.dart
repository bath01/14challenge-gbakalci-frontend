import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/track.dart';
import '../../core/providers/player_provider.dart';
import '../theme.dart';
import '../responsive.dart';
import 'cover_art.dart';
import 'genre_badge.dart';
import 'download_button.dart';

class TrackRow extends StatelessWidget {
  final Track track;
  final VoidCallback? onTap;

  const TrackRow({
    super.key,
    required this.track,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);

    return Consumer<PlayerProvider>(
      builder: (context, player, _) {
        final isActive = player.state.currentTrack?.id == track.id;
        final isPlaying = isActive && player.state.isPlaying;

        return GestureDetector(
          onTap: onTap ?? () => player.playTrack(track),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: EdgeInsets.symmetric(
              horizontal: r.paddingH * 0.5,
              vertical: 2,
            ),
            padding: EdgeInsets.symmetric(
              horizontal: r.paddingH,
              vertical: r.paddingV,
            ),
            decoration: BoxDecoration(
              color: isActive ? ciOrange.withOpacity(0.07) : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
              border: Border(
                left: BorderSide(
                  color: isActive ? ciOrange : Colors.transparent,
                  width: 3,
                ),
              ),
            ),
            child: Row(
              children: [

                // ——— Pochette ———
                CoverArt(
                  track: track,
                  size: r.coverSizeMini,
                  radius: 10,
                  isPlaying: isPlaying,
                ),

                SizedBox(width: r.gap),

                // ——— Titre + artiste ———
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        track.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: r.bodySize,
                          fontWeight: FontWeight.w700,
                          color: isActive ? ciOrange : textP,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        track.artist,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: r.smallSize,
                          color: textS,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(width: r.gap * 0.5),

                // ——— Genre + durée + téléchargement ———
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (track.genre != null)
                      GenreBadge(genre: track.genre!),
                    const SizedBox(height: 4),
                    Text(
                      track.formattedDuration,
                      style: TextStyle(
                        fontSize: r.tinySize,
                        color: textDim,
                      ),
                    ),
                  ],
                ),

                SizedBox(width: r.gap * 0.5),

                // ——— Bouton téléchargement ———
                // Ne pas afficher si déjà local
                if (!track.isLocal)
                  DownloadButton(
                    track: track,
                    size: r.isSmall ? 26 : 30,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}