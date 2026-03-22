import 'package:flutter/material.dart';
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
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: textP,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                '"Gbakal" = ambiance / fête en nouchi (argot ivoirien)',
                style: TextStyle(
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                  color: textDim,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Player de musique ivoirienne — écouter du Zouglou, du Coupé-Décalé et du Rap Ivoire sans connexion ni inscription.',
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

        // ——— Fonctionnalités ———
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
                'FONCTIONNALITÉS',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: textDim,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 14),
              ...[
                [Icons.play_circle_outline, 'Lecture audio complète', 'Play, pause, suivant, précédent, shuffle, repeat'],
                [Icons.download_outlined, 'Téléchargement hors-ligne', 'Sauvegarde locale des morceaux via SQLite'],
                [Icons.queue_music, 'Playlists', 'Créer, modifier, réordonner vos playlists'],
                [Icons.category_outlined, 'Catégories', 'Filtrer par genre : Zouglou, Coupé-Décalé, Rap Ivoire...'],
                [Icons.equalizer, 'Visualiseur audio', 'Barres animées en temps réel'],
                [Icons.album, 'Pochette tournante', 'Animation fluide dans le lecteur plein écran'],
              ].map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      item[0] as IconData,
                      color: ciOrange,
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item[1] as String,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: textP,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item[2] as String,
                            style: const TextStyle(
                              fontSize: 10,
                              color: textS,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // ——— Stack technique ———
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
                'STACK TECHNIQUE',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: textDim,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 14),
              ...[
                ['Frontend', 'Flutter / Dart'],
                ['État', 'Provider'],
                ['Audio', 'just_audio + audio_session'],
                ['HTTP', 'Dio'],
                ['Base de données', 'SQLite (sqflite)'],
                ['Cache images', 'cached_network_image'],
                ['Backend', '.NET Core (API REST)'],
              ].map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    SizedBox(
                      width: 110,
                      child: Text(
                        item[0],
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: textDim,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        item[1],
                        style: const TextStyle(
                          fontSize: 11,
                          color: textP,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
            ],
          ),
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
                ['Bath Dorgeles', 'Chef de projet & Front-end'],
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
                text: const TextSpan(
                  style: TextStyle(fontSize: 12, color: textS),
                  children: [
                    TextSpan(text: 'Open Source · '),
                    TextSpan(
                      text: '225os.com',
                      style: TextStyle(
                        color: ciOrange,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    TextSpan(text: ' & '),
                    TextSpan(
                      text: 'GitHub',
                      style: TextStyle(
                        color: ciGreen,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Version 1.0.0',
                style: TextStyle(
                  fontSize: 11,
                  color: textS,
                ),
              ),
              const SizedBox(height: 4),
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
  }
}
