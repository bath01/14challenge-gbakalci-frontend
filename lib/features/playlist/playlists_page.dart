import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/playlist.dart';
import '../../core/models/track.dart';
import '../../core/providers/player_provider.dart';
import '../../core/providers/playlist_provider.dart';
import '../../shared/theme.dart';
import '../../shared/responsive.dart';
import '../../shared/widgets/cover_art.dart';
import '../../shared/widgets/track_row.dart';

class PlaylistsPage extends StatelessWidget {
  const PlaylistsPage({super.key});

  // ——— Dialog création playlist ———
  void _showCreateDialog(BuildContext context) {
    final controller = TextEditingController();
    final playlistProvider = context.read<PlaylistProvider>();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: border),
        ),
        title: const Text(
          'Nouvelle playlist',
          style: TextStyle(
            color: textP,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: textP),
          decoration: InputDecoration(
            hintText: 'Nom de la playlist',
            hintStyle: const TextStyle(color: textDim),
            filled: true,
            fillColor: surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: ciOrange),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Annuler',
              style: TextStyle(color: textS),
            ),
          ),
          GestureDetector(
            onTap: () async {
              final name = controller.text.trim();
              if (name.isEmpty) return;
              Navigator.pop(context);
              await playlistProvider.createPlaylist(name: name);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: ciOrange,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Créer',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);

    return Consumer<PlaylistProvider>(
      builder: (context, playlist, _) {
        // Stats playlists
        final totalTracksInPlaylists = playlist.playlists
            .fold<int>(0, (sum, p) => sum + p.trackCount);
        final totalDurationSec = playlist.playlists
            .fold<int>(0, (sum, p) => sum + p.totalDuration);
        final totalDurationMin = totalDurationSec ~/ 60;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ——— Header ———
            Padding(
              padding: EdgeInsets.fromLTRB(r.paddingH, 8, r.paddingH, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Playlists',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: textP,
                      letterSpacing: -0.5,
                    ),
                  ),

                  // ——— Bouton créer ———
                  GestureDetector(
                    onTap: () => _showCreateDialog(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: ciOrange,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.add, color: Colors.white, size: 14),
                          SizedBox(width: 4),
                          Text(
                            'Nouvelle',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ——— Stats playlists ———
            if (playlist.playlists.isNotEmpty)
              Padding(
                padding: EdgeInsets.fromLTRB(r.paddingH, 0, r.paddingH, 12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: card,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: border),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _PlaylistStat(
                        icon: Icons.queue_music,
                        value: '${playlist.playlists.length}',
                        label: 'Playlists',
                        color: ciOrange,
                      ),
                      Container(width: 1, height: 24, color: border),
                      _PlaylistStat(
                        icon: Icons.music_note,
                        value: '$totalTracksInPlaylists',
                        label: 'Morceaux',
                        color: ciGreen,
                      ),
                      Container(width: 1, height: 24, color: border),
                      _PlaylistStat(
                        icon: Icons.timer_outlined,
                        value: '${totalDurationMin}min',
                        label: 'Durée totale',
                        color: ciOrange,
                      ),
                    ],
                  ),
                ),
              ),

            Expanded(
              child: playlist.isLoadingPlaylists
                  ? const Center(
                child: CircularProgressIndicator(color: ciOrange),
              )
                  : playlist.playlists.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.queue_music,
                        color: textDim, size: 48),
                    const SizedBox(height: 12),
                    const Text(
                      'Aucune playlist',
                      style: TextStyle(color: textS, fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Crée ta première playlist pour organiser tes morceaux',
                      style: TextStyle(color: textDim, fontSize: 11),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () => _showCreateDialog(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: ciOrange,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'Créer une playlist',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
                  : ListView.builder(
                padding: EdgeInsets.fromLTRB(
                  r.paddingH, 0, r.paddingH, 80,
                ),
                itemCount: playlist.playlists.length,
                itemBuilder: (_, i) => _PlaylistCard(
                  playlist: playlist.playlists[i],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ——— Stat pour la page playlists ———
class _PlaylistStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _PlaylistStat({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 14),
        const SizedBox(height: 3),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 9, color: textDim),
        ),
      ],
    );
  }
}

// ——— Carte playlist ———
class _PlaylistCard extends StatefulWidget {
  final Playlist playlist;
  const _PlaylistCard({required this.playlist});

  @override
  State<_PlaylistCard> createState() => _PlaylistCardState();
}

class _PlaylistCardState extends State<_PlaylistCard> {
  bool _expanded = false;
  bool _isAddingTrack = false;

  // ——— Dialog ajout de morceau ———
  void _showAddTrackDialog(BuildContext context) {
    final playlistProvider = context.read<PlaylistProvider>();
    final allTracks = playlistProvider.allTracks;

    // Récupère la playlist à jour depuis le provider
    final freshPlaylist = playlistProvider.playlists
        .where((p) => p.id == widget.playlist.id)
        .firstOrNull ?? widget.playlist;

    // Filtre les morceaux qui ne sont pas déjà dans la playlist
    final availableTracks = allTracks.where((t) =>
    !freshPlaylist.tracks.any((pt) => pt.id == t.id)
    ).toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: BoxDecoration(
          color: surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          border: Border.all(color: border.withOpacity(0.5)),
        ),
        child: Column(
          children: [

            // Handle
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

            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Ajouter un morceau',
                        style: TextStyle(
                          color: textP,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        'À : ${widget.playlist.name}',
                        style: const TextStyle(
                          color: textS,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.08),
                      ),
                      child: const Icon(Icons.close, color: textS, size: 14),
                    ),
                  ),
                ],
              ),
            ),

            Divider(color: border, height: 1),

            // Liste des morceaux disponibles
            Expanded(
              child: availableTracks.isEmpty
                  ? const Center(
                child: Text(
                  'Tous les morceaux sont déjà dans cette playlist',
                  style: TextStyle(color: textS, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              )
                  : ListView.builder(
                padding: const EdgeInsets.only(bottom: 16),
                itemCount: availableTracks.length,
                itemBuilder: (_, i) {
                  final track = availableTracks[i];
                  return _AddTrackRow(
                    track: track,
                    onAdd: () async {
                      Navigator.pop(context);
                      setState(() => _isAddingTrack = true);
                      await playlistProvider.addTrackToPlaylist(
                        playlistId: widget.playlist.id,
                        track: track,
                      );
                      if (mounted) setState(() => _isAddingTrack = false);

                      // Notification de succès
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '${track.title} ajouté à ${widget.playlist.name}',
                            ),
                            backgroundColor: ciGreen,
                            duration: const Duration(seconds: 2),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ——— Dialog suppression morceau ———
  void _confirmRemoveTrack(BuildContext context, Track track) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: border),
        ),
        title: const Text(
          'Retirer le morceau ?',
          style: TextStyle(color: textP, fontSize: 15, fontWeight: FontWeight.w700),
        ),
        content: Text(
          '${track.title} sera retiré de ${widget.playlist.name}',
          style: const TextStyle(color: textS, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler', style: TextStyle(color: textS)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await context.read<PlaylistProvider>().removeTrackFromPlaylist(
                playlistId: widget.playlist.id,
                trackId: track.id,
              );
            },
            child: const Text(
              'Retirer',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<PlayerProvider, PlaylistProvider>(
      builder: (context, player, playlistProvider, _) {
        // Récupère la playlist à jour depuis le provider
        final currentPlaylist = playlistProvider.playlists
            .where((p) => p.id == widget.playlist.id)
            .firstOrNull ?? widget.playlist;

        return GestureDetector(
          onTap: () => setState(() => _expanded = !_expanded),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: border),
            ),
            child: Column(
              children: [

                // ——— En-tête ———
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              currentPlaylist.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: textP,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                '${currentPlaylist.trackCount} titre${currentPlaylist.trackCount > 1 ? 's' : ''}',
                                style: const TextStyle(
                                    fontSize: 10, color: textS),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                _expanded
                                    ? Icons.keyboard_arrow_up
                                    : Icons.keyboard_arrow_down,
                                color: textDim,
                                size: 18,
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      // Mini pochettes
                      Row(
                        children: [
                          ...currentPlaylist.tracks.take(4).map(
                                (t) => Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: CoverArt(track: t, size: 36, radius: 8),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            currentPlaylist.formattedTotalDuration,
                            style: const TextStyle(fontSize: 10, color: textDim),
                          ),
                          Row(
                            children: [

                              // ——— Bouton ajouter morceau ———
                              GestureDetector(
                                onTap: _isAddingTrack
                                    ? null
                                    : () => _showAddTrackDialog(context),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: ciGreen.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: _isAddingTrack
                                      ? const SizedBox(
                                          width: 50,
                                          height: 13,
                                          child: Center(
                                            child: SizedBox(
                                              width: 13,
                                              height: 13,
                                              child: CircularProgressIndicator(
                                                color: ciGreen,
                                                strokeWidth: 2,
                                              ),
                                            ),
                                          ),
                                        )
                                      : const Row(
                                          children: [
                                            Icon(Icons.add, color: ciGreen, size: 13),
                                            SizedBox(width: 3),
                                            Text(
                                              'Ajouter',
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w700,
                                                color: ciGreen,
                                              ),
                                            ),
                                          ],
                                        ),
                                ),
                              ),

                              const SizedBox(width: 8),

                              // ——— Bouton lire ———
                              GestureDetector(
                                onTap: () => player.playPlaylist(currentPlaylist),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: ciOrange.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Row(
                                    children: [
                                      Icon(Icons.play_arrow,
                                          color: ciOrange, size: 13),
                                      SizedBox(width: 3),
                                      Text(
                                        'Lire',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: ciOrange,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // ——— Morceaux expandables ———
                if (_expanded)
                  Column(
                    children: [
                      Divider(color: border, height: 1),
                      ...currentPlaylist.tracks.map(
                            (t) => Dismissible(
                          // Swipe gauche pour retirer
                          key: ValueKey(t.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 16),
                            color: Colors.red.withOpacity(0.2),
                            child: const Icon(Icons.delete_outline,
                                color: Colors.red, size: 20),
                          ),
                          confirmDismiss: (_) async {
                            _confirmRemoveTrack(context, t);
                            return false; // on gère manuellement
                          },
                          child: TrackRow(
                            track: t,
                            onTap: () {
                              final idx = currentPlaylist.tracks.indexOf(t);
                              player.playPlaylist(
                                currentPlaylist,
                                startIndex: idx,
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ——— Row pour ajouter un morceau ———
class _AddTrackRow extends StatelessWidget {
  final Track track;
  final VoidCallback onAdd;

  const _AddTrackRow({required this.track, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Row(
        children: [
          Expanded(
            child: TrackRow(track: track),
          ),
          GestureDetector(
            onTap: onAdd,
            child: Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: ciGreen.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, color: ciGreen, size: 16),
            ),
          ),
        ],
      ),
    );
  }
}