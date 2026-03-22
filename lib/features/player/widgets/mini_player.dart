import 'package:flutter/material.dart';
import 'package:gbakalci/features/player/lyrics_player_page.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/player_provider.dart';
import '../../../shared/theme.dart';
import '../../../shared/responsive.dart';
import '../../../shared/widgets/cover_art.dart';
import '../../../shared/widgets/visualizer_bars.dart';
import '../full_player_page.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);

    return Consumer<PlayerProvider>(
      builder: (context, player, _) {
        final track = player.state.currentTrack;
        if (track == null) return const SizedBox.shrink();

        return GestureDetector(
          onTap: () => Navigator.of(context).push(
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => const LyricsPlayerPage(),
              transitionsBuilder: (_, anim, __, child) => SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 1),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: anim,
                  curve: Curves.easeOut,
                )),
                child: child,
              ),
            ),
          ),
          child: Container(
            margin: EdgeInsets.fromLTRB(r.paddingH * 0.5, 0, r.paddingH * 0.5, r.gap * 0.5),
            padding: EdgeInsets.fromLTRB(r.paddingH, r.paddingV, r.paddingH, r.paddingV + 6),
            decoration: BoxDecoration(
              color: card.withOpacity(0.97),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: border),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    CoverArt(
                      track: track,
                      size: r.coverSizeMini - 6,
                      radius: 8,
                      isPlaying: player.state.isPlaying,
                    ),

                    SizedBox(width: r.gap),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            track.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: r.bodySize - 1,
                              fontWeight: FontWeight.w700,
                              color: textP,
                            ),
                          ),
                          Text(
                            track.artist,
                            style: TextStyle(
                              fontSize: r.smallSize - 1,
                              color: textS,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(width: r.gap * 0.5),

                    SizedBox(
                      width: 36,
                      child: VisualizerBars(
                        frequencyData: player.state.frequencyData.isEmpty
                            ? List.filled(8, 0.05)
                            : player.state.frequencyData.take(8).toList(),
                        height: 18,
                        count: 8,
                        isPlaying: player.state.isPlaying,
                      ),
                    ),

                    SizedBox(width: r.gap * 0.5),

                    GestureDetector(
                      onTap: () => player.togglePlayPause(),
                      child: Icon(
                        player.state.isPlaying
                            ? Icons.pause
                            : Icons.play_arrow,
                        color: textP,
                        size: r.isSmall ? 24 : 28,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: r.gap * 0.5),

                ClipRRect(
                  borderRadius: BorderRadius.circular(1),
                  child: LinearProgressIndicator(
                    value: player.state.progress,
                    backgroundColor: border,
                    valueColor: const AlwaysStoppedAnimation<Color>(ciOrange),
                    minHeight: 2,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}