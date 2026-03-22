import 'package:flutter/material.dart';
import '../../core/models/track.dart';
import '../../core/services/local_audio_service.dart';
import 'cover_art.dart';
import '../theme.dart';
import 'dart:typed_data';

// Widget qui affiche la pochette d'un fichier local
// Récupère l'artwork depuis le fichier audio lui-même
class LocalCoverArt extends StatefulWidget {
  final Track track;
  final double size;
  final double radius;
  final bool isPlaying;

  const LocalCoverArt({
    super.key,
    required this.track,
    this.size = 48,
    this.radius = 12,
    this.isPlaying = false,
  });

  @override
  State<LocalCoverArt> createState() => _LocalCoverArtState();
}

class _LocalCoverArtState extends State<LocalCoverArt> {
  final LocalAudioService _service = LocalAudioService();
  Uint8List? _artwork;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadArtwork();
  }

  @override
  void didUpdateWidget(LocalCoverArt old) {
    super.didUpdateWidget(old);
    if (old.track.id != widget.track.id) {
      _loadArtwork();
    }
  }

  Future<void> _loadArtwork() async {
    if (widget.track.localId == null) {
      setState(() => _loaded = true);
      return;
    }
    final artwork = await _service.getArtwork(widget.track.localId!);
    if (mounted) {
      setState(() {
        _artwork = artwork;
        _loaded = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Si pas encore chargé → placeholder
    if (!_loaded) {
      return Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.radius),
          color: card,
        ),
        child: const Center(
          child: CircularProgressIndicator(
            color: ciOrange,
            strokeWidth: 2,
          ),
        ),
      );
    }

    // Si artwork disponible → on l'affiche
    if (_artwork != null) {
      return Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.radius),
          boxShadow: widget.isPlaying
              ? [
            BoxShadow(
              color: ciOrange.withOpacity(0.3),
              blurRadius: 24,
            ),
          ]
              : [],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(widget.radius),
          child: Image.memory(
            _artwork!,
            fit: BoxFit.cover,
            width: widget.size,
            height: widget.size,
          ),
        ),
      );
    }

    // Fallback → gradient avec initiales
    return CoverArt(
      track: widget.track,
      size: widget.size,
      radius: widget.radius,
      isPlaying: widget.isPlaying,
    );
  }
}