import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/track.dart';
import '../../core/providers/player_provider.dart';
import '../../core/providers/playlist_provider.dart';
import '../../shared/theme.dart';
import '../../shared/responsive.dart';
import '../../shared/widgets/cover_art.dart';
import '../../shared/widgets/track_row.dart';
import '../../shared/widgets/visualizer_bars.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _selectedGenre = 'Tous';

  List<Track> _filterTracks(List<Track> tracks) {
    if (_selectedGenre == 'Tous') return tracks;
    return tracks.where((t) => t.genre == _selectedGenre).toList();
  }

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);

    return Consumer2<PlayerProvider, PlaylistProvider>(
      builder: (context, player, playlist, _) {
        final track = player.state.currentTrack;
        final filtered = _filterTracks(playlist.allTracks);

        // ——— Catégories dynamiques depuis l'API ———
        final categories = [
          'Tous',
          ...playlist.categories.map((c) => c.name),
        ];

        return Column(
          children: [

            // ——— Now Playing Banner ———
            if (track != null)
              Container(
                margin: EdgeInsets.fromLTRB(
                  r.paddingH, 0, r.paddingH, r.gap,
                ),
                padding: EdgeInsets.all(r.paddingH),
                decoration: BoxDecoration(
                  color: card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: border),
                ),
                child: Row(
                  children: [
                    CoverArt(
                      track: track,
                      size: r.coverSizeMedium,
                      radius: 12,
                      isPlaying: player.state.isPlaying,
                    ),

                    SizedBox(width: r.gap),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              SizedBox(
                                width: r.isSmall ? 36 : 50,
                                child: VisualizerBars(
                                  frequencyData: player.state.frequencyData.isEmpty
                                      ? List.filled(5, 0.05)
                                      : player.state.frequencyData.take(5).toList(),
                                  height: r.isSmall ? 12 : 16,
                                  count: 5,
                                  isPlaying: player.state.isPlaying,
                                ),
                              ),
                              SizedBox(width: r.gap * 0.5),
                              Text(
                                'EN LECTURE',
                                style: TextStyle(
                                  fontSize: r.tinySize,
                                  fontWeight: FontWeight.w600,
                                  color: ciOrange,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            track.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: r.bodySize + 1,
                              fontWeight: FontWeight.w700,
                              color: textP,
                            ),
                          ),
                          Text(
                            track.artist,
                            style: TextStyle(
                              fontSize: r.smallSize,
                              color: textS,
                            ),
                          ),
                        ],
                      ),
                    ),

                    GestureDetector(
                      onTap: () => player.togglePlayPause(),
                      child: Container(
                        width: r.isSmall ? 34 : 40,
                        height: r.isSmall ? 34 : 40,
                        decoration: const BoxDecoration(
                          color: ciOrange,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          player.state.isPlaying
                              ? Icons.pause
                              : Icons.play_arrow,
                          color: Colors.white,
                          size: r.isSmall ? 18 : 22,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // ——— Filtres catégories ———
            if (playlist.isLoadingCategories)
              SizedBox(
                height: r.isSmall ? 32 : 36,
                child: const Center(
                  child: CircularProgressIndicator(
                    color: ciOrange,
                    strokeWidth: 2,
                  ),
                ),
              )
            else
              SizedBox(
                height: r.isSmall ? 32 : 36,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: r.paddingH),
                  itemCount: categories.length,
                  separatorBuilder: (_, __) => SizedBox(width: r.gap * 0.5),
                  itemBuilder: (_, i) {
                    final g = categories[i];
                    final isSelected = g == _selectedGenre;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedGenre = g),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: EdgeInsets.symmetric(
                          horizontal: r.isSmall ? 10 : 14,
                          vertical: r.isSmall ? 4 : 6,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected ? ciOrange : card,
                          borderRadius: BorderRadius.circular(20),
                          border: isSelected
                              ? null
                              : Border.all(color: border),
                        ),
                        child: Center(
                          child: Text(
                            g,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: r.isSmall ? 10 : 11,
                              fontWeight: FontWeight.w700,
                              color: isSelected ? Colors.white : textS,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

            SizedBox(height: r.gap),

            // ——— Liste des morceaux ———
            Expanded(
              child: playlist.isLoadingTracks
                  ? const Center(
                child: CircularProgressIndicator(color: ciOrange),
              )
                  : filtered.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.music_off,
                      color: textDim,
                      size: r.isSmall ? 36 : 48,
                    ),
                    SizedBox(height: r.gap),
                    Text(
                      'Aucun morceau',
                      style: TextStyle(
                        color: textS,
                        fontSize: r.bodySize,
                      ),
                    ),
                  ],
                ),
              )
                  : ListView.builder(
                padding: const EdgeInsets.only(bottom: 80),
                itemCount: filtered.length,
                itemBuilder: (_, i) => TrackRow(
                  track: filtered[i],
                  onTap: () => player.playTrack(filtered[i]),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}