import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/nav_state.dart';
import '../theme/haven_theme.dart';

const _prompts = [
  'Cravings peak and fade. This one will too.',
  'Name five things you can see right now.',
  'You have survived every urge before this one.',
  'Feel your feet. Feel the chair. You are here.',
  "You don't have to act. You only have to wait.",
];

class CopingScreen extends StatefulWidget {
  const CopingScreen({super.key});

  @override
  State<CopingScreen> createState() => _CopingScreenState();
}

class _CopingScreenState extends State<CopingScreen> with SingleTickerProviderStateMixin {
  static const int _total = 1200; // 20 minutes
  int timer = _total;
  bool running = true;
  Timer? _ticker;

  late final AnimationController _breath =
      AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat(reverse: true);

  @override
  void initState() {
    super.initState();
    _start();
  }

  void _start() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        if (timer <= 1) {
          timer = 0;
          running = false;
          _ticker?.cancel();
        } else {
          timer -= 1;
        }
      });
    });
  }

  void _toggle() {
    setState(() {
      running = !running;
      if (running) {
        _start();
      } else {
        _ticker?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _breath.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final nav = context.read<NavState>();
    final mm = (timer ~/ 60).toString();
    final ss = (timer % 60).toString().padLeft(2, '0');
    final prompt = _prompts[((_total - timer) ~/ 24) % _prompts.length];

    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0, -0.3),
          radius: 1.1,
          colors: [Color(0xFF6F8C76), Color(0xFF5B7763), Color(0xFF4D6655)],
          stops: [0.0, 0.55, 1.0],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 58,
            right: 24,
            child: GestureDetector(
              onTap: () => nav.go(HavenScreen.home),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3EFE6).withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text('×',
                      style: hank(size: 20, color: const Color(0xFFF3EFE6))),
                ),
              ),
            ),
          ),
          Column(
            children: [
              const SizedBox(height: 78),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  children: [
                    Text('RIDE THE WAVE',
                        style: hank(
                            size: 13,
                            color: const Color(0xFFF3EFE6).withValues(alpha: 0.7),
                            letterSpacing: 2.0)),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 70,
                      child: Center(
                        child: Text(prompt,
                            textAlign: TextAlign.center,
                            style: news(size: 25, height: 1.35, color: const Color(0xFFF3EFE6))),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: AnimatedBuilder(
                    animation: _breath,
                    builder: (context, _) {
                      final t = _breath.value; // 0..1
                      final breathScale = 0.72 + 0.28 * t;
                      final breathOpacity = 0.55 + 0.45 * t;
                      final ringScale = 0.86 + 0.22 * t;
                      final ringOpacity = 0.5 * (1 - t);
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          Transform.scale(
                            scale: ringScale,
                            child: Opacity(
                              opacity: ringOpacity,
                              child: Container(
                                width: 250,
                                height: 250,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: const Color(0xFFF3EFE6).withValues(alpha: 0.4)),
                                ),
                              ),
                            ),
                          ),
                          Transform.scale(
                            scale: breathScale,
                            child: Opacity(
                              opacity: breathOpacity,
                              child: Container(
                                width: 210,
                                height: 210,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    center: const Alignment(-0.24, -0.36),
                                    colors: [
                                      const Color(0xFFF3EFE6).withValues(alpha: 0.4),
                                      const Color(0xFFF3EFE6).withValues(alpha: 0.08),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Text('$mm:$ss',
                              style: news(size: 44, color: const Color(0xFFF7F3EC))),
                        ],
                      );
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(30, 0, 30, 56),
                child: Column(
                  children: [
                    Text('Breathe with the circle. Nothing to fix — just stay.',
                        textAlign: TextAlign.center,
                        style: hank(
                            size: 14,
                            height: 1.5,
                            color: const Color(0xFFF3EFE6).withValues(alpha: 0.8))),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: _WaveButton(
                            label: running ? 'Pause' : 'Resume',
                            filled: true,
                            onTap: _toggle,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _WaveButton(
                            label: 'I rode it out',
                            filled: false,
                            onTap: () => nav.go(HavenScreen.home),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WaveButton extends StatelessWidget {
  const _WaveButton({required this.label, required this.filled, required this.onTap});
  final String label;
  final bool filled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color:
              filled ? const Color(0xFFF3EFE6) : const Color(0xFFF3EFE6).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: filled ? null : Border.all(color: const Color(0xFFF3EFE6).withValues(alpha: 0.45)),
        ),
        child: Center(
          child: Text(label,
              style: hank(
                  size: 15,
                  weight: FontWeight.w600,
                  color: filled ? const Color(0xFF44593F) : const Color(0xFFF3EFE6))),
        ),
      ),
    );
  }
}
