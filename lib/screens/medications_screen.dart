import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/constants.dart';
import '../models/models.dart';
import '../state/data_store.dart';
import '../theme/haven_theme.dart';
import '../widgets/fade_up.dart';
import '../widgets/haven_widgets.dart';
import 'deep_scaffold.dart';

class MedicationsScreen extends StatefulWidget {
  const MedicationsScreen({super.key});

  @override
  State<MedicationsScreen> createState() => _MedicationsScreenState();
}

class _MedicationsScreenState extends State<MedicationsScreen> {
  bool formOpen = false;
  bool saving = false;
  final _name = TextEditingController();
  final _dose = TextEditingController();
  final _purpose = TextEditingController();
  final _prescriber = TextEditingController();
  final _supply = TextEditingController();
  final Set<String> _times = {};
  String _form = 'tablet';

  @override
  void dispose() {
    for (final c in [_name, _dose, _purpose, _prescriber, _supply]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty) return;
    setState(() => saving = true);
    try {
      await context.read<DataStore>().addMedication({
        'name': _name.text.trim(),
        'dose': _dose.text.trim().isEmpty ? '—' : _dose.text.trim(),
        'form': _form,
        'times': _times.isEmpty ? ['Morning'] : _times.toList(),
        'purpose': _purpose.text.trim(),
        'prescriber': _prescriber.text.trim(),
        'supply_days': int.tryParse(_supply.text.trim()),
      });
      for (final c in [_name, _dose, _purpose, _prescriber, _supply]) {
        c.clear();
      }
      _times.clear();
      _form = 'tablet';
      if (mounted) setState(() => formOpen = false);
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<DataStore>();

    return DeepScaffold(
      title: 'Medications',
      children: [
        Text('Your routine, gently kept. For reference only — never medical advice.',
            style: hank(size: 14.5, height: 1.5, color: HavenColors.muted)),
        const SizedBox(height: 18),
        _TodaysDosesCard(store: store),
        const SizedBox(height: 22),
        Eyebrow('Your medications'),
        const SizedBox(height: 12),
        ...store.medications.map((m) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _MedCard(med: m),
            )),
        if (formOpen)
          FadeUp(
            duration: const Duration(milliseconds: 300),
            child: _MedForm(
              name: _name,
              dose: _dose,
              purpose: _purpose,
              prescriber: _prescriber,
              supply: _supply,
              times: _times,
              form: _form,
              saving: saving,
              onToggleTime: (t) => setState(() => _times.contains(t) ? _times.remove(t) : _times.add(t)),
              onSetForm: (f) => setState(() => _form = f),
              onSave: _save,
              onCancel: () => setState(() => formOpen = false),
            ),
          )
        else
          _DashedAdd(label: '+ Add a medication', onTap: () => setState(() => formOpen = true)),
        const SizedBox(height: 4),
      ],
    );
  }
}

class _TodaysDosesCard extends StatelessWidget {
  const _TodaysDosesCard({required this.store});
  final DataStore store;

  @override
  Widget build(BuildContext context) {
    final doses = store.todaysDoses;
    return HavenCard(
      radius: 18,
      color: HavenColors.greenTint,
      border: const Color(0xFFD6E0D7),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Eyebrow("Today's doses", color: HavenColors.sageDeep, size: 12),
              Text('${store.adherenceTaken} of ${store.adherenceTotal} taken',
                  style: hank(size: 13, weight: FontWeight.w600, color: const Color(0xFF5E7A68))),
            ],
          ),
          const SizedBox(height: 11),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Container(
              height: 7,
              color: const Color(0xFFD8E3D9),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: store.adherenceFraction,
                child: Container(
                  decoration: BoxDecoration(
                      color: HavenColors.sageDeep, borderRadius: BorderRadius.circular(4)),
                ),
              ),
            ),
          ),
          ...doses.map((d) => _DoseRow(dose: d)),
        ],
      ),
    );
  }
}

class _DoseRow extends StatelessWidget {
  const _DoseRow({required this.dose});
  final DoseItem dose;

