import 'package:flutter/material.dart';
import '../theme.dart';

class VisualizerBars extends StatelessWidget {
  final List<double> frequencyData;
  final double height;
  final int count;
  final bool isPlaying;

  const VisualizerBars({
    super.key,
    required this.frequencyData,
    this.height = 32,
    this.count = 20,
    this.isPlaying = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(
          count.clamp(0, frequencyData.length),
              (i) {
            // Couleur alternée : orange / vert / orange transparent
            final Color barColor = i % 3 == 0
                ? ciOrange
                : i % 3 == 1
                ? ciGreen
                : ciOrange.withOpacity(0.4);

            final double barHeight = (frequencyData[i] * height)
                .clamp(height * 0.04, height);

            return Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin: const EdgeInsets.symmetric(horizontal: 1),
                height: barHeight,
                decoration: BoxDecoration(
                  color: barColor.withOpacity(isPlaying ? 1.0 : 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}