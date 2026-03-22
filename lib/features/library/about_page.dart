import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/playlist_provider.dart';
import '../../shared/theme.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  static String _getInitials(String name) {
    return name.split(' ').take(2)
        .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
        .join();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PlaylistProvider>(
      builder: (context, playlist, _) {
        final artists = playlist.uniqueArtists;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [

            // ——— Header ———
            const Text(
              'À propos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: textP,
                letterSpacing: -0.5,
              ),
            ),

            const SizedBox(height: 16),

            // ——— Présentation ———
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Drapeau CI
                  Container(
                    width: 48,
                    height: 3,
                    margin: const EdgeInsets.only(bottom: 16),
                    clipBehavior: Clip.hardEdge,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: Row(
                      children: [
                        Expanded(child: Container(color: ciOrange)),
                        Expanded(child: Container(color: Colors.white)),
                        Expanded(child: Container(color: ciGreen)),
                      ],
                    ),
                  ),
                  const Text(
                    'GbakalCI',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: textP,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Jour 7 du Challenge 14-14-14. Player de musique ivoirienne — écouter sans connexion ni inscription.',
                    style: TextStyle(
                      fontSize: 12,
                      color: textS,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ——— Stats ———
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.8,
              children: [
                _StatCard(
                    value: '${playlist.trackCount}',
                    label: 'Titres',
                    color: ciOrange),
                _StatCard(
                    value: '${artists.length}',
                    label: 'Artistes',
                    color: ciGreen),
                _StatCard(
                    value: '${playlist.playlistCount}',
                    label: 'Playlists',
                    color: ciGreen),
                _StatCard(
                    value: '4',
                    label: 'Genres',
                    color: ciOrange),
              ],
            ),

            const SizedBox(height: 16),

            // ——— Équipe ———
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "L'ÉQUIPE",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: textDim,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 14),
                  ...[
                    ['Bath Dorgeles', 'Chef de projet & Front'],
                    ['Oclin Marcel C.', 'Dev Front-end (Flutter)'],
                    ['Rayane Irie', 'Back-end (.NET Core)'],
                  ].asMap().entries.map((e) {
                    final i = e.key;
                    final m = e.value;
                    return Padding(
                      padding: EdgeInsets.only(bottom: i < 2 ? 12 : 0),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [ciOrange, ciGreen],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                _getInitials(m[0]),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(m[0],
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: textP,
                                  )),
                              Text(m[1],
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: textS,
                                  )),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ——— Footer ———
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: border),
              ),
              child: Column(
                children: [
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: const TextStyle(
                          fontSize: 12, color: textS),
                      children: [
                        const TextSpan(text: 'Open Source · '),
                        TextSpan(
                          text: '225os.com',
                          style: const TextStyle(
                            color: ciOrange,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const TextSpan(text: ' & '),
                        TextSpan(
                          text: 'GitHub',
                          style: const TextStyle(
                            color: ciGreen,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    '14-14-14 // JOUR 7 // MARS 2026',
                    style: TextStyle(
                      fontSize: 10,
                      color: textDim,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
          ],
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _StatCard({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: textS),
          ),
        ],
      ),
    );
  }
}