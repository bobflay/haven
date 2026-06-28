import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import '../models/content.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../theme/haven_theme.dart';

// --- small view-model records the screens read --------------------------------

class RecentItem {
  final String code;
  final Color color;
  final String trigger;
  final String when;
  final String place;
  final int intensity;
  final Color intColor;
  RecentItem(this.code, this.color, this.trigger, this.when, this.place, this.intensity, this.intColor);
}

class WeekBar {
  final String day;
  final String label;
  final double fraction; // 0..1 of the chart height
  final Color color;
  WeekBar(this.day, this.label, this.fraction, this.color);
}

class StateDistItem {
  final EnergyState state;
  final int count;
  final double fraction;
  StateDistItem(this.state, this.count, this.fraction);
}

class MoodBar {
  final String label;
  final Color color;
  final String value;
  final double fraction;
  MoodBar(this.label, this.color, this.value, this.fraction);
}

class DoseItem {
  final int medId;
  final String medName;
  final String dose;
  final String slot;
  final bool taken;
  DoseItem(this.medId, this.medName, this.dose, this.slot, this.taken);
}

/// The single source of truth for everything inside an authenticated session.
class DataStore extends ChangeNotifier {
  DataStore(this.api);
  final ApiService api;

  List<Entry> entries = [];
  List<Doctor> doctors = [];
  List<Medication> medications = [];
  List<CrisisContact> crisisContacts = [];
  List<ChatMessage> chat = [];

  /// Reference copy + form options served by the API. Non-null once [loadAll]
  /// completes (the shell gates every screen behind [loading] until then).
  late AppContent content;

  bool loading = true;
  bool chatBusy = false;

  Future<void> loadAll() async {
    loading = true;
    notifyListeners();
    final results = await Future.wait([
      api.getContent(),
      api.getEntries(),
      api.getDoctors(),
      api.getMedications(),
      api.getCrisisContacts(),
      api.getChat(),
    ]);
    content = results[0] as AppContent;
    entries = results[1] as List<Entry>;
    doctors = results[2] as List<Doctor>;
    medications = results[3] as List<Medication>;
    crisisContacts = results[4] as List<CrisisContact>;
    chat = results[5] as List<ChatMessage>;
    loading = false;
    notifyListeners();
  }

  void reset() {
    entries = [];
    doctors = [];
    medications = [];
    crisisContacts = [];
    chat = [];
    loading = true;
    chatBusy = false;
  }

  // --- mutations ------------------------------------------------------------
  Future<void> addEntry(Map<String, dynamic> payload) async {
    final entry = await api.createEntry(payload);
    entries = [entry, ...entries];
    notifyListeners();
  }

  Future<void> addDoctor(Map<String, dynamic> payload) async {
    final d = await api.createDoctor(payload);
    doctors = [...doctors, d];
    notifyListeners();
  }

  Future<void> deleteDoctor(int id) async {
    await api.deleteDoctor(id);
    doctors = doctors.where((d) => d.id != id).toList();
    notifyListeners();
  }

  Future<void> addMedication(Map<String, dynamic> payload) async {
    final m = await api.createMedication(payload);
    medications = [...medications, m];
    notifyListeners();
  }

  Future<void> deleteMedication(int id) async {
    await api.deleteMedication(id);
    medications = medications.where((m) => m.id != id).toList();
    notifyListeners();
  }

  Future<void> toggleDose(int medId, String slot) async {
    final updated = await api.toggleDose(medId, slot);
    medications = medications.map((m) => m.id == medId ? updated : m).toList();
    notifyListeners();
  }

  Future<void> sendChat(String text) async {
    chat = [...chat, ChatMessage(role: 'user', text: text)];
    chatBusy = true;
    notifyListeners();
    try {
      chat = await api.sendChat(text);
    } finally {
      chatBusy = false;
      notifyListeners();
    }
  }

  // --- derived: home --------------------------------------------------------
  bool _sameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

  int get todayCount {
    final now = DateTime.now();
    return entries.where((e) => _sameDay(e.occurredAt, now)).length;
  }

  Entry? get lastEntry => entries.isEmpty ? null : entries.first;

  String _formatWhen(DateTime ts) {
    final now = DateTime.now();
    final time = DateFormat('h:mm a').format(ts);
    if (_sameDay(ts, now)) return 'Today, $time';
    final midnightNow = DateTime(now.year, now.month, now.day);
    final midnightTs = DateTime(ts.year, ts.month, ts.day);
    if (midnightNow.difference(midnightTs).inDays == 1) return 'Yesterday, $time';
    return '${DateFormat('EEE').format(ts)}, $time';
  }

