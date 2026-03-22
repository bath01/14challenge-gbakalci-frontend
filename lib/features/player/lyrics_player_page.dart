import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/PlayerState.dart' as ps;
import '../../core/providers/player_provider.dart';
import '../../shared/theme.dart';
import '../../shared/responsive.dart';
import '../../shared/widgets/cover_art.dart';
import '../../shared/widgets/rotating_cover.dart';
import '../../shared/widgets/visualizer_bars.dart';
import 'queue_page.dart';

class LyricsPlayerPage extends StatelessWidget {
  const LyricsPlayerPage({super.key});

  String _formatDuration(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  String _formatRemaining(Duration current, Duration total) {
    final remaining = total - current;
    final m = remaining.inMinutes;
    final s = remaining.inSeconds % 60;
    return '-$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Consumer<PlayerProvider>(
        builder: (context, player, _) {
          final track = player.state.currentTrack;
          if (track == null) {
            Navigator.pop(context);
            return const SizedBox.shrink();
          }

          final gradient = CoverArt.getGradient(track.artist);
          final dominantColor = gradient.colors.first;

          return Stack(
            children: [

              // ——— Fond dégradé ———
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      dominantColor.withValues(alpha: 0.8),
                      darkBg.withValues(alpha: 0.95),
                      darkBg,
                    ],
                    stops: const [0.0, 0.4, 1.0],
                  ),
                ),
              ),

              // ——— Blur ———
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                child: Container(
                  color: Colors.black.withValues(alpha: 0.3),
                ),
              ),

