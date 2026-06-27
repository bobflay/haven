import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/constants.dart';
import '../models/models.dart';
import '../state/data_store.dart';
import '../state/nav_state.dart';
import '../theme/haven_theme.dart';
import '../widgets/fade_up.dart';
import '../widgets/haven_widgets.dart';
import 'log_flow_widgets.dart';

const _steps = ['time', 'place', 'state', 'energy', 'intensity', 'duration', 'trigger', 'emotions', 'sleep', 'coping', 'saved'];
const _titles = ['Timing', 'Place', 'State', 'Energy', 'Intensity', 'Duration', 'Trigger', 'Emotions', 'Rest', 'Response', 'Saved'];

class LogFlowScreen extends StatefulWidget {
  const LogFlowScreen({super.key});

  @override
  State<LogFlowScreen> createState() => _LogFlowScreenState();
}

class _LogFlowScreenState extends State<LogFlowScreen> {
  int step = 0;
  bool saving = false;

  // draft
  String period = 'PM';
  String? place;
  String? state;
  int energy = 5;
  int intensity = 5;
  String? duration;
  String? trigger;
  final note = TextEditingController();
  Mood mood = const Mood();
  String? sleepHours;
  int sleepQual = 3;
  List<String> autopilot = [];
  bool? coping;
  String? outcome;

  @override
  void dispose() {
    note.dispose();
    super.dispose();
  }

  String get _stepKey => _steps[step];

  bool get _ready => switch (_stepKey) {
        'place' => place != null,
        'state' => state != null,
        'duration' => duration != null,
        'trigger' => trigger != null,
        'coping' => outcome != null,
        _ => true,
      };

