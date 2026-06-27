import 'package:flutter/material.dart';

import '../theme/haven_theme.dart';

/// The standard raised card surface (#fdfbf7 with a hairline border).
class HavenCard extends StatelessWidget {
  const HavenCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.radius = 18,
    this.color = HavenColors.card,
    this.border = HavenColors.border,
    this.borderWidth = 1,
  });

  final Widget child;
  final EdgeInsets padding;
  final double radius;
  final Color color;
  final Color border;
  final double borderWidth;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: border, width: borderWidth),
      ),
      child: child,
    );
  }
}

/// The primary call-to-action: sage when ready, muted + non-interactive when not.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onTap,
    this.enabled = true,
    this.radius = 16,
    this.fontSize = 15.5,
    this.padding = 16,
  });

  final String label;
  final VoidCallback? onTap;
  final bool enabled;
  final double radius;
  final double fontSize;
  final double padding;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: padding),
        decoration: BoxDecoration(
          color: enabled ? HavenColors.sageDeep : HavenColors.disabledBg,
          borderRadius: BorderRadius.circular(radius),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: HavenColors.sageDeep.withValues(alpha: 0.9),
                    blurRadius: 24,
                    spreadRadius: -12,
                    offset: const Offset(0, 12),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: hank(
              size: fontSize,
              weight: FontWeight.w600,
              color: enabled ? HavenColors.cream : HavenColors.faint2,
            ),
          ),
        ),
      ),
    );
  }
}

/// The 40×40 hamburger that opens the side drawer.
class HamburgerButton extends StatelessWidget {
  const HamburgerButton({super.key, required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    Widget line(double w) => Container(
          width: w,
          height: 1.8,
          margin: const EdgeInsets.symmetric(vertical: 1.75),
          decoration: BoxDecoration(
            color: const Color(0xFF6C6256),
            borderRadius: BorderRadius.circular(2),
          ),
        );
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: HavenColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: HavenColors.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [line(16), line(16), line(11)],
        ),
      ),
    );
  }
}

/// A coloured square holding a two-letter state code (HW/RF/TZ/FC).
class StateBadge extends StatelessWidget {
  const StateBadge({
    super.key,
    required this.code,
    required this.color,
    this.size = 38,
    this.radius = 11,
    this.fontSize = 13,
  });

  final String code;
  final Color color;
  final double size;
  final double radius;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(radius)),
      alignment: Alignment.center,
      child: Text(code, style: hank(size: fontSize, weight: FontWeight.w700, color: Colors.white)),
    );
  }
}

/// A circular back / close glyph button used on flow headers.
class GlyphButton extends StatelessWidget {
  const GlyphButton({
    super.key,
    required this.glyph,
    required this.onTap,
    this.color = HavenColors.muted,
    this.size = 22,
    this.align = TextAlign.left,
  });

  final String glyph;
  final VoidCallback onTap;
  final Color color;
  final double size;
  final TextAlign align;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 30,
        child: Text(glyph,
            textAlign: align, style: hank(size: size, weight: FontWeight.w500, color: color)),
      ),
    );
  }
}

/// A styled single-line / multi-line input that matches the design's fields.
class HavenField extends StatelessWidget {
  const HavenField({
    super.key,
    required this.controller,
    this.hint,
    this.obscure = false,
    this.keyboardType,
    this.borderColor = HavenColors.borderSoft,
    this.onChanged,
    this.minLines,
    this.maxLines = 1,
    this.fillColor = HavenColors.card,
  });

  final TextEditingController controller;
  final String? hint;
  final bool obscure;
  final TextInputType? keyboardType;
  final Color borderColor;
  final ValueChanged<String>? onChanged;
  final int? minLines;
  final int? maxLines;
  final Color fillColor;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      minLines: minLines,
      maxLines: obscure ? 1 : maxLines,
      onChanged: onChanged,
      style: hank(size: 15.5, color: HavenColors.ink),
      cursorColor: HavenColors.sageDeep,
      decoration: InputDecoration(
        isDense: true,
        filled: true,
        fillColor: fillColor,
        hintText: hint,
        hintStyle: hank(size: 15.5, color: HavenColors.faint),
        contentPadding: const EdgeInsets.symmetric(horizontal: 17, vertical: 15),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: borderColor, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: HavenColors.sage, width: 1.5),
        ),
      ),
    );
  }
}

/// Label + field pair used on the auth and "add" forms.
class LabeledField extends StatelessWidget {
  const LabeledField({super.key, required this.label, required this.field});
  final String label;
  final Widget field;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(label.toUpperCase(),
              style: hank(
                  size: 11,
                  weight: FontWeight.w600,
                  color: HavenColors.muted2,
                  letterSpacing: 1.1)),
        ),
        field,
      ],
    );
  }
}

/// Small uppercase section header (".12em tracking, muted").
class Eyebrow extends StatelessWidget {
  const Eyebrow(this.text, {super.key, this.color = HavenColors.muted2, this.size = 12});
  final String text;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Text(text.toUpperCase(),
        style: hank(size: size, weight: FontWeight.w600, color: color, letterSpacing: size * 0.1));
  }
}
