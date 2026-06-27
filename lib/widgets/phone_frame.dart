import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/haven_theme.dart';

/// The app shell. The UI fills the whole browser window: full viewport height,
/// with the content held in a centred column capped at [maxWidth] so the
/// mobile-first layout stays readable on wide desktops. (Formerly a phone
/// mockup — the device bezel and status bar have been removed.)
class PhoneFrame extends StatelessWidget {
  const PhoneFrame({super.key, required this.child});
  final Widget child;

  /// Design reference width (used for a few relative sizings).
  static const double screenW = 390;
  static const double screenH = 844;

  /// Content never grows wider than this; below it, the app is full-bleed.
  static const double maxWidth = 480;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: HavenColors.cream,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = math.min(constraints.maxWidth, maxWidth);
          return Center(
            child: SizedBox(
              width: width,
              height: constraints.maxHeight,
              // A transparent Material gives every screen the Material ancestor
              // that TextField needs, plus the proper default text style.
              child: Material(
                type: MaterialType.transparency,
                child: child,
              ),
            ),
          );
        },
      ),
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