  Future<void> _next() async {
    final nav = context.read<NavState>();
    if (_stepKey == 'coping') {
      // commit, then show the summary
      setState(() => saving = true);
      try {
        await context.read<DataStore>().addEntry(_payload());
        if (mounted) setState(() => step = _steps.length - 1);
      } catch (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not save that moment. Try again.')),
          );
        }
      } finally {
        if (mounted) setState(() => saving = false);
      }
    } else if (_stepKey == 'saved') {
      nav.go(HavenScreen.home);
    } else {
      setState(() => step += 1);
    }
  }

  void _back() {
    final nav = context.read<NavState>();
    if (step == 0) {
      nav.go(HavenScreen.home);
    } else {
      setState(() => step -= 1);
    }
  }

  Map<String, dynamic> _payload() => {
        'occurred_at': DateTime.now().toUtc().toIso8601String(),
        'period': period,
        'place': place ?? 'Safe-Zone',
        'state': state ?? 'RF',
        'energy': energy,
        'intensity': intensity,
        'duration': duration ?? '15–30 min',
        'trigger': trigger ?? 'Emotional',
        'note': note.text.trim().isEmpty ? null : note.text.trim(),
        'mood': mood.toJson(),
        'sleep_hours': sleepHours,
        'sleep_quality': sleepQual,
        'autopilot': autopilot,
        'coping': coping,
        'outcome': outcome ?? 'Stayed steady',
      };

  @override
  Widget build(BuildContext context) {
    final nav = context.read<NavState>();
    final progress = step / (_steps.length - 1);
    final nextLabel = _stepKey == 'coping'
        ? 'Save this moment'
        : (_stepKey == 'saved' ? 'Back to today' : 'Continue');

    return ColoredBox(
      color: HavenColors.cream,
      child: Column(
        children: [
          // header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 58, 20, 14),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GlyphButton(glyph: '‹', onTap: _back),
                    Eyebrow(_titles[step], size: 12),
                    GlyphButton(
                        glyph: '×',
                        align: TextAlign.right,
                        color: HavenColors.faint,
                        onTap: () => nav.go(HavenScreen.home)),
                  ],
                ),
                const SizedBox(height: 14),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
                    height: 5,
                    color: const Color(0xFFE6DFD1),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: progress.clamp(0.0, 1.0),
                      child: Container(
                        decoration: BoxDecoration(
                            color: const Color(0xFF82997F), borderRadius: BorderRadius.circular(4)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // step body
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(22, 12, 22, 20),
              child: FadeUp(
                key: ValueKey(step),
                duration: const Duration(milliseconds: 350),
                child: _buildStep(),
              ),
            ),
          ),
          // footer
          Container(
            padding: const EdgeInsets.fromLTRB(22, 12, 22, 30),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [HavenColors.cream, Color(0x00F7F3EC)],
                stops: [0.7, 1.0],
              ),
            ),
            child: PrimaryButton(
              label: saving ? 'Saving…' : nextLabel,
              radius: 17,
              enabled: _ready && !saving,
              onTap: _next,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep() => switch (_stepKey) {
        'time' => _timeStep(),
        'place' => _placeStep(),
        'state' => _stateStep(),
        'energy' => _energyStep(),
        'intensity' => _intensityStep(),
        'duration' => _durationStep(),
        'trigger' => _triggerStep(),
        'emotions' => _emotionsStep(),
        'sleep' => _sleepStep(),
        'coping' => _copingStep(),
        _ => _savedStep(),
      };

  // --- steps ----------------------------------------------------------------
  Widget _timeStep() {
    return _StepShell(
      title: 'When is this happening?',
      child: Row(
        children: [
          for (final p in kPeriods) ...[
            Expanded(
              child: BigChoice(
                big: p,
                desc: p == 'AM' ? 'Morning hours' : 'Afternoon / night',
                selected: period == p,
                onTap: () => setState(() => period = p),
              ),
            ),
            if (p == 'AM') const SizedBox(width: 12),
          ],
        ],
      ),
    );
  }

  Widget _placeStep() {
    final descs = {
      'Safe-Zone': 'Inside the hospital — supported, contained.',
      'Unsafe-Zone': 'Outside — more exposure, fewer guardrails.',
    };
    return _StepShell(
      title: 'Where are you?',
      child: Column(
        children: [
          for (final p in kPlaces)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: SelectChip(
                label: p == 'Safe-Zone' ? 'Safe Zone' : 'Unsafe Zone',
                desc: descs[p],
                selected: place == p,
                onTap: () => setState(() => place = p),
              ),
            ),
        ],
      ),
    );
  }

  Widget _stateStep() {
    Widget card(EnergyState s) => StateChoice(
          state: s,
          selected: state == s.code,
          onTap: () => setState(() => state = s.code),
        );
    return _StepShell(
      title: "What's your wiring like?",
      subtitle: "Body and mind don't always move together.",
      // A responsive 2-column grid with equal-height rows.
      child: Column(
        children: [
          for (var i = 0; i < kStates.length; i += 2)
            Padding(
              padding: EdgeInsets.only(bottom: i + 2 < kStates.length ? 11 : 0),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(child: card(kStates[i])),
                    const SizedBox(width: 11),
                    Expanded(
                      child: i + 1 < kStates.length ? card(kStates[i + 1]) : const SizedBox(),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _energyStep() {
    final label = energy <= 3
        ? 'Running on empty'
        : (energy <= 6 ? 'Somewhere in the middle' : 'Buzzing, hard to settle');
    return _StepShell(
      title: "How's your energy?",
      subtitle: 'Drained on the left, electric on the right.',
      child: Column(
        children: [
          Text('$energy', style: news(size: 64, height: 1.0, color: HavenColors.sageDeep)),
          const SizedBox(height: 8),
          Text(label, style: hank(size: 14, weight: FontWeight.w500, color: HavenColors.muted2)),
          const SizedBox(height: 26),
          DotScale(
            count: 10,
            value: energy,
            onTap: (n) => setState(() => energy = n),
            colorFor: (n) => HavenColors.sageDeep.withValues(alpha: (0.45 + n * 0.055).clamp(0.0, 1.0)),
          ),
          const SizedBox(height: 10),
          _ScaleEnds(left: 'Depleted', right: 'Wired'),
        ],
      ),
    );
  }

  Widget _intensityStep() {
    final ic = intColorFor(intensity);
    final hint = intensity <= 3
        ? 'A passing thought, easily redirected.'
        : (intensity <= 6
            ? 'Persistent — worth actively using a coping skill.'
            : 'Intense urge. Consider changing your physical environment or reaching out now.');
    return _StepShell(
      title: 'How strong is the craving?',
      subtitle: 'No wrong answer — just notice.',
      child: Column(
        children: [
          Text('$intensity', style: news(size: 64, height: 1.0, color: ic)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(color: ic, borderRadius: BorderRadius.circular(20)),
            child: Text(intBandFor(intensity),
                style: hank(size: 13, weight: FontWeight.w600, color: Colors.white)),
          ),
          const SizedBox(height: 26),
          DotScale(
            count: 10,
            value: intensity,
            onTap: (n) => setState(() => intensity = n),
            colorFor: (_) => ic,
          ),
          const SizedBox(height: 18),
          HavenCard(
            radius: 14,
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
            child: Text(hint, style: hank(size: 13.5, height: 1.5, color: HavenColors.muted)),
          ),
        ],
      ),
    );
  }

  Widget _durationStep() {
    return _StepShell(
      title: 'How long did it last?',
      subtitle: 'Most urges peak and fade within 20–30 minutes.',
      child: Column(
        children: [
          for (final d in kDurations)
            Padding(
              padding: const EdgeInsets.only(bottom: 11),
              child: SelectChip(
                label: d,
                selected: duration == d,
                onTap: () => setState(() => duration = d),
                radius: 15,
                bold: true,
              ),
            ),
        ],
      ),
    );
  }

  Widget _triggerStep() {
    final descs = {
      'Physical': 'Fatigue, pain, hunger (HALT).',
      'Environmental': 'A time of day, a memory, a place, media.',
      'Emotional': 'Stress, boredom, emptiness, anger.',
    };
    return _StepShell(
      title: 'What set it off?',
      child: Column(
        children: [
          for (final t in kTriggers)
            Padding(
              padding: const EdgeInsets.only(bottom: 11),
              child: SelectChip(
                label: t,
                desc: descs[t],
                selected: trigger == t,
                onTap: () => setState(() => trigger = t),
              ),
            ),
          const SizedBox(height: 5),
          HavenField(
            controller: note,
            hint: 'Name it, if you can. (optional)',
            minLines: 3,
            maxLines: 4,
            borderColor: HavenColors.borderWarm,
          ),
        ],
      ),
    );
  }

  Widget _emotionsStep() {
    final groups = [
      ('High activation', HavenColors.clay, [
        ('anxiety', 'Anxiety / panic'),
        ('irritability', 'Irritability / anger'),
      ]),
      ('Low activation', HavenColors.dusk, [
        ('depression', 'Depression / sadness'),
        ('apathy', 'Apathy / numbness'),
      ]),
      ('Grounded', HavenColors.sage, [
        ('peace', 'Peace / comfort'),
        ('connection', 'Connection'),
      ]),
    ];
    return _StepShell(
      title: "What's present emotionally?",
      subtitle: 'Slide each to where it sits. 1 is barely, 5 is a lot.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: groups.map((g) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Eyebrow(g.$1, color: g.$2, size: 11),
                const SizedBox(height: 12),
                ...g.$3.map((m) => MoodSlider(
                      label: m.$2,
                      value: mood.byKey(m.$1),
                      color: g.$2,
                      onChanged: (v) => setState(() => mood = mood.withKey(m.$1, v)),
                    )),
                const SizedBox(height: 6),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _sleepStep() {
    return _StepShell(
      title: 'How did you sleep?',
      subtitle: 'Rest shapes everything that follows.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Eyebrow('Hours slept', size: 12),
          const SizedBox(height: 12),
          Row(
            children: [
              for (final h in kSleepHours) ...[
                Expanded(
                  child: SelectChip(
                    label: h,
                    selected: sleepHours == h,
                    onTap: () => setState(() => sleepHours = h),
                    radius: 13,
                    bold: true,
                    centered: true,
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
                    fontSize: 13.5,
                  ),
                ),
                if (h != kSleepHours.last) const SizedBox(width: 9),
              ],
            ],
          ),
          const SizedBox(height: 28),
          Eyebrow('Quality', size: 12),
          const SizedBox(height: 12),
          QualityDots(value: sleepQual, onTap: (n) => setState(() => sleepQual = n)),
          const SizedBox(height: 9),
          _ScaleEnds(left: 'Restless', right: 'Deep'),
        ],
      ),
    );
  }

  Widget _copingStep() {
    return _StepShell(
      title: 'What did you do with it?',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Eyebrow('Autopilot pulls (any that fit)', size: 12),
          const SizedBox(height: 12),
          Wrap(
            spacing: 9,
            runSpacing: 9,
            children: kAutopilots.map((a) {
              final on = autopilot.contains(a);
              return PillChip(
                label: a,
                selected: on,
                onTap: () => setState(() {
                  if (on) {
                    autopilot = autopilot.where((x) => x != a).toList();
                  } else {
                    autopilot = [...autopilot, a];
                  }
                }),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          Eyebrow('Did you reach for a coping tool?', size: 12),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: SelectChip(
                  label: 'Yes, I reached for one',
                  selected: coping == true,
                  onTap: () => setState(() => coping = true),
                  radius: 15,
                  bold: true,
                  centered: true,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SelectChip(
                  label: 'Not this time',
                  selected: coping == false,
                  onTap: () => setState(() => coping = false),
                  radius: 15,
                  bold: true,
                  centered: true,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Eyebrow('And the outcome?', size: 12),
          const SizedBox(height: 12),
          ...[
            ('De-escalated', 'It helped — the feeling eased'),
            ('Stayed steady', 'It held steady'),
            ('Got worse', 'It got more intense'),
          ].map((o) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: SelectChip(
                  label: o.$2,
                  selected: outcome == o.$1,
                  onTap: () => setState(() => outcome = o.$1),
                  radius: 15,
                  bold: true,
                  fontSize: 14.5,
                ),
              )),
        ],
      ),
    );
  }

  Widget _savedStep() {
    final rows = [
      ('When', '$period · ${place ?? '—'}'),
      ('State', stateMeta(state ?? 'RF').label),
      ('Craving', '$intensity/10 · ${intBandFor(intensity)}'),
      ('Trigger', trigger ?? '—'),
      ('Outcome', outcome ?? '—'),
    ];
    return Column(
      children: [
        const SizedBox(height: 12),
        Container(
          width: 64,
          height: 64,
          decoration: const BoxDecoration(color: HavenColors.greenTint, shape: BoxShape.circle),
          child: const Center(child: Icon(Icons.check, size: 30, color: HavenColors.sageDeep)),
        ),
        const SizedBox(height: 18),
        Text("It's witnessed.", style: news(size: 28, height: 1.2)),
        const SizedBox(height: 8),
        Text('You named it instead of feeding it. That counts.',
            textAlign: TextAlign.center, style: hank(size: 15, height: 1.5, color: HavenColors.muted)),
        const SizedBox(height: 22),
        HavenCard(
          radius: 20,
          child: Column(
            children: rows.map((r) {
              final isLast = r == rows.last;
              return Container(
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  border: isLast
                      ? null
                      : const Border(bottom: BorderSide(color: Color(0xFFF0EBE0))),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(r.$1, style: hank(size: 13.5, color: HavenColors.muted2)),
                    Flexible(
                      child: Text(r.$2,
                          textAlign: TextAlign.right,
                          style: hank(size: 14, weight: FontWeight.w600)),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

/// Step heading + subtitle + body.
class _StepShell extends StatelessWidget {
  const _StepShell({required this.title, this.subtitle, required this.child});
  final String title;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text(title, style: news(size: 27, height: 1.25)),
        if (subtitle != null) ...[
          const SizedBox(height: 6),
          Text(subtitle!, style: hank(size: 14, color: HavenColors.muted)),
        ],
        SizedBox(height: subtitle != null ? 20 : 24),
        child,
      ],
    );
  }
}

class _ScaleEnds extends StatelessWidget {
  const _ScaleEnds({required this.left, required this.right});
  final String left;
  final String right;

  @override
  Widget build(BuildContext context) {
    final s = hank(size: 12, weight: FontWeight.w500, color: HavenColors.faint);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [Text(left, style: s), Text(right, style: s)],
    );
  }
}
