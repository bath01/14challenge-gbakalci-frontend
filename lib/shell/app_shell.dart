import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../features/library/home_page.dart';
import '../features/library/library_page.dart';
import '../features/library/about_page.dart';
import '../features/playlist/playlists_page.dart';
import '../features/player/widgets/mini_player.dart';
import '../shared/theme.dart';
import '../shared/responsive.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    LibraryPage(),
    PlaylistsPage(),
    AboutPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);

    return Scaffold(
      backgroundColor: darkBg,
      body: SafeArea(
        child: Column(
          children: [



            // ——— Logo ———
            Padding(
              padding: EdgeInsets.fromLTRB(
                r.paddingH, r.gap * 0.5, r.paddingH, r.gap * 0.5,
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: SizedBox(
                      width: 28,
                      height: 3,
                      child: Row(
                        children: [
                          Expanded(child: Container(color: ciOrange)),
                          Expanded(child: Container(color: Colors.white)),
                          Expanded(child: Container(color: ciGreen)),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: r.gap * 0.5),
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: r.titleSize,
                        fontWeight: FontWeight.w800,
                        color: textP,
                        letterSpacing: -0.5,
                      ),
                      children: const [
                        TextSpan(text: 'Gbakal'),
                        TextSpan(
                          text: 'CI',
                          style: TextStyle(color: ciOrange),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ——— Pages + Mini Player ———
            Expanded(
              child: Stack(
                children: [
                  _pages[_currentIndex],
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: const MiniPlayer(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // ——— Bottom Nav ———
      bottomNavigationBar: Container(
        height: r.bottomNavHeight,
        decoration: BoxDecoration(
          color: const Color(0xFF0D0D12).withOpacity(0.97),
          border: Border(top: BorderSide(color: border)),
        ),
        child: Row(
          children: [
            _buildNavItem(r, '🏠', 'Accueil', 0),
            _buildNavItem(r, '🎵', 'Biblio', 1),
            _buildNavItem(r, '📋', 'Playlists', 2),
            _buildNavItem(r, 'ℹ️', 'À propos', 3),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(Responsive r, String emoji, String label, int index) {
    final isSelected = _currentIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _currentIndex = index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              emoji,
              style: TextStyle(
                fontSize: r.isSmall ? 16 : 18,
                color: Colors.white.withOpacity(isSelected ? 1.0 : 0.4),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: r.tinySize,
                fontWeight: FontWeight.w600,
                color: isSelected ? ciOrange : textDim,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
