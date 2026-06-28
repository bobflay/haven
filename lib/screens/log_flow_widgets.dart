import 'package:flutter/material.dart';

import '../models/content.dart';
import '../theme/haven_theme.dart';
import '../widgets/haven_widgets.dart';

BoxDecoration _selected(double radius) => BoxDecoration(
      color: HavenColors.greenTint,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: HavenColors.sage, width: 1.5),
      boxShadow: [
        BoxShadow(
          color: HavenColors.sageDeep.withValues(alpha: 0.6),
          blurRadius: 14,
          spreadRadius: -8,
          offset: const Offset(0, 4),
        ),
      ],
    );

BoxDecoration _unselected(double radius) => BoxDecoration(
      color: HavenColors.card,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: HavenColors.border, width: 1.5),
    );

/// A large centred AM/PM-style choice tile.
class BigChoice extends StatelessWidget {
  const BigChoice(
      {super.key, required this.big, required this.desc, required this.selected, required this.onTap});
  final String big;
  final String desc;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
        decoration: selected ? _selected(18) : _unselected(18),
        child: Column(
          children: [
            Text(big, style: news(size: 30)),
            const SizedBox(height: 4),
            Text(desc,
                textAlign: TextAlign.center,
                style: hank(size: 12.5, color: HavenColors.muted)),
          ],
        ),
      ),
    );
  }
}

/// A selectable chip with a bold label and optional supporting line.
class SelectChip extends StatelessWidget {
  const SelectChip({
    super.key,
    required this.label,
    this.desc,
    required this.selected,
    required this.onTap,
    this.radius = 16,
    this.bold = false,
    this.centered = false,
    this.fontSize = 16,
    this.padding,
  });

  final String label;
  final String? desc;
  final bool selected;
  final VoidCallback onTap;
  final double radius;
  final bool bold;
  final bool centered;
  final double fontSize;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: double.infinity,
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: selected ? _selected(radius) : _unselected(radius),
        child: Column(
          crossAxisAlignment: centered ? CrossAxisAlignment.center : CrossAxisAlignment.start,
          children: [
            Text(
              label,
              textAlign: centered ? TextAlign.center : TextAlign.start,
              style: hank(size: fontSize, weight: bold ? FontWeight.w600 : FontWeight.w600),
            ),
            if (desc != null) ...[
              const SizedBox(height: 3),
              Text(desc!, style: hank(size: 13.5, color: HavenColors.muted)),
            ],
          ],
        ),
      ),
    );
  }
}

/// The 2×2 nervous-system state cards (badge + label + description).
class StateChoice extends StatelessWidget {
  const StateChoice({super.key, required this.state, required this.selected, required this.onTap});
  final EnergyState state;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(16),
        decoration: selected ? _selected(18) : _unselected(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StateBadge(code: state.code, color: state.color, size: 34, radius: 10, fontSize: 13),
            const SizedBox(height: 10),
            Text(state.label, style: hank(size: 14, weight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(state.desc, style: hank(size: 12.5, height: 1.4, color: HavenColors.muted)),
          ],
        ),
      ),
    );
  }
}

/// A 1..count row of tappable bars (energy / intensity).
class DotScale extends StatelessWidget {
  const DotScale({
    super.key,
    required this.count,
    required this.value,
    required this.onTap,
    required this.colorFor,
  });
  final int count;
  final int value;
  final ValueChanged<int> onTap;
  final Color Function(int n) colorFor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 1; i <= count; i++) ...[
          Expanded(
            child: GestureDetector(
              onTap: () => onTap(i),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                height: 38,
                decoration: BoxDecoration(
                  color: i <= value ? colorFor(i) : HavenColors.track,
                  borderRadius: BorderRadius.circular(9),
                ),
              ),
            ),
          ),
          if (i != count) const SizedBox(width: 6),
        ],
      ],
    );
  }
}

/// Five numbered tiles for sleep quality (1..5).
class QualityDots extends StatelessWidget {
  const QualityDots({super.key, required this.value, required this.onTap});
  final int value;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 1; i <= 5; i++) ...[
          Expanded(
            child: GestureDetector(
              onTap: () => onTap(i),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                height: 46,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: i <= value ? HavenColors.sage : HavenColors.track,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('$i',
                    style: hank(
                        size: 15,
                        weight: FontWeight.w600,
                        color: i <= value ? Colors.white : HavenColors.faint)),
              ),
            ),
          ),
          if (i != 5) const SizedBox(width: 8),
        ],
      ],
    );
  }
}

/// Label + value + a 1..5 slider for one emotion.
class MoodSlider extends StatelessWidget {
  const MoodSlider({
    super.key,
    required this.label,
    required this.value,
    required this.color,
    required this.onChanged,
  });
  final String label;
  final int value;
  final Color color;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label,
                  style: hank(size: 14, weight: FontWeight.w500, color: const Color(0xFF5A544B))),
              Text('$value', style: hank(size: 14, weight: FontWeight.w700, color: color)),
            ],
          ),
          const SizedBox(height: 4),
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 4,
              activeTrackColor: color,
              inactiveTrackColor: HavenColors.track,
              thumbColor: HavenColors.card,
              overlayColor: color.withValues(alpha: 0.12),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
              trackShape: const RoundedRectSliderTrackShape(),
            ),
            child: Slider(
              min: 1,
              max: 5,
              divisions: 4,
              value: value.toDouble(),
              onChanged: (v) => onChanged(v.round()),
            ),
          ),
        ],
      ),
    );
  }
}

/// A small toggle pill (autopilot behaviours).
class PillChip extends StatelessWidget {
  const PillChip({super.key, required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? HavenColors.greenTint : HavenColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? HavenColors.sage : HavenColors.border, width: 1.5),
        ),
        child: Text(label,
            style: hank(
                size: 13.5,
                weight: FontWeight.w600,
                color: selected ? const Color(0xFF43503F) : HavenColors.muted)),
      ),
    );
  }
}
