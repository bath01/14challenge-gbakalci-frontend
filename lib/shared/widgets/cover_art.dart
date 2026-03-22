import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/models/track.dart';
import '../theme.dart';

class CoverArt extends StatelessWidget {
  final Track track;
  final double size;
  final double radius;
  final bool isPlaying;

  const CoverArt({
    super.key,
    required this.track,
    this.size = 48,
    this.radius = 12,
    this.isPlaying = false,
  });

  // Génère un gradient unique basé sur le nom de l'artiste
  // Même artiste = même couleur à chaque fois
  static LinearGradient getGradient(String artist) {
    final hash = artist.codeUnits.fold(0, (sum, c) => sum + c);
    final hue1 = hash % 360;
    final hue2 = (hue1 + 40) % 360;
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        HSLColor.fromAHSL(1, hue1.toDouble(), 0.7, 0.35).toColor(),
        HSLColor.fromAHSL(1, hue2.toDouble(), 0.6, 0.25).toColor(),
      ],
    );
  }

  // Initiales de l'artiste — ex: "Magic System" → "MS"
  static String getInitials(String name) {
    return name
        .split(' ')
        .take(2)
        .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
        .join();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: getGradient(track.artist),
        boxShadow: isPlaying
            ? [
          BoxShadow(
            color: ciOrange.withOpacity(0.3),
            blurRadius: 24,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ]
            : [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      // Si une URL de pochette est disponible → on affiche l'image
      // Sinon → on affiche les initiales
      child: track.coverUrl.isNotEmpty
          ? ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: CachedNetworkImage(
          imageUrl: track.coverUrl,
          fit: BoxFit.cover,
          placeholder: (_, __) => _buildInitials(),
          errorWidget: (_, __, ___) => _buildInitials(),
        ),
      )
          : _buildInitials(),
    );
  }

  Widget _buildInitials() {
    return Center(
      child: Text(
        getInitials(track.artist),
        style: TextStyle(
          color: Colors.white.withOpacity(0.75),
          fontSize: size * 0.3,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
      ),
    );
  }
}