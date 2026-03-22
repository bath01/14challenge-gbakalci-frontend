import 'package:flutter/material.dart';

class Responsive {

  final BuildContext context;
  late final double width;
  late final double height;
  late final double pixelRatio;

  Responsive(this.context) {
    final media = MediaQuery.of(context);
    width = media.size.width;
    height = media.size.height;
    pixelRatio = media.devicePixelRatio;
  }

  // ——— Breakpoints ———
  bool get isSmall  => width < 360;   // petits téléphones
  bool get isMedium => width < 414;   // téléphones normaux
  bool get isLarge  => width >= 414;  // grands téléphones / tablettes

  // ——— Espacements adaptatifs ———
  double get paddingH => isSmall ? 12 : 16;     // padding horizontal
  double get paddingV => isSmall ? 8  : 12;     // padding vertical
  double get gap      => isSmall ? 8  : 12;     // gap entre éléments
  double get gapLarge => isSmall ? 16 : 24;     // grand gap

  // ——— Tailles de texte adaptatives ———
  double get titleSize  => isSmall ? 16 : 18;   // titre de page
  double get bodySize   => isSmall ? 12 : 13;   // texte normal
  double get smallSize  => isSmall ? 10 : 11;   // petit texte
  double get tinySize   => isSmall ? 8  : 9;    // très petit

  // ——— Tailles de composants ———
  double get coverSizeMini   => isSmall ? 38 : 46;   // cover dans TrackRow
  double get coverSizeMedium => isSmall ? 48 : 56;   // cover dans banner
  double get coverSizeFull   => isSmall ? 180 : 220; // cover dans FullPlayer
  double get coverRadiusFull => isSmall ? 18 : 24;   // radius cover full

  double get miniPlayerHeight => isSmall ? 60 : 72;
  double get bottomNavHeight  => isSmall ? 56 : 60;

  // ——— Méthode utilitaire ———
  // Retourne une valeur selon la taille de l'écran
  T when<T>({required T small, required T medium, required T large}) {
    if (isSmall)  return small;
    if (isMedium) return medium;
    return large;
  }
}