              // ——— Contenu principal ———
              SafeArea(
                child: Column(
                  children: [

                    // ——— Header ———
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: r.paddingH,
                        vertical: r.paddingV,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _CircleButton(
                            onTap: () => Navigator.pop(context),
                            child: const Icon(
                              Icons.arrow_back_ios_new,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                          Column(
                            children: [
                              const Text(
                                'En lecture',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              if (track.genre != null)
                                Container(
                                  margin: const EdgeInsets.only(top: 4),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: ciOrange.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    track.genre!,
                                    style: const TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w600,
                                      color: ciOrange,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          _CircleButton(
                            onTap: () => _openQueue(context),
                            child: const Icon(
                              Icons.queue_music_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ——— Contenu scrollable ———
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [

                            SizedBox(height: r.gap),

                            // ——— Pochette ———
                            RotatingCover(
                              track: track,
                              isPlaying: player.state.isPlaying,
                              size: r.coverSizeFull,
                            ),

                            SizedBox(height: r.gapLarge),

                            // ——— Titre et artiste ———
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: r.gapLarge),
                              child: Column(
                                children: [
                                  Text(
                                    track.title,
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: r.isSmall ? 20 : 24,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    track.artist,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: r.bodySize,
                                      color: Colors.white.withValues(alpha: 0.6),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 12),

                            // ——— Visualiseur ———
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.6,
                              height: 32,
                              child: VisualizerBars(
                                frequencyData: player.state.frequencyData.isEmpty
                                    ? List.filled(20, 0.05)
                                    : player.state.frequencyData,
                                height: 32,
                                count: 20,
                                isPlaying: player.state.isPlaying,
                              ),
                            ),

                            const SizedBox(height: 16),

                            // ——— Barre de progression ———
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: r.paddingH),
                              child: Column(
                                children: [
                                  SliderTheme(
                                    data: SliderThemeData(
                                      trackHeight: 3,
                                      thumbShape: const RoundSliderThumbShape(
                                        enabledThumbRadius: 7,
                                      ),
                                      overlayShape: const RoundSliderOverlayShape(
                                        overlayRadius: 16,
                                      ),
                                      activeTrackColor: ciOrange,
                                      inactiveTrackColor: Colors.white.withValues(alpha: 0.15),
                                      thumbColor: ciOrange,
                                      overlayColor: ciOrange.withValues(alpha: 0.2),
                                    ),
                                    child: Slider(
                                      value: player.state.progress.clamp(0.0, 1.0),
                                      onChanged: (v) => player.seekToProgress(v),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: r.gap * 0.5),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          _formatDuration(player.state.currentTime),
                                          style: TextStyle(
                                            fontSize: r.tinySize + 1,
                                            color: Colors.white.withValues(alpha: 0.6),
                                          ),
                                        ),
                                        Text(
                                          _formatRemaining(
                                            player.state.currentTime,
                                            player.state.totalDuration,
                                          ),
                                          style: TextStyle(
                                            fontSize: r.tinySize + 1,
                                            color: Colors.white.withValues(alpha: 0.6),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 20),

                            // ——— Contrôles principaux ———
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: r.paddingH),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [

                                  // Shuffle
                                  IconButton(
                                    onPressed: () => player.toggleShuffle(),
                                    icon: Icon(
                                      Icons.shuffle,
                                      color: player.state.shuffle
                                          ? ciOrange
                                          : Colors.white.withValues(alpha: 0.5),
                                      size: r.isSmall ? 20 : 22,
                                    ),
                                  ),

                                  // Précédent
                                  _ControlButton(
                                    onTap: () => player.skipToPrevious(),
                                    child: Icon(
                                      Icons.skip_previous_rounded,
                                      color: Colors.white,
                                      size: r.isSmall ? 28 : 32,
                                    ),
                                  ),

                                  // Play / Pause
                                  GestureDetector(
                                    onTap: () => player.state.isLoading
                                        ? null
                                        : player.togglePlayPause(),
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      width: r.isSmall ? 60 : 68,
                                      height: r.isSmall ? 60 : 68,
                                      decoration: BoxDecoration(
                                        color: ciOrange,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: ciOrange.withValues(alpha: 0.4),
                                            blurRadius: 20,
                                            spreadRadius: 4,
                                          ),
                                        ],
                                      ),
                                      child: player.state.isLoading
                                          ? const Padding(
                                              padding: EdgeInsets.all(16),
                                              child: CircularProgressIndicator(
                                                color: Colors.black,
                                                strokeWidth: 3,
                                              ),
                                            )
                                          : Icon(
                                              player.state.isPlaying
                                                  ? Icons.pause_rounded
                                                  : Icons.play_arrow_rounded,
                                              color: Colors.black,
                                              size: r.isSmall ? 30 : 36,
                                            ),
                                    ),
                                  ),

                                  // Suivant
                                  _ControlButton(
                                    onTap: () => player.skipToNext(),
                                    child: Icon(
                                      Icons.skip_next_rounded,
                                      color: Colors.white,
                                      size: r.isSmall ? 28 : 32,
                                    ),
                                  ),

                                  // Repeat
                                  IconButton(
                                    onPressed: () => player.cycleRepeatMode(),
                                    icon: Icon(
                                      player.state.repeatMode == ps.RepeatMode.one
                                          ? Icons.repeat_one
                                          : Icons.repeat,
                                      color: player.state.repeatMode != ps.RepeatMode.none
                                          ? ciOrange
                                          : Colors.white.withValues(alpha: 0.5),
                                      size: r.isSmall ? 20 : 22,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 24),

                            // ——— Contrôle volume ———
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: r.paddingH + 8),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.volume_down,
                                    color: Colors.white.withValues(alpha: 0.5),
                                    size: 18,
                                  ),
                                  Expanded(
                                    child: SliderTheme(
                                      data: SliderThemeData(
                                        trackHeight: 2,
                                        thumbShape: const RoundSliderThumbShape(
                                          enabledThumbRadius: 5,
                                        ),
                                        overlayShape: const RoundSliderOverlayShape(
                                          overlayRadius: 12,
                                        ),
                                        activeTrackColor: Colors.white.withValues(alpha: 0.6),
                                        inactiveTrackColor: Colors.white.withValues(alpha: 0.1),
                                        thumbColor: Colors.white,
                                        overlayColor: Colors.white.withValues(alpha: 0.1),
                                      ),
                                      child: Slider(
                                        value: player.state.volume.clamp(0.0, 1.0),
                                        onChanged: (v) => player.setVolume(v),
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    Icons.volume_up,
                                    color: Colors.white.withValues(alpha: 0.5),
                                    size: 18,
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 16),

                            // ——— Infos morceau ———
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: r.paddingH),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.05),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    _TrackInfo(
                                      icon: Icons.timer_outlined,
                                      label: 'Durée',
                                      value: track.formattedDuration,
                                    ),
                                    Container(
                                      width: 1,
                                      height: 24,
                                      color: Colors.white.withValues(alpha: 0.1),
                                    ),
                                    _TrackInfo(
                                      icon: Icons.category_outlined,
                                      label: 'Genre',
                                      value: track.genre ?? 'Inconnu',
                                    ),
                                    Container(
                                      width: 1,
                                      height: 24,
                                      color: Colors.white.withValues(alpha: 0.1),
                                    ),
                                    _TrackInfo(
                                      icon: Icons.graphic_eq,
                                      label: 'Qualité',
                                      value: 'MP3',
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _openQueue(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const QueuePage(),
    );
  }
}

// ——— Bouton rond header ———
class _CircleButton extends StatelessWidget {
  final VoidCallback onTap;
  final Widget child;

  const _CircleButton({required this.onTap, required this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.1),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Center(child: child),
      ),
    );
  }
}

// ——— Bouton contrôle (prev/next) ———
class _ControlButton extends StatelessWidget {
  final VoidCallback onTap;
  final Widget child;

  const _ControlButton({required this.onTap, required this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.08),
        ),
        child: Center(child: child),
      ),
    );
  }
}

// ——— Info morceau en bas ———
class _TrackInfo extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _TrackInfo({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: ciOrange, size: 14),
        const SizedBox(height: 3),
        Text(
          value,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            color: Colors.white.withValues(alpha: 0.4),
          ),
        ),
      ],
    );
  }
}