  @override
  Widget build(BuildContext context) {
    final store = context.read<DataStore>();
    return GestureDetector(
      onTap: () => store.toggleDose(dose.medId, dose.slot),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: HavenColors.sageDeep.withValues(alpha: 0.16))),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 27,
              height: 27,
              decoration: BoxDecoration(
                color: dose.taken ? HavenColors.sageDeep : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                    color: dose.taken ? HavenColors.sageDeep : const Color(0xFFCFD8CF), width: 1.5),
              ),
              child: dose.taken
                  ? const Icon(Icons.check, size: 14, color: HavenColors.cream)
                  : null,
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(dose.medName,
                      style: hank(
                          size: 14.5,
                          weight: FontWeight.w600,
                          color: dose.taken ? HavenColors.muted2 : HavenColors.ink,
                          height: 1.2).copyWith(
                          decoration: dose.taken ? TextDecoration.lineThrough : null,
                          decorationColor: HavenColors.muted2)),
                  Text('${dose.dose} · ${dose.slot}',
                      style: hank(size: 12, color: HavenColors.muted2)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MedCard extends StatelessWidget {
  const _MedCard({required this.med});
  final Medication med;

  @override
  Widget build(BuildContext context) {
    final m = med;
    final low = m.supplyDays != null && m.supplyDays! <= 7;
    final supplyColor = low ? HavenColors.clay : const Color(0xFF7C9885);
    final supplyBarW = m.supplyDays == null ? 0.0 : (m.supplyDays! / 30).clamp(0.04, 1.0);

    return HavenCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                    color: const Color(0xFFECEAF0), borderRadius: BorderRadius.circular(14)),
                child: const Icon(Icons.medication_outlined, size: 22, color: Color(0xFF7A6C8A)),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                            child: Text(m.name,
                                style: news(size: 17, weight: FontWeight.w500))),
                        const SizedBox(width: 8),
                        Text(m.dose,
                            style:
                                hank(size: 13, weight: FontWeight.w600, color: HavenColors.sageDeep)),
                      ],
                    ),
                    if (m.purpose != null && m.purpose!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text('For ${m.purpose} · ${m.form}',
                            style: hank(size: 12.5, color: HavenColors.muted2)),
                      ),
                    const SizedBox(height: 9),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: m.times
                          .map((t) => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 4),
                                decoration: BoxDecoration(
                                    color: const Color(0xFFF1ECE1),
                                    borderRadius: BorderRadius.circular(8)),
                                child: Text(t,
                                    style: hank(
                                        size: 11.5,
                                        weight: FontWeight.w600,
                                        color: const Color(0xFF6C6256))),
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Container(
            margin: const EdgeInsets.only(top: 13),
            padding: const EdgeInsets.only(top: 12),
            decoration:
                const BoxDecoration(border: Border(top: BorderSide(color: Color(0xFFF0EBE0)))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(m.supplyDays != null ? '${m.supplyDays} days left' : '',
                        style: hank(size: 12.5, weight: FontWeight.w600, color: supplyColor)),
                    if (m.prescriber != null && m.prescriber!.isNotEmpty)
                      Text(m.prescriber!, style: hank(size: 12, color: HavenColors.muted2)),
                  ],
                ),
                if (m.supplyDays != null) ...[
                  const SizedBox(height: 7),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Container(
                      height: 6,
                      color: const Color(0xFFEFE9DD),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: supplyBarW,
                        child: Container(
                            decoration: BoxDecoration(
                                color: supplyColor, borderRadius: BorderRadius.circular(4))),
                      ),
                    ),
                  ),
                ],
                if (low && m.refillBy != null && m.refillBy!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text('Running low · Refill by ${m.refillBy}',
                        style: hank(size: 11.5, weight: FontWeight.w600, color: HavenColors.clay)),
                  ),
              ],
            ),
          ),
          if (m.notes != null && m.notes!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(m.notes!,
                  style: news(size: 13, height: 1.45, italic: true, color: HavenColors.muted)),
            ),
        ],
      ),
    );
  }
}

class _MedForm extends StatelessWidget {
  const _MedForm({
    required this.name,
    required this.dose,
    required this.purpose,
    required this.prescriber,
    required this.supply,
    required this.times,
    required this.form,
    required this.saving,
    required this.onToggleTime,
    required this.onSetForm,
    required this.onSave,
    required this.onCancel,
  });

  final TextEditingController name, dose, purpose, prescriber, supply;
  final Set<String> times;
  final String form;
  final bool saving;
  final ValueChanged<String> onToggleTime;
  final ValueChanged<String> onSetForm;
  final VoidCallback onSave;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    Widget field(TextEditingController c, String hint, {TextInputType? type}) => Padding(
          padding: const EdgeInsets.only(bottom: 9),
          child: HavenField(
              controller: c,
              hint: hint,
              keyboardType: type,
              borderColor: HavenColors.borderWarm,
              fillColor: Colors.white),
        );

    return Container(
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: HavenColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFD6E0D7), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          field(name, 'Medication name'),
          field(dose, 'Dose (e.g. 50 mg)'),
          const SizedBox(height: 4),
          Eyebrow('When', size: 11),
          const SizedBox(height: 8),
          Row(
            children: [
              for (final t in kMedTimes) ...[
                Expanded(
                  child: _MiniChip(
                    label: t,
                    selected: times.contains(t),
                    onTap: () => onToggleTime(t),
                    selectedColor: HavenColors.sageDeep,
                    selectedText: HavenColors.cream,
                  ),
                ),
                if (t != kMedTimes.last) const SizedBox(width: 7),
              ],
            ],
          ),
          const SizedBox(height: 13),
          Eyebrow('Form', size: 11),
          const SizedBox(height: 8),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: kMedForms
                .map((f) => _MiniChip(
                      label: f,
                      selected: form == f,
                      onTap: () => onSetForm(f),
                      selectedColor: const Color(0xFFECEAF0),
                      selectedText: const Color(0xFF7A6C8A),
                      selectedBorder: const Color(0xFFCDC4D6),
                      expand: false,
                    ))
                .toList(),
          ),
          const SizedBox(height: 13),
          field(purpose, "What it's for (optional)"),
          field(prescriber, 'Prescriber (optional)'),
          field(supply, 'Days of supply left (optional)', type: TextInputType.number),
          const SizedBox(height: 3),
          Row(
            children: [
              Expanded(
                child: PrimaryButton(
                    label: saving ? 'Saving…' : 'Save',
                    radius: 13,
                    fontSize: 14,
                    padding: 12,
                    enabled: !saving,
                    onTap: onSave),
              ),
              const SizedBox(width: 9),
              GestureDetector(
                onTap: onCancel,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  decoration: BoxDecoration(
                      color: const Color(0xFFEFE9DD), borderRadius: BorderRadius.circular(13)),
                  child: Text('Cancel',
                      style: hank(size: 14, weight: FontWeight.w600, color: HavenColors.muted)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  const _MiniChip({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.selectedColor,
    required this.selectedText,
    this.selectedBorder,
    this.expand = true,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color selectedColor;
  final Color selectedText;
  final Color? selectedBorder;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final chip = GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.symmetric(horizontal: expand ? 4 : 13, vertical: expand ? 9 : 8),
        alignment: expand ? Alignment.center : null,
        decoration: BoxDecoration(
          color: selected ? selectedColor : Colors.white,
          borderRadius: BorderRadius.circular(11),
          border: Border.all(
              color: selected ? (selectedBorder ?? selectedColor) : HavenColors.borderWarm,
              width: 1.5),
        ),
        child: Text(label,
            style: hank(
                size: expand ? 12 : 12.5,
                weight: FontWeight.w600,
                color: selected ? selectedText : HavenColors.muted2)),
      ),
    );
    return chip;
  }
}

class _DashedAdd extends StatelessWidget {
  const _DashedAdd({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.only(top: 14),
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFD3CBBB), width: 1.5),
        ),
        child: Center(
          child: Text(label,
              style: hank(size: 14.5, weight: FontWeight.w600, color: HavenColors.sageDeep)),
        ),
      ),
    );
  }
}
