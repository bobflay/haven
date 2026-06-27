import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/constants.dart';
import '../services/api_service.dart';
import '../theme/haven_theme.dart';
import '../widgets/fade_up.dart';
import '../widgets/haven_widgets.dart';
import '../utils/download.dart';
import 'deep_scaffold.dart';

const _formats = [
  ('Summary report', 'A readable .txt overview'),
  ('Spreadsheet (CSV)', 'Rows for every logged moment'),
];

const _included = [
  'Daily craving logs',
  'Intensity & duration',
  'Energy states',
  'Emotional ratings',
  'Sleep & coping outcomes',
];

class ExportScreen extends StatefulWidget {
  const ExportScreen({super.key});

  @override
  State<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends State<ExportScreen> {
  String range = 'Last 30 days';
  String format = 'Summary report';
  bool busy = false;
  Map<String, dynamic>? result;

  String get fileLabel => format == 'Spreadsheet (CSV)' ? '.csv' : '.txt';

  Future<void> _prepare() async {
    setState(() => busy = true);
    try {
      final r = await context.read<ApiService>().export(range, format);
      if (mounted) setState(() => result = r);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Could not prepare the export.')));
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  void _download() {
    final r = result;
    if (r == null) return;
    downloadFile(r['filename'] as String, r['content'] as String, r['mime'] as String);
  }

  @override
  Widget build(BuildContext context) {
    return DeepScaffold(
      title: 'Export data',
      children: [
        Text('Bring a clear picture to your next appointment.',
            style: hank(size: 14.5, height: 1.5, color: HavenColors.muted)),
        const SizedBox(height: 22),
        Eyebrow('Time range'),
        const SizedBox(height: 11),
        Row(
          children: [
            for (final r in kExportRanges) ...[
              Expanded(
                child: _ChoiceTile(
                  label: r,
                  selected: range == r,
                  onTap: () => setState(() {
                    range = r;
                    result = null;
                  }),
                ),
              ),
              if (r != kExportRanges.last) const SizedBox(width: 9),
            ],
          ],
        ),
        const SizedBox(height: 24),
        Eyebrow('Format'),
        const SizedBox(height: 11),
        ..._formats.map((f) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _FormatTile(
                label: f.$1,
                desc: f.$2,
                selected: format == f.$1,
                onTap: () => setState(() {
                  format = f.$1;
                  result = null;
                }),
              ),
            )),
        const SizedBox(height: 14),
        HavenCard(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Included',
                  style: hank(size: 12.5, weight: FontWeight.w600, color: const Color(0xFF5A544B))),
              const SizedBox(height: 9),
              ..._included.map((it) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(
                      children: [
                        const Icon(Icons.check, size: 14, color: HavenColors.sageDeep),
                        const SizedBox(width: 8),
                        Text(it, style: hank(size: 13.5, color: HavenColors.muted)),
                      ],
                    ),
                  )),
            ],
          ),
        ),
        const SizedBox(height: 22),
        if (result != null)
          FadeUp(
            duration: const Duration(milliseconds: 300),
            child: HavenCard(
              radius: 18,
              color: HavenColors.greenTint,
              border: const Color(0xFFD6E0D7),
              child: Column(
                children: [
                  Text('Your ${result!['count']} moments are ready to go.',
                      textAlign: TextAlign.center,
                      style: news(size: 15, height: 1.4, color: const Color(0xFF43503F))),
                  const SizedBox(height: 13),
                  GestureDetector(
                    onTap: _download,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 13),
                      decoration: BoxDecoration(
                          color: HavenColors.sageDeep, borderRadius: BorderRadius.circular(14)),
                      child: Text('Download $fileLabel',
                          style:
                              hank(size: 14.5, weight: FontWeight.w600, color: HavenColors.cream)),
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          PrimaryButton(
            label: busy ? 'Preparing…' : 'Prepare export',
            fontSize: 15.5,
            enabled: !busy,
            onTap: _prepare,
          ),
        const SizedBox(height: 4),
      ],
    );
  }
}

class _ChoiceTile extends StatelessWidget {
  const _ChoiceTile({required this.label, required this.selected, required this.onTap});
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
        padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 6),
        decoration: BoxDecoration(
          color: selected ? HavenColors.greenTint : HavenColors.card,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: selected ? HavenColors.sage : HavenColors.border, width: 1.5),
        ),
        child: Center(
          child: Text(label,
              textAlign: TextAlign.center,
              style: hank(size: 12.5, weight: FontWeight.w600)),
        ),
      ),
    );
  }
}

class _FormatTile extends StatelessWidget {
  const _FormatTile(
      {required this.label, required this.desc, required this.selected, required this.onTap});
  final String label;
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
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? HavenColors.greenTint : HavenColors.card,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: selected ? HavenColors.sage : HavenColors.border, width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: hank(size: 15, weight: FontWeight.w600)),
            const SizedBox(height: 2),
            Text(desc, style: hank(size: 12.5, color: HavenColors.muted)),
          ],
        ),
      ),
    );
  }
}
