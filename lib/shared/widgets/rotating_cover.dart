import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/models/track.dart';
import '../theme.dart';
import 'cover_art.dart';

class RotatingCover extends StatefulWidget {
  final Track track;
  final bool isPlaying;
  final double size;

  const RotatingCover({
    super.key,
    required this.track,
    required this.isPlaying,
    this.size = 260,
  });

  @override
  State<RotatingCover> createState() => _RotatingCoverState();
}

class _RotatingCoverState extends State<RotatingCover>
    with SingleTickerProviderStateMixin {
  // SingleTickerProviderStateMixin = fournit un ticker pour l'animation
  // Un ticker = une source de frames d'animation

  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      // durée d'une rotation complète = 12 secondes
      duration: const Duration(seconds: 12),
    );

    // Si en lecture au démarrage → on lance l'animation
    if (widget.isPlaying) {
      _controller.repeat(); // repeat = tourne en boucle infinie
    }
  }

  @override
  void didUpdateWidget(RotatingCover oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Quand isPlaying change → on démarre ou on arrête la rotation
    if (widget.isPlaying != oldWidget.isPlaying) {
      if (widget.isPlaying) {
        _controller.repeat();
      } else {
        // forward = continue jusqu'à la fin de l'animation en cours
        // puis s'arrête — évite un saut brusque
        _controller.stop();
      }
    }

    // Quand le morceau change → on remet la rotation à 0
    if (widget.track.id != oldWidget.track.id) {
      _controller.reset();
      if (widget.isPlaying) _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose(); // libère les ressources
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [

          // ——— Anneau extérieur décoratif ———
          Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.08),
                width: 1,
              ),
            ),
          ),

          // ——— Pochette circulaire qui tourne ———
          RotationTransition(
            // RotationTransition utilise l'animation du controller
            // turns = nombre de tours complets
            turns: _controller,
            child: Container(
              width: widget.size - 8,
              height: widget.size - 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: ciOrange.withOpacity(
                      widget.isPlaying ? 0.4 : 0.1,
                    ),
                    blurRadius: widget.isPlaying ? 40 : 20,
                    spreadRadius: widget.isPlaying ? 8 : 2,
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipOval(
                // ClipOval = découpe en cercle parfait
                child: widget.track.coverUrl.isNotEmpty
                    ? CachedNetworkImage(
                  imageUrl: widget.track.coverUrl,
                  fit: BoxFit.cover,
                  width: widget.size - 8,
                  height: widget.size - 8,
                  placeholder: (_, __) => _buildGradientCover(),
                  errorWidget: (_, __, ___) => _buildGradientCover(),
                )
                    : _buildGradientCover(),
              ),
            ),
          ),

          // ——— Point central (style vinyle) ———
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: darkBg,
              border: Border.all(
                color: Colors.white.withOpacity(0.15),
                width: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Pochette gradient quand pas d'image disponible
  Widget _buildGradientCover() {
    return Container(
      decoration: BoxDecoration(
        gradient: CoverArt.getGradient(widget.track.artist),
      ),
      child: Center(
        child: Text(
          CoverArt.getInitials(widget.track.artist),
          style: TextStyle(
            color: Colors.white.withOpacity(0.75),
            fontSize: widget.size * 0.22,
            fontWeight: FontWeight.w800,
            letterSpacing: -1,
          ),
        ),
      ),
    );
  }
}