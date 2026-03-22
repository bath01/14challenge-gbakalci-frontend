import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/player_provider.dart';
import '../../core/providers/playlist_provider.dart';
import '../../shared/theme.dart';
import '../../shared/widgets/track_row.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<PlayerProvider, PlaylistProvider>(
      builder: (context, player, playlist, _) {
        final tracks = playlist.searchTracks(_searchQuery);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ——— Header ———
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 12),
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

            // ——— Barre de recherche ———
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Container(
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
                    hintText: 'Rechercher un titre, artiste...',
                    hintStyle: const TextStyle(color: textDim, fontSize: 13),
                    prefixIcon: const Icon(Icons.search, color: textDim, size: 20),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? GestureDetector(
                      onTap: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                      child: const Icon(Icons.close,
                          color: textDim, size: 18),
                    )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),

            // ——— Compteur ———
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(
                '${tracks.length} morceau${tracks.length > 1 ? 'x' : ''}',
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
                    const Icon(Icons.search_off,
                        color: textDim, size: 48),
                    const SizedBox(height: 12),
                    Text(
                      'Aucun résultat pour "$_searchQuery"',
                      style: const TextStyle(color: textS),
                    ),
                  ],
                ),
              )
                  : ListView.builder(
                padding: const EdgeInsets.only(bottom: 8),
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