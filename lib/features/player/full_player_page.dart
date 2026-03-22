import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/PlayerState.dart';
import '../../core/providers/player_provider.dart';
import '../../shared/theme.dart';
import '../../shared/responsive.dart';
import '../../shared/widgets/cover_art.dart';
import '../../shared/widgets/genre_badge.dart';
import '../../shared/widgets/visualizer_bars.dart';

class FullPlayerPage extends StatelessWidget {
  const FullPlayerPage({super.key});

  String _formatDuration(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);

    return Scaffold(
      backgroundColor: darkBg,
      body: SafeArea(
        child: Consumer<PlayerProvider>(
          builder: (context, player, _) {
            final track = player.state.currentTrack;
            if (track == null) return const SizedBox.shrink();

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: r.gapLarge,
                vertical: r.paddingV,
              ),
              child: Column(
                children: [

                  // ——— Header ———
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(
                          Icons.keyboard_arrow_down,
                          color: textS,
                          size: r.isSmall ? 24 : 28,
                        ),
                      ),
                      Text(
                        'EN LECTURE',
                        style: TextStyle(
                          fontSize: r.tinySize + 2,
                          fontWeight: FontWeight.w700,
                          color: textS,
                          letterSpacing: 1,
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: Icon(
                          Icons.more_horiz,
                          color: textS,
                          size: r.isSmall ? 24 : 28,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: r.gapLarge),

                  // ——— Pochette ———
                  Center(
                    child: CoverArt(
                      track: track,
                      size: r.coverSizeFull,
                      radius: r.coverRadiusFull,
                      isPlaying: player.state.isPlaying,
                    ),
                  ),

                  SizedBox(height: r.gapLarge),

                  // ——— Visualiseur ———
                  VisualizerBars(
                    frequencyData: player.state.frequencyData.isEmpty
                        ? List.filled(20, 0.05)
                        : player.state.frequencyData,
                    height: r.isSmall ? 28 : 40,
                    count: 20,
                    isPlaying: player.state.isPlaying,
                  ),

                  SizedBox(height: r.gap),

                  // ——— Titre + genre ———
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              track.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: r.isSmall ? 16 : 18,
                                fontWeight: FontWeight.w800,
                                color: textP,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              track.artist,
                              style: TextStyle(
                                fontSize: r.bodySize,
                                color: textS,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (track.genre != null)
                        GenreBadge(genre: track.genre!, large: true),
                    ],
                  ),

                  SizedBox(height: r.gap),

                  // ——— Barre de progression ———
                  SliderTheme(
                    data: SliderThemeData(
                      trackHeight: 4,
                      thumbShape: RoundSliderThumbShape(
                        enabledThumbRadius: r.isSmall ? 5 : 6,
                      ),
                      overlayShape: RoundSliderOverlayShape(
                        overlayRadius: r.isSmall ? 12 : 14,
                      ),
                      activeTrackColor: ciOrange,
                      inactiveTrackColor: border,
                      thumbColor: ciOrange,
                      overlayColor: ciOrange.withOpacity(0.2),
                    ),
                    child: Slider(
                      value: player.state.progress.clamp(0.0, 1.0),
                      onChanged: (v) => player.seekToProgress(v),
                    ),
                  ),

                  // ——— Temps ———
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: r.gap * 0.5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatDuration(player.state.currentTime),
                          style: TextStyle(fontSize: r.tinySize + 1, color: textS),
                        ),
                        Text(
                          track.formattedDuration,
                          style: TextStyle(fontSize: r.tinySize + 1, color: textS),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: r.gapLarge),

                  // ——— Contrôles ———
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        onPressed: () => player.toggleShuffle(),
                        icon: Icon(
                          Icons.shuffle,
                          color: player.state.shuffle ? ciOrange : textDim,
                          size: r.isSmall ? 20 : 22,
                        ),
                      ),
                      IconButton(
                        onPressed: () => player.skipToPrevious(),
                        icon: Icon(
                          Icons.skip_previous,
                          color: textP,
                          size: r.isSmall ? 30 : 36,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => player.togglePlayPause(),
                        child: Container(
                          width: r.isSmall ? 56 : 64,
                          height: r.isSmall ? 56 : 64,
                          decoration: const BoxDecoration(
                            color: ciOrange,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            player.state.isPlaying
                                ? Icons.pause
                                : Icons.play_arrow,
                            color: Colors.white,
                            size: r.isSmall ? 26 : 32,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => player.skipToNext(),
                        icon: Icon(
                          Icons.skip_next,
                          color: textP,
                          size: r.isSmall ? 30 : 36,
                        ),
                      ),
                      IconButton(
                        onPressed: () => player.cycleRepeatMode(),
                        icon: Icon(
                          player.state.repeatMode == RepeatMode.one
                              ? Icons.repeat_one
                              : Icons.repeat,
                          color: player.state.repeatMode != RepeatMode.none
                              ? ciOrange
                              : textDim,
                          size: r.isSmall ? 20 : 22,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: r.gapLarge),

                  // ——— Volume ———
                  Row(
                    children: [
                      Icon(Icons.volume_down,
                          color: textDim, size: r.isSmall ? 18 : 20),
                      Expanded(
                        child: SliderTheme(
                          data: SliderThemeData(
                            trackHeight: 3,
                            thumbShape: RoundSliderThumbShape(
                              enabledThumbRadius: r.isSmall ? 4 : 5,
                            ),
                            activeTrackColor: ciOrange,
                            inactiveTrackColor: border,
                            thumbColor: ciOrange,
                          ),
                          child: Slider(
                            value: player.state.volume,
                            onChanged: (v) => player.setVolume(v),
                          ),
                        ),
                      ),
                      Icon(Icons.volume_up,
                          color: textDim, size: r.isSmall ? 18 : 20),
                    ],
                  ),

                  SizedBox(height: r.gap),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}