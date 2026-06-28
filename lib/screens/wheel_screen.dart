import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/content.dart';
import '../state/data_store.dart';
import '../state/nav_state.dart';
import '../theme/haven_theme.dart';
import '../widgets/fade_up.dart';
import '../widgets/haven_widgets.dart';

class WheelScreen extends StatefulWidget {
  const WheelScreen({super.key});

  @override
  State<WheelScreen> createState() => _WheelScreenState();
}

class _WheelSelection {
  final String label;
  final String core;
  final Color color;
  _WheelSelection(this.label, this.core, this.color);
}

class _WheelScreenState extends State<WheelScreen> {
  static const double _size = 280;
  static const double rIn = 42, rMid = 86, rOut = 128;
  static const Offset _center = Offset(140, 140);

  String? activeCore;
  _WheelSelection? sel;

  void _handleTap(Offset local) {
    final cores = context.read<DataStore>().content.emotionCores;
    final dx = local.dx - _center.dx;
    final dy = local.dy - _center.dy;
    final r = math.sqrt(dx * dx + dy * dy);
    if (r < rIn || r > rOut) return;

    // Convert back to the design's angle convention (0 = up, clockwise).
    var a = math.atan2(dy, dx) * 180 / math.pi + 90;
    a %= 360;
    if (a < 0) a += 360;

    final coreIndex = (a ~/ 60) % cores.length;
    final core = cores[coreIndex];

    setState(() {
      if (r < rMid) {
        activeCore = core.key;
        sel = null;
      } else {
        final offset = a - coreIndex * 60;
        final subIndex = (offset ~/ 12).clamp(0, core.subs.length - 1);
        activeCore = core.key;
        sel = _WheelSelection(core.subs[subIndex], core.label, core.color);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final nav = context.read<NavState>();
    final cores = context.watch<DataStore>().content.emotionCores;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 64, 20, 108),
      children: [
        FadeUp(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HamburgerButton(onTap: nav.openMenu),
              const SizedBox(height: 18),
              Text('Name the feeling', style: news(size: 30, height: 1.1)),
              const SizedBox(height: 4),
              Text("When it's all a blur, start at the center and work outward.",
                  style: hank(size: 15, height: 1.45, color: HavenColors.muted)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        FadeUp(
          delay: const Duration(milliseconds: 50),
          child: Center(
            child: GestureDetector(
              onTapDown: (d) => _handleTap(d.localPosition),
              child: CustomPaint(
                size: const Size(_size, _size),
                painter: _WheelPainter(
                    cores: cores,
                    activeCore: activeCore,
                    selLabel: sel?.label,
                    selCore: sel?.core),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 96,
          child: sel == null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 18),
                    child: Text('Tap a wedge to begin.',
                        style: hank(size: 14, color: HavenColors.faint)),
                  ),
                )
              : FadeUp(
                  duration: const Duration(milliseconds: 350),
                  child: HavenCard(
                    radius: 20,
                    child: Column(
                      children: [
                        Text('Right now there is a sense of',
                            style: hank(size: 13, color: HavenColors.muted2)),
                        const SizedBox(height: 4),
                        Text(sel!.label, style: news(size: 28, color: sel!.color)),
                        const SizedBox(height: 2),
                        Text('a shade of ${sel!.core.toLowerCase()}',
                            style: hank(size: 13.5, color: HavenColors.muted)),
                        const SizedBox(height: 14),
                        GestureDetector(
                          onTap: () => nav.go(HavenScreen.log),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 11),
                            decoration: BoxDecoration(
                              color: HavenColors.sageDeep,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Text('Log this moment',
                                style: hank(size: 14, weight: FontWeight.w600, color: HavenColors.cream)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}

class _WheelPainter extends CustomPainter {
  _WheelPainter({required this.cores, this.activeCore, this.selLabel, this.selCore});
  final List<EmotionCore> cores;
  final String? activeCore;
  final String? selLabel;
  final String? selCore;

  static const double rIn = 42, rMid = 86, rOut = 128;
  static const Offset center = Offset(140, 140);
  static const Color cream = Color(0xFFF7F3EC);

  double _rad(double deg) => (deg - 90) * math.pi / 180;
  Offset _pol(double r, double aDeg) {
    final rad = _rad(aDeg);
    return center + Offset(r * math.cos(rad), r * math.sin(rad));
  }

  Path _annulus(double r1, double r2, double a0, double a1) {
    final sweep = (a1 - a0) * math.pi / 180;
    final path = Path();
    path.moveTo(_pol(r2, a0).dx, _pol(r2, a0).dy);
    path.arcTo(Rect.fromCircle(center: center, radius: r2), _rad(a0), sweep, false);
    path.lineTo(_pol(r1, a1).dx, _pol(r1, a1).dy);
    path.arcTo(Rect.fromCircle(center: center, radius: r1), _rad(a1), -sweep, false);
    path.close();
    return path;
  }

  void _text(Canvas canvas, String text, Offset at, double fontSize, Color color,
      {double rotation = 0, FontWeight weight = FontWeight.w700}) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: hank(size: fontSize, weight: weight, color: color),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    canvas.save();
    canvas.translate(at.dx, at.dy);
    if (rotation != 0) canvas.rotate(rotation);
    tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
    canvas.restore();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..color = cream;

    for (var ci = 0; ci < cores.length; ci++) {
      final core = cores[ci];
      final a0 = ci * 60.0, a1 = a0 + 60.0, mid = (a0 + a1) / 2;
      final isActive = activeCore == core.key;

      // Inner core wedge
      canvas.drawPath(
        _annulus(rIn, rMid, a0, a1),
        Paint()..color = core.color.withValues(alpha: isActive ? 1.0 : 0.92),
      );
      canvas.drawPath(_annulus(rIn, rMid, a0, a1), stroke..strokeWidth = 2);
      _text(canvas, core.label, _pol((rIn + rMid) / 2, mid), 11, Colors.white);

      // Outer "shade" wedges
      for (var si = 0; si < core.subs.length; si++) {
        final b0 = a0 + si * 12.0, b1 = b0 + 12.0, bmid = (b0 + b1) / 2;
        final sub = core.subs[si];
        final isSel = selLabel == sub && selCore == core.label;
        canvas.drawPath(
          _annulus(rMid, rOut, b0, b1),
          Paint()..color = core.color.withValues(alpha: isSel ? 1.0 : (isActive ? 0.5 : 0.16)),
        );
        canvas.drawPath(_annulus(rMid, rOut, b0, b1), stroke..strokeWidth = 1.5);

        if (isActive) {
          var rot = bmid;
          if (rot > 90 && rot < 270) rot += 180;
          _text(canvas, sub, _pol((rMid + rOut) / 2, bmid), 7.5, Colors.white,
              rotation: (rot - 90) * math.pi / 180, weight: FontWeight.w600);
        }
      }
    }

    // Centre hole + prompt
    canvas.drawCircle(center, rIn, Paint()..color = cream);
    final hint1 = activeCore != null ? 'tap a' : 'start';
    final hint2 = activeCore != null ? 'shade' : 'here';
    _text(canvas, hint1, center.translate(0, -7), 11, HavenColors.muted, weight: FontWeight.w600);
    _text(canvas, hint2, center.translate(0, 7), 11, HavenColors.muted, weight: FontWeight.w600);
  }

  @override
  bool shouldRepaint(covariant _WheelPainter old) =>
      old.activeCore != activeCore || old.selLabel != selLabel || old.selCore != selCore;
}
