import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/models.dart';
import '../state/data_store.dart';
import '../theme/haven_theme.dart';
import '../widgets/fade_up.dart';
import '../widgets/haven_widgets.dart';
import 'deep_scaffold.dart';

class CareTeamScreen extends StatefulWidget {
  const CareTeamScreen({super.key});

  @override
  State<CareTeamScreen> createState() => _CareTeamScreenState();
}

class _CareTeamScreenState extends State<CareTeamScreen> {
  bool formOpen = false;
  bool saving = false;
  final _name = TextEditingController();
  final _role = TextEditingController();
  final _specialty = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _location = TextEditingController();
  final _nextAppt = TextEditingController();

  @override
  void dispose() {
    for (final c in [_name, _role, _specialty, _phone, _email, _location, _nextAppt]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty) return;
    setState(() => saving = true);
    try {
      await context.read<DataStore>().addDoctor({
        'name': _name.text.trim(),
        'role': _role.text.trim().isEmpty ? 'Provider' : _role.text.trim(),
        'specialty': _specialty.text.trim(),
        'phone': _phone.text.trim(),
        'email': _email.text.trim(),
        'location': _location.text.trim(),
        'next_appt': _nextAppt.text.trim(),
      });
      for (final c in [_name, _role, _specialty, _phone, _email, _location, _nextAppt]) {
        c.clear();
      }
      if (mounted) setState(() => formOpen = false);
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<DataStore>();
    final nextDoc = store.nextApptDoctor;

    return DeepScaffold(
      title: 'Care team',
      children: [
        Text('The people in your corner. Keep them a tap away.',
            style: hank(size: 14.5, height: 1.5, color: HavenColors.muted)),
        const SizedBox(height: 18),
        _CrisisCard(contacts: store.crisisContacts, onCall: (tel) => _launch('tel:$tel')),
        const SizedBox(height: 20),
        if (nextDoc != null) ...[
          _NextApptCard(doctor: nextDoc),
          const SizedBox(height: 22),
        ],
        Eyebrow('Your providers'),
        const SizedBox(height: 12),
        ...store.doctors.map((d) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _DoctorCard(doctor: d, launch: _launch),
            )),
        if (formOpen)
          FadeUp(
            duration: const Duration(milliseconds: 300),
            child: _ProviderForm(
              name: _name,
              role: _role,
              specialty: _specialty,
              phone: _phone,
              email: _email,
              location: _location,
              nextAppt: _nextAppt,
              saving: saving,
              onSave: _save,
              onCancel: () => setState(() => formOpen = false),
            ),
          )
        else
          _AddButton(label: '+ Add a provider', onTap: () => setState(() => formOpen = true)),
        const SizedBox(height: 4),
      ],
    );
  }
}

