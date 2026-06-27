import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/data_store.dart';
import '../state/nav_state.dart';
import '../theme/haven_theme.dart';
import '../widgets/fade_up.dart';
import '../widgets/haven_widgets.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<DataStore>();
    final nav = context.read<NavState>();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 64, 20, 108),
      children: [
        FadeUp(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HamburgerButton(onTap: nav.openMenu),
              const SizedBox(height: 18),
              Text('Your patterns', style: news(size: 30, height: 1.1)),
              const SizedBox(height: 4),
              Text('The last 7 days, gently observed.',
                  style: hank(size: 15, color: HavenColors.muted)),
            ],
          ),
        ),
        const SizedBox(height: 20),
        FadeUp(
          delay: const Duration(milliseconds: 50),
          child: HavenCard(
            radius: 20,
            color: HavenColors.greenTint,
            border: const Color(0xFFDDE7DD),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Eyebrow('A gentle observation', color: HavenColors.sageDeep, size: 11),
                const SizedBox(height: 6),
                Text(store.insight,
                    style: news(size: 17, height: 1.45, color: const Color(0xFF43503F))),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        FadeUp(
          delay: const Duration(milliseconds: 100),
          child: HavenCard(
            radius: 22,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Craving intensity', style: hank(size: 14, weight: FontWeight.w600)),
                Text('Average per day · 1–10',
                    style: hank(size: 12.5, color: HavenColors.muted2)),
                const SizedBox(height: 16),
                _WeekChart(store: store),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        FadeUp(
          delay: const Duration(milliseconds: 150),
          child: HavenCard(
            radius: 22,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Energy states', style: hank(size: 14, weight: FontWeight.w600)),
                const SizedBox(height: 16),
                ...store.stateDist.map((d) => Padding(
                      padding: const EdgeInsets.only(bottom: 13),
                      child: _StateRow(item: d),
                    )),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        FadeUp(
          delay: const Duration(milliseconds: 200),
          child: HavenCard(
            radius: 22,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Emotional weather', style: hank(size: 14, weight: FontWeight.w600)),
                Text('Weekly average · 1–5', style: hank(size: 12.5, color: HavenColors.muted2)),
                const SizedBox(height: 16),
                ...store.moodBars.map((m) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _MoodRow(bar: m),
                    )),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _WeekChart extends StatelessWidget {
  const _WeekChart({required this.store});
  final DataStore store;

  static const double _barMax = 76;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: store.weekBars.map((b) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(b.label, style: hank(size: 11, weight: FontWeight.w600, color: HavenColors.muted)),
                  const SizedBox(height: 8),
                  Container(
                    height: (b.fraction * _barMax).clamp(4, _barMax),
                    decoration: BoxDecoration(
                      color: b.color,
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(8), bottom: Radius.circular(4)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(b.day, style: hank(size: 11, weight: FontWeight.w600, color: HavenColors.faint)),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _StateRow extends StatelessWidget {
  const _StateRow({required this.item});
  final StateDistItem item;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        StateBadge(code: item.state.code, color: item.state.color, size: 32, radius: 9, fontSize: 12),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(item.state.label,
                      style: hank(size: 13, weight: FontWeight.w500, color: const Color(0xFF5A544B))),
                  Text('${item.count}',
                      style: hank(size: 13, weight: FontWeight.w600, color: HavenColors.muted2)),
                ],
              ),
              const SizedBox(height: 5),
              _Track(fraction: item.fraction, color: item.state.color, height: 8),
            ],
          ),
        ),
      ],
    );
  }
}

class _MoodRow extends StatelessWidget {
  const _MoodRow({required this.bar});
  final MoodBar bar;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(bar.label,
                style: hank(size: 13, weight: FontWeight.w500, color: const Color(0xFF5A544B))),
            Text(bar.value, style: hank(size: 13, weight: FontWeight.w600, color: bar.color)),
          ],
        ),
        const SizedBox(height: 6),
        _Track(fraction: bar.fraction, color: bar.color, height: 9),
      ],
    );
  }
}

class _Track extends StatelessWidget {
  const _Track({required this.fraction, required this.color, required this.height});
  final double fraction;
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(height / 2),
      child: Container(
        height: height,
        color: const Color(0xFFEFE9DD),
        child: FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: fraction.clamp(0.0, 1.0),
          child: Container(
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(height / 2)),
          ),
        ),
      ),
    );
  }
}
