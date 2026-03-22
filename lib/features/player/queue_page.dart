import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/player_provider.dart';
import '../../core/providers/playlist_provider.dart';
import '../../shared/theme.dart';
import '../../shared/responsive.dart';
import '../../shared/widgets/cover_art.dart';
import '../../shared/widgets/track_row.dart';

class QueuePage extends StatelessWidget {
  const QueuePage({super.key});

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);

    return Consumer2<PlayerProvider, PlaylistProvider>(
      builder: (context, player, playlist, _) {

        // Liste des morceaux dans la file d'attente
        // Si une playlist est active → ses morceaux
        // Sinon → tous les morceaux de la bibliothèque
        final queue = player.state.currentPlaylist?.tracks
            ?? playlist.allTracks;

        final currentTrack = player.state.currentTrack;
        final currentIndex = player.state.currentIndex;

        return Container(
          // Hauteur = 75% de l'écran
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: BoxDecoration(
            color: surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(24),
            ),
            border: Border.all(color: border.withOpacity(0.5)),
          ),
          child: Column(
            children: [

              // ——— Handle de la modal ———
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // ——— Header ———
              Padding(
                padding: EdgeInsets.fromLTRB(
                  r.paddingH, r.paddingV, r.paddingH, 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'File d\'attente',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: textP,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${queue.length} morceau${queue.length > 1 ? 'x' : ''}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: textS,
                          ),
                        ),
                      ],
                    ),

                    // Bouton fermer
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.08),
                        ),
                        child: const Icon(
                          Icons.close,
                          color: textS,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // ——— Morceau en cours ———
              if (currentTrack != null) ...[
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: r.paddingH),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'EN COURS',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: ciOrange,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: EdgeInsets.all(r.paddingV),
                        decoration: BoxDecoration(
                          color: ciOrange.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: ciOrange.withOpacity(0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            CoverArt(
                              track: currentTrack,
                              size: 44,
                              radius: 10,
                              isPlaying: player.state.isPlaying,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    currentTrack.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: ciOrange,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    currentTrack.artist,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: textS,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Indicateur de lecture animé
                            _PlayingIndicator(
                              isPlaying: player.state.isPlaying,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Séparateur
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: r.paddingH),
                  child: Row(
                    children: [
                      const Text(
                        'SUIVANT',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: textDim,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Divider(
                          color: border,
                          height: 1,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),
              ],

              // ——— Liste des morceaux suivants ———
              Expanded(
                child: queue.isEmpty
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.queue_music,
                        color: textDim,
                        size: 48,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'File d\'attente vide',
                        style: TextStyle(color: textS),
                      ),
                    ],
                  ),
                )
                    : ReorderableListView.builder(
                  // ReorderableListView = liste drag & drop
                  padding: EdgeInsets.only(
                    bottom: r.gapLarge,
                    left: r.paddingH * 0.5,
                    right: r.paddingH * 0.5,
                  ),
                  // Filtre les morceaux déjà passés
                  itemCount: queue
                      .skip(currentIndex)
                      .length,
                  itemBuilder: (_, i) {
                    final trackIndex = currentIndex + i;
                    final track = queue[trackIndex];
                    final isActive = track.id == currentTrack?.id;

                    // Chaque item doit avoir une key unique
                    // pour que le ReorderableListView fonctionne
                    return isActive
                        ? const SizedBox.shrink(
                      key: ValueKey('active'),
                    )
                        : KeyedSubtree(
                      key: ValueKey(track.id),
                      child: TrackRow(
                        track: track,
                        onTap: () {
                          // Joue le morceau depuis son index
                          if (player.state.currentPlaylist != null) {
                            player.playPlaylist(
                              player.state.currentPlaylist!,
                              startIndex: trackIndex,
                            );
                          } else {
                            player.playTrack(track);
                          }
                          Navigator.pop(context);
                        },
                      ),
                    );
                  },
                  // Appelé quand l'utilisateur réordonne
                  onReorder: (oldIndex, newIndex) {
                    if (player.state.currentPlaylist != null) {
                      final adjustedOld = currentIndex + oldIndex;
                      final adjustedNew = currentIndex + newIndex;
                      context.read<PlaylistProvider>().reorderTrack(
                        playlistId: player.state.currentPlaylist!.id,
                        oldIndex: adjustedOld,
                        newIndex: adjustedNew,
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ——— Indicateur de lecture animé (3 barres) ———
class _PlayingIndicator extends StatefulWidget {
  final bool isPlaying;

  const _PlayingIndicator({required this.isPlaying});

  @override
  State<_PlayingIndicator> createState() => _PlayingIndicatorState();
}

class _PlayingIndicatorState extends State<_PlayingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    // 3 animations décalées pour les 3 barres
    _animations = List.generate(3, (i) {
      return Tween<double>(begin: 0.2, end: 1.0).animate(
        CurvedAnimation(
          parent: _controller,
          // Interval = chaque barre commence à un moment différent
          curve: Interval(
            i * 0.2,         // début
            0.6 + i * 0.2,   // fin
            curve: Curves.easeInOut,
          ),
        ),
      );
    });

    if (widget.isPlaying) _controller.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(_PlayingIndicator old) {
    super.didUpdateWidget(old);
    if (widget.isPlaying != old.isPlaying) {
      if (widget.isPlaying) {
        _controller.repeat(reverse: true);
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20,
      height: 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(3, (i) {
          return AnimatedBuilder(
            animation: _animations[i],
            builder: (_, __) => Container(
              width: 3,
              height: 20 * _animations[i].value,
              decoration: BoxDecoration(
                color: ciOrange,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }
}