  List<RecentItem> get recent => entries.take(3).map((e) {
        final meta = content.stateMeta(e.state);
        return RecentItem(e.state, meta.color, e.trigger, _formatWhen(e.occurredAt), e.place,
            e.intensity, content.intColor(e.intensity));
      }).toList();

  // --- derived: history -----------------------------------------------------
  List<WeekBar> get weekBars {
    final now = DateTime.now();
    final bars = <WeekBar>[];
    for (var i = 6; i >= 0; i--) {
      final dt = now.subtract(Duration(days: i));
      final dayEntries = entries.where((e) => _sameDay(e.occurredAt, dt)).toList();
      final avg = dayEntries.isEmpty
          ? 0.0
          : dayEntries.map((e) => e.intensity).reduce((a, b) => a + b) / dayEntries.length;
      final fraction = avg == 0 ? 0.0 : ((12 + avg / 10 * 100) / 100).clamp(0.0, 1.0);
      bars.add(WeekBar(
        DateFormat('EEEEE').format(dt), // narrow weekday (M, T, W…)
        avg == 0 ? '' : avg.toStringAsFixed(0),
        fraction,
        avg == 0 ? HavenColors.borderWarm : content.intColor(avg),
      ));
    }
    return bars;
  }

  List<StateDistItem> get stateDist {
    final states = content.states;
    final counts = {for (final s in states) s.code: 0};
    for (final e in entries) {
      if (counts.containsKey(e.state)) counts[e.state] = counts[e.state]! + 1;
    }
    final maxC = [1, ...counts.values].reduce((a, b) => a > b ? a : b);
    return states.map((s) => StateDistItem(s, counts[s.code]!, counts[s.code]! / maxC)).toList();
  }

  double _moodAvg(String key) {
    if (entries.isEmpty) return 0;
    return entries.map((e) => e.mood.byKey(key)).reduce((a, b) => a + b) / entries.length;
  }

  List<MoodBar> get moodBars {
    final groups = [
      ('Anxiety & anger', HavenColors.clay, 'anxiety', 'irritability'),
      ('Low & numb', HavenColors.dusk, 'depression', 'apathy'),
      ('Peace & connection', HavenColors.sage, 'peace', 'connection'),
    ];
    return groups.map((g) {
      final v = (_moodAvg(g.$3) + _moodAvg(g.$4)) / 2;
      return MoodBar(g.$1, g.$2, v.toStringAsFixed(1), (v / 5).clamp(0.0, 1.0));
    }).toList();
  }

  String get insight {
    if (entries.isEmpty) return 'Once you log a few moments, gentle patterns will surface here.';
    final tcount = <String, int>{};
    for (final e in entries) {
      tcount[e.trigger] = (tcount[e.trigger] ?? 0) + 1;
    }
    final topTrig =
        (tcount.entries.toList()..sort((a, b) => b.value.compareTo(a.value))).first.key;
    final pmCount = entries.where((e) => e.period == 'PM').length;
    final evening = pmCount > entries.length / 2;
    return '$topTrig triggers show up most for you'
        '${evening ? ', and they cluster in the evenings.' : ' lately.'}';
  }

  // --- derived: medications -------------------------------------------------
  static const _timeOrder = ['Morning', 'Midday', 'Evening', 'Night'];

  List<DoseItem> get todaysDoses {
    final list = <DoseItem>[];
    for (final m in medications) {
      for (final slot in m.times) {
        list.add(DoseItem(m.id ?? 0, m.name, m.dose, slot, m.taken.contains(slot)));
      }
    }
    list.sort((a, b) => _timeOrder.indexOf(a.slot).compareTo(_timeOrder.indexOf(b.slot)));
    return list;
  }

  int get adherenceTaken => todaysDoses.where((d) => d.taken).length;
  int get adherenceTotal => todaysDoses.length;
  double get adherenceFraction => adherenceTotal == 0 ? 0 : adherenceTaken / adherenceTotal;

  Doctor? get nextApptDoctor {
    for (final d in doctors) {
      if (d.nextAppt != null && d.nextAppt!.isNotEmpty) return d;
    }
    return null;
  }
}
