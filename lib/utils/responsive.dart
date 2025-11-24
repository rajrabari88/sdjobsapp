import 'package:flutter/material.dart';

// Simple responsive helpers used across the app.
class Responsive {
  // Breakpoints (you can tune these)
  static const double smallWidth = 360; // small phones
  static const double mediumWidth = 600; // large phones / small tablets
  static const double largeWidth = 900; // tablets / foldable wide

  static bool isSmall(BuildContext context) {
    return MediaQuery.of(context).size.width < mediumWidth;
  }

  static bool isMedium(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return w >= mediumWidth && w < largeWidth;
  }

  static bool isLarge(BuildContext context) {
    return MediaQuery.of(context).size.width >= largeWidth;
  }

  // Returns a scaled font size based on screen width
  static double fontSize(BuildContext context, double base) {
    final w = MediaQuery.of(context).size.width;
    if (w < mediumWidth) return base; // default
    if (w < largeWidth) return base * 1.08;
    return base * 1.18;
  }

  // Return an adaptive width for cards like featured cards
  static double featuredCardWidth(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w < mediumWidth) return w * 0.75; // allow horizontal peek
    if (w < largeWidth) return 340;
    return 420; // spacious on large/foldable
  }

  // Return suggested list item padding
  static EdgeInsets contentPadding(BuildContext context) {
    if (isSmall(context)) return const EdgeInsets.symmetric(horizontal: 12);
    if (isMedium(context)) return const EdgeInsets.symmetric(horizontal: 16);
    return const EdgeInsets.symmetric(horizontal: 24);
  }
}

// A small widget that switches between single-column and two-column
// layouts based on width. Useful for foldables: show two columns on wide screens.
class AdaptiveTwoColumn extends StatelessWidget {
  final Widget left;
  final Widget right;
  final double splitRatio; // fraction for left column

  const AdaptiveTwoColumn({
    Key? key,
    required this.left,
    required this.right,
    this.splitRatio = 0.55,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w >= Responsive.largeWidth) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: w * splitRatio, child: left),
          const SizedBox(width: 16),
          Expanded(child: right),
        ],
      );
    }

    // fallback single column
    return Column(children: [left, const SizedBox(height: 12), right]);
  }
}
