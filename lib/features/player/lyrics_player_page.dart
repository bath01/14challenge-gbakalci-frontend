import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/PlayerState.dart';
import '../../core/providers/player_provider.dart';
import '../../shared/theme.dart';
import '../../shared/responsive.dart';
import '../../shared/widgets/cover_art.dart';
import '../../shared/widgets/rotating_cover.dart';
import 'queue_page.dart';

class LyricsPlayerPage extends StatelessWidget {
  const LyricsPlayerPage({super.key});

  // Formate la durée en mm:ss
  String _formatDuration(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  // Formate le temps restant en -mm:ss
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
      // Fond transparent pour voir le blur derrière
      backgroundColor: Colors.transparent,
      body: Consumer<PlayerProvider>(
        builder: (context, player, _) {
          final track = player.state.currentTrack;
          if (track == null) {
            Navigator.pop(context);
            return const SizedBox.shrink();
          }

          // Couleur dominante basée sur le gradient de l'artiste
          final gradient = CoverArt.getGradient(track.artist);
          final dominantColor = gradient.colors.first;

          return Stack(
            children: [

              // ——— Fond flouté avec couleur dominante ———
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      dominantColor.withOpacity(0.8),
                      darkBg.withOpacity(0.95),
                      darkBg,
                    ],
                    stops: const [0.0, 0.4, 1.0],
                  ),
                ),
              ),

              // ——— Effet blur sur le fond ———
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                child: Container(
                  color: Colors.black.withOpacity(0.3),
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

                          // Bouton retour
                          _CircleButton(
                            onTap: () => Navigator.pop(context),
                            child: const Icon(
                              Icons.arrow_back_ios_new,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),

                          // Titre de la page
                          const Text(
                            'Now Playing',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),

                          // Bouton favori
                          _CircleButton(
                            onTap: () {},
                            child: const Icon(
                              Icons.favorite_border,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: r.gapLarge),

                    // ——— Pochette circulaire animée ———
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
                            maxLines: 1,
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
                              color: Colors.white.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: r.gapLarge),

                    // ——— Barre de progression ———
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: r.paddingH),
                      child: Column(
                        children: [

                          // Slider
                          SliderTheme(
                            data: SliderThemeData(
                              trackHeight: 3,
                              thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 7,
                              ),
                              overlayShape: const RoundSliderOverlayShape(
                                overlayRadius: 16,
                              ),
                              // Couleur verte comme dans la maquette
                              activeTrackColor: const Color(0xFFB5E550),
                              inactiveTrackColor: Colors.white.withOpacity(0.2),
                              thumbColor: const Color(0xFFB5E550),
                              overlayColor: const Color(0xFFB5E550).withOpacity(0.2),
                            ),
                            child: Slider(
                              value: player.state.progress.clamp(0.0, 1.0),
                              onChanged: (v) => player.seekToProgress(v),
                            ),
                          ),

                          // Temps actuel et temps restant
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: r.gap * 0.5,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _formatDuration(player.state.currentTime),
                                  style: TextStyle(
                                    fontSize: r.tinySize + 1,
                                    color: Colors.white.withOpacity(0.6),
                                  ),
                                ),
                                Text(
                                  // Temps restant négatif comme dans la maquette
                                  _formatRemaining(
                                    player.state.currentTime,
                                    player.state.totalDuration,
                                  ),
                                  style: TextStyle(
                                    fontSize: r.tinySize + 1,
                                    color: Colors.white.withOpacity(0.6),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: r.gapLarge),

                    // ——— Contrôles ———
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
                                  ? const Color(0xFFB5E550)
                                  : Colors.white.withOpacity(0.5),
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

                          // Play / Pause — bouton principal
                          GestureDetector(
                            onTap: () => player.togglePlayPause(),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: r.isSmall ? 60 : 68,
                              height: r.isSmall ? 60 : 68,
                              decoration: BoxDecoration(
                                // Vert lime comme dans la maquette
                                color: const Color(0xFFB5E550),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFB5E550)
                                        .withOpacity(0.4),
                                    blurRadius: 20,
                                    spreadRadius: 4,
                                  ),
                                ],
                              ),
                              child: Icon(
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

                          // Queue / File d'attente
                          IconButton(
                            onPressed: () => _openQueue(context),
                            icon: Icon(
                              Icons.queue_music_rounded,
                              color: Colors.white.withOpacity(0.5),
                              size: r.isSmall ? 20 : 22,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: r.gap),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Ouvre la page file d'attente en modal depuis le bas
  void _openQueue(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      // true = la modal peut prendre plus de 50% de l'écran
      builder: (_) => const QueuePage(),
    );
  }
}

// ——— Bouton rond avec fond semi-transparent ———
class _CircleButton extends StatelessWidget {
  final VoidCallback onTap;
  final Widget child;

  const _CircleButton({
    required this.onTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.1),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
          ),
        ),
        child: Center(child: child),
      ),
    );
  }
}

// ——— Bouton de contrôle (précédent / suivant) ———
class _ControlButton extends StatelessWidget {
  final VoidCallback onTap;
  final Widget child;

  const _ControlButton({
    required this.onTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.08),
        ),
        child: Center(child: child),
      ),
    );
  }
}