class _CrisisCard extends StatelessWidget {
  const _CrisisCard({required this.contacts, required this.onCall});
  final List<CrisisContact> contacts;
  final ValueChanged<String> onCall;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFC08A72), Color(0xFFA8755E)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('IF THE GROUND GIVES WAY',
              style: hank(
                  size: 11,
                  weight: FontWeight.w600,
                  color: HavenColors.cream.withValues(alpha: 0.85),
                  letterSpacing: 1.2)),
          ...contacts.map((c) => Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.only(top: 11, bottom: 3),
                decoration: BoxDecoration(
                  border:
                      Border(top: BorderSide(color: HavenColors.cream.withValues(alpha: 0.22))),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(c.label,
                              style: hank(size: 15, weight: FontWeight.w600, color: HavenColors.cream)),
                          if (c.sub != null)
                            Text(c.sub!,
                                style: hank(
                                    size: 12.5,
                                    color: HavenColors.cream.withValues(alpha: 0.82))),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => onCall(c.tel),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                        decoration: BoxDecoration(
                          color: HavenColors.cream.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: Text('Call',
                            style:
                                hank(size: 12.5, weight: FontWeight.w600, color: HavenColors.cream)),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

class _NextApptCard extends StatelessWidget {
  const _NextApptCard({required this.doctor});
  final Doctor doctor;

  @override
  Widget build(BuildContext context) {
    return HavenCard(
      radius: 18,
      color: HavenColors.greenTint,
      border: const Color(0xFFD6E0D7),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Eyebrow('Next appointment', color: HavenColors.sageDeep, size: 11),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(doctor.name, style: news(size: 17, weight: FontWeight.w500)),
                    Text(doctor.role, style: hank(size: 12.5, color: HavenColors.muted)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(doctor.nextAppt ?? '',
                      style: news(size: 15, weight: FontWeight.w500, color: const Color(0xFF43503F))),
                  if (doctor.location != null)
                    Text(doctor.location!, style: hank(size: 12, color: HavenColors.muted2)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DoctorCard extends StatelessWidget {
  const _DoctorCard({required this.doctor, required this.launch});
  final Doctor doctor;
  final Future<void> Function(String) launch;

  @override
  Widget build(BuildContext context) {
    final d = doctor;
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
                  color: const Color(0xFFE7EEE8),
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: Text(d.initials,
                    style: hank(size: 15, weight: FontWeight.w600, color: const Color(0xFF5E7A68))),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(d.name,
                              style: news(size: 17, weight: FontWeight.w500),
                              overflow: TextOverflow.ellipsis),
                        ),
                        if (d.isPrimary) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                                color: const Color(0xFFE7EEE8),
                                borderRadius: BorderRadius.circular(6)),
                            child: Text('PRIMARY',
                                style: hank(
                                    size: 10,
                                    weight: FontWeight.w600,
                                    color: const Color(0xFF5E7A68),
                                    letterSpacing: 0.6)),
                          ),
                        ],
                      ],
                    ),
                    Text(d.role,
                        style: hank(size: 12.5, weight: FontWeight.w600, color: HavenColors.sageDeep)),
                    if (d.specialty != null && d.specialty!.isNotEmpty)
                      Text(d.specialty!, style: hank(size: 12.5, color: HavenColors.muted2)),
                  ],
                ),
              ),
            ],
          ),
          if (d.nextAppt != null && d.nextAppt!.isNotEmpty) ...[
            const SizedBox(height: 13),
            Text('Next visit · ${d.nextAppt}',
                style: hank(size: 13, weight: FontWeight.w500, color: const Color(0xFF5A544B))),
          ],
          if (d.location != null && d.location!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(d.location!, style: hank(size: 12.5, color: HavenColors.muted2)),
            ),
          if (d.notes != null && d.notes!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 9),
              child: Text(d.notes!,
                  style: news(size: 13, height: 1.45, italic: true, color: HavenColors.muted)),
            ),
          const SizedBox(height: 14),
          Row(
            children: [
              if (d.phone != null && d.phone!.isNotEmpty)
                _PillAction(
                    label: 'Call',
                    onTap: () => launch('tel:${d.phone!.replaceAll(RegExp(r'[^0-9+]'), '')}')),
              if (d.email != null && d.email!.isNotEmpty)
                _PillAction(label: 'Email', onTap: () => launch('mailto:${d.email}')),
              if (d.location != null && d.location!.isNotEmpty)
                _PillAction(
                    label: 'Directions',
                    onTap: () =>
                        launch('https://maps.google.com/?q=${Uri.encodeComponent(d.location!)}')),
            ],
          ),
        ],
      ),
    );
  }
}

class _PillAction extends StatelessWidget {
  const _PillAction({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(right: 8),
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 9),
            decoration: BoxDecoration(
              color: const Color(0xFFF1ECE1),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Center(
              child: Text(label,
                  style: hank(size: 13, weight: FontWeight.w600, color: const Color(0xFF5E7A68))),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProviderForm extends StatelessWidget {
  const _ProviderForm({
    required this.name,
    required this.role,
    required this.specialty,
    required this.phone,
    required this.email,
    required this.location,
    required this.nextAppt,
    required this.saving,
    required this.onSave,
    required this.onCancel,
  });

  final TextEditingController name, role, specialty, phone, email, location, nextAppt;
  final bool saving;
  final VoidCallback onSave;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    Widget field(TextEditingController c, String hint) => Padding(
          padding: const EdgeInsets.only(bottom: 9),
          child: HavenField(controller: c, hint: hint, borderColor: HavenColors.borderWarm, fillColor: Colors.white),
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
        children: [
          field(name, 'Name'),
          field(role, 'Role (e.g. Psychiatrist)'),
          field(specialty, 'Specialty (optional)'),
          field(phone, 'Phone'),
          field(email, 'Email'),
          field(location, 'Location (optional)'),
          field(nextAppt, 'Next appt (e.g. Thu Jul 2 · 9 AM)'),
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

class _AddButton extends StatelessWidget {
  const _AddButton({required this.label, required this.onTap});
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
