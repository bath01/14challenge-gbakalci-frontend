import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/player_provider.dart';
import '../../core/providers/playlist_provider.dart';
import '../../shared/theme.dart';
import '../../shared/widgets/track_row.dart';
import '../../shared/widgets/cover_art.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _sortBy = 'title'; // title, artist, duration

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<PlayerProvider, PlaylistProvider>(
      builder: (context, player, playlist, _) {
        var tracks = playlist.searchTracks(_searchQuery);

        // Tri
        switch (_sortBy) {
          case 'artist':
            tracks = List.from(tracks)..sort((a, b) => a.artist.compareTo(b.artist));
            break;
          case 'duration':
            tracks = List.from(tracks)..sort((a, b) => b.duration.compareTo(a.duration));
            break;
          default:
            tracks = List.from(tracks)..sort((a, b) => a.title.compareTo(b.title));
        }

        // Stats
        final totalSec = playlist.allTracks.fold<int>(0, (s, t) => s + t.duration);
        final totalMin = totalSec ~/ 60;
        final artists = playlist.uniqueArtists;

        // Top 3 artistes par nombre de morceaux
        final artistCounts = <String, int>{};
        for (final t in playlist.allTracks) {
          artistCounts[t.artist] = (artistCounts[t.artist] ?? 0) + 1;
        }
        final topArtists = artistCounts.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ——— Header ———
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Text(
                'Bibliothèque',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: textP,
                  letterSpacing: -0.5,
                ),
              ),
            ),

            // ——— Stats rapides ———
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: Row(
                children: [
                  _QuickChip(
                    icon: Icons.music_note,
                    text: '${playlist.trackCount} titres',
                  ),
                  const SizedBox(width: 8),
                  _QuickChip(
                    icon: Icons.person,
                    text: '${artists.length} artistes',
                  ),
                  const SizedBox(width: 8),
                  _QuickChip(
                    icon: Icons.timer_outlined,
                    text: '${totalMin}min',
                  ),
                ],
              ),
            ),

            // ——— Top artistes ———
            if (topArtists.isNotEmpty)
              SizedBox(
                height: 80,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  itemCount: topArtists.length > 6 ? 6 : topArtists.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (_, i) {
                    final artist = topArtists[i];
                    // Trouve un morceau de cet artiste pour la pochette
                    final artistTrack = playlist.allTracks
                        .firstWhere((t) => t.artist == artist.key);
                    return GestureDetector(
                      onTap: () {
                        _searchController.text = artist.key;
                        setState(() => _searchQuery = artist.key);
                      },
                      child: Container(
                        width: 110,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: card,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: border),
                        ),
                        child: Row(
                          children: [
                            CoverArt(
                              track: artistTrack,
                              size: 40,
                              radius: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    artist.key,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: textP,
                                    ),
                                  ),
                                  Text(
                                    '${artist.value} titre${artist.value > 1 ? 's' : ''}',
                                    style: const TextStyle(
                                      fontSize: 9,
                                      color: textDim,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

            // ——— Barre de recherche + tri ———
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: card,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: border),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (v) => setState(() => _searchQuery = v),
                        style: const TextStyle(color: textP, fontSize: 13),
                        decoration: InputDecoration(
                          hintText: 'Rechercher...',
                          hintStyle: const TextStyle(color: textDim, fontSize: 13),
                          prefixIcon: const Icon(Icons.search, color: textDim, size: 18),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? GestureDetector(
                                  onTap: () {
                                    _searchController.clear();
                                    setState(() => _searchQuery = '');
                                  },
                                  child: const Icon(Icons.close, color: textDim, size: 16),
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Boutons de tri
                  Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: card,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: border),
                    ),
                    child: Row(
                      children: [
                        _SortButton(
                          icon: Icons.sort_by_alpha,
                          isActive: _sortBy == 'title',
                          onTap: () => setState(() => _sortBy = 'title'),
                        ),
                        _SortButton(
                          icon: Icons.person_outline,
                          isActive: _sortBy == 'artist',
                          onTap: () => setState(() => _sortBy = 'artist'),
                        ),
                        _SortButton(
                          icon: Icons.timer_outlined,
                          isActive: _sortBy == 'duration',
                          onTap: () => setState(() => _sortBy = 'duration'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ——— Compteur résultats ———
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
              child: Text(
                _searchQuery.isNotEmpty
                    ? '${tracks.length} résultat${tracks.length > 1 ? 's' : ''} pour "$_searchQuery"'
                    : '${tracks.length} morceau${tracks.length > 1 ? 'x' : ''}',
                style: const TextStyle(fontSize: 11, color: textDim),
              ),
            ),

            // ——— Liste ———
            Expanded(
              child: playlist.isLoadingTracks
                  ? const Center(
                      child: CircularProgressIndicator(color: ciOrange),
                    )
                  : tracks.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.search_off, color: textDim, size: 48),
                              const SizedBox(height: 12),
                              Text(
                                'Aucun résultat pour "$_searchQuery"',
                                style: const TextStyle(color: textS),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.only(bottom: 80),
                          itemCount: tracks.length,
                          itemBuilder: (_, i) => TrackRow(
                            track: tracks[i],
                            onTap: () => player.playTrack(tracks[i]),
                          ),
                        ),
            ),
          ],
        );
      },
    );
  }
}

// ——— Chip rapide pour les stats ———
class _QuickChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _QuickChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: ciOrange, size: 12),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: textS,
            ),
          ),
        ],
      ),
    );
  }
}

// ——— Bouton de tri ———
class _SortButton extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _SortButton({
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 40,
        decoration: BoxDecoration(
          color: isActive ? ciOrange.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          size: 16,
          color: isActive ? ciOrange : textDim,
        ),
      ),
    );
  }
}
