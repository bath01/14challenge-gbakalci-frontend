import 'package:flutter/material.dart';
import '../theme.dart';

class GenreBadge extends StatelessWidget {
  final String genre;
  final bool large;

  const GenreBadge({
    super.key,
    required this.genre,
    this.large = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: large ? 10 : 7,
        vertical: large ? 4 : 2,
      ),
      decoration: BoxDecoration(
        color: ciGreen.withOpacity(0.18),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        genre,
        style: TextStyle(
          fontSize: large ? 10 : 9,
          fontWeight: FontWeight.w600,
          color: ciGreen,
        ),
      ),
    );
  }
}