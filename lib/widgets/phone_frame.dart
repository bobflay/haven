import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/haven_theme.dart';

/// The app shell. The UI fills the whole browser window edge-to-edge. Each
/// screen draws its own full-bleed background; the readable content inside is
/// centred and width-limited by [contentWidth] so it scales with the screen
/// rather than stretching mobile cards across a 4K monitor.
class PhoneFrame extends StatelessWidget {
  const PhoneFrame({super.key, required this.child});
  final Widget child;

  /// Design reference height (used for the auth screens' min height).
  static const double screenH = 844;

  /// A responsive content width: full-bleed on phones, then scaling up with the
  /// viewport but bounded so mobile-style cards stay readable on big displays.
  static double contentWidth(double viewportWidth) {
    if (viewportWidth < 600) return viewportWidth;
    return (viewportWidth * 0.58).clamp(600.0, 860.0);
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: HavenColors.cream,
      // A transparent Material gives every screen the Material ancestor that
      // TextField needs, plus the proper default text style.
      child: Material(
        type: MaterialType.transparency,
        child: child,
      ),
    );
  }
}

/// Centres a screen's readable content and caps its width responsively, while
/// the screen's background fills the full viewport behind it.
class CenteredContent extends StatelessWidget {
  const CenteredContent({super.key, required this.child, this.maxWidth});

  final Widget child;

  /// Override the responsive width with a fixed cap (used by the auth forms).
  final double? maxWidth;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = maxWidth != null
            ? math.min(constraints.maxWidth, maxWidth!)
            : PhoneFrame.contentWidth(constraints.maxWidth);
        return Center(
          child: SizedBox(
            width: width,
            height: constraints.maxHeight,
            child: child,
          ),
        );
      },
    );
  }
}

/// The little concentric-arc "horizon" mark, on a sage rounded square.
class HavenLogo extends StatelessWidget {
  const HavenLogo({super.key, this.size = 48, this.radius = 15, this.strokeScale = 1.0});
  final double size;
  final double radius;
  final double strokeScale;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF82997F), Color(0xFF647F6A)],
        ),
        boxShadow: [
          if (size >= 60)
            BoxShadow(
              color: const Color(0xFF5E7A68).withValues(alpha: 0.6),
              blurRadius: 30,
              spreadRadius: -12,
              offset: const Offset(0, 16),
            ),
        ],
      ),
      child: Center(
        child: SizedBox(
          width: size * 0.62,
          height: size * 0.62,
          child: CustomPaint(painter: _HavenMarkPainter(strokeScale)),
        ),
      ),
    );
  }
}

class _HavenMarkPainter extends CustomPainter {
  _HavenMarkPainter(this.strokeScale);
  final double strokeScale;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 48.0;
    final center = Offset(24 * s, 31 * s);
    const cream = Color(0xFFF3EFE6);
    const brightCream = Color(0xFFF7F3EC);

    void arc(double r, Color color, double opacity) {
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 2.4 * s * strokeScale
        ..color = color.withValues(alpha: opacity);
      // top semicircle: start at 180°, sweep 180° clockwise (through the top).
      canvas.drawArc(Rect.fromCircle(center: center, radius: r * s), math.pi, math.pi, false, paint);
    }

    arc(19, cream, 0.40);
    arc(13, cream, 0.62);
    arc(7, brightCream, 0.92);

    // centre dot
    canvas.drawCircle(center, 2.6 * s, Paint()..color = brightCream);

    // horizon line
    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2.4 * s * strokeScale
      ..color = cream.withValues(alpha: 0.85);
    canvas.drawLine(Offset(4 * s, 36 * s), Offset(44 * s, 36 * s), line);
  }

  @override
  bool shouldRepaint(covariant _HavenMarkPainter oldDelegate) => false;
}
