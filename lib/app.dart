import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/providers/playlist_provider.dart';
import 'shared/theme.dart';
import 'shell/app_shell.dart';

class MusicApp extends StatelessWidget {
  const MusicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GbakalCI',
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;
  late Animation<double> _scale;
  bool _loadingDone = false;
  String _statusText = 'Chargement...';

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _scale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();
    _loadData();
  }

  Future<void> _loadData() async {
    final provider = context.read<PlaylistProvider>();

    setState(() => _statusText = 'Chargement des morceaux...');
    await provider.loadTracks();

    setState(() => _statusText = 'Chargement des playlists...');
    await provider.loadPlaylists();

    setState(() => _statusText = 'Chargement des catégories...');
    await provider.loadCategories();

    setState(() {
      _statusText = 'C\'est parti !';
      _loadingDone = true;
    });

    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const AppShell(),
          transitionsBuilder: (_, anim, __, child) => FadeTransition(
            opacity: anim,
            child: child,
          ),
          transitionDuration: const Duration(milliseconds: 600),
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBg,
      body: Center(
        child: FadeTransition(
          opacity: _fadeIn,
          child: ScaleTransition(
            scale: _scale,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Drapeau CI
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: SizedBox(
                    width: 60,
                    height: 6,
                    child: Row(
                      children: [
                        Expanded(child: Container(color: ciOrange)),
                        Expanded(child: Container(color: Colors.white)),
                        Expanded(child: Container(color: ciGreen)),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Logo
                RichText(
                  text: const TextSpan(
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      color: textP,
                      letterSpacing: -1,
                    ),
                    children: [
                      TextSpan(text: 'Gbakal'),
                      TextSpan(
                        text: 'CI',
                        style: TextStyle(color: ciOrange),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // Sous-titre
                const Text(
                  'Musique ivoirienne',
                  style: TextStyle(
                    fontSize: 13,
                    color: textS,
                    letterSpacing: 1,
                  ),
                ),

                const SizedBox(height: 40),

                // Loader
                SizedBox(
                  width: 28,
                  height: 28,
                  child: _loadingDone
                      ? const Icon(
                          Icons.check_circle,
                          color: ciGreen,
                          size: 28,
                        )
                      : const CircularProgressIndicator(
                          color: ciOrange,
                          strokeWidth: 2.5,
                        ),
                ),

                const SizedBox(height: 16),

                // Texte de statut
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    _statusText,
                    key: ValueKey(_statusText),
                    style: const TextStyle(
                      fontSize: 11,
                      color: textDim,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}