import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/nav_state.dart';
import '../theme/haven_theme.dart';
import '../widgets/haven_widgets.dart';

/// Shared chrome for the "deep" screens reached from the drawer (Care team,
/// Medications, Export): a back arrow + title, then a scrolling body.
class DeepScaffold extends StatelessWidget {
  const DeepScaffold({super.key, required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final nav = context.read<NavState>();
    return ColoredBox(
      color: HavenColors.cream,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 58, 20, 16),
            child: Row(
              children: [
                GlyphButton(glyph: '‹', size: 24, onTap: () => nav.go(HavenScreen.home)),
                const SizedBox(width: 4),
                Text(title, style: news(size: 25)),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 30),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
            ),
          ),
        ],
      ),
    );
  }
}
