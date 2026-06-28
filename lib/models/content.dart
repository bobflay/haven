import 'package:flutter/material.dart';

/// Parse a `#RRGGBB` (or `#AARRGGBB`) hex string from the API into a [Color].
Color havenHex(String s) {
  var h = s.replaceFirst('#', '').trim();
  if (h.length == 6) h = 'FF$h';
  return Color(int.parse(h, radix: 16));
}

String _s(dynamic v) => (v ?? '').toString();
List<String> _strings(dynamic v) => ((v ?? []) as List).map((e) => e.toString()).toList();

/// A nervous-system "wiring" state (the HW/RF/TZ/FC chips).
class EnergyState {
  final String code;
  final String label;
  final String desc;
  final Color color;
  const EnergyState(this.code, this.label, this.desc, this.color);

  factory EnergyState.fromJson(Map<String, dynamic> j) =>
      EnergyState(_s(j['code']), _s(j['label']), _s(j['desc']), havenHex(_s(j['color'])));
}

/// A core feeling on the emotion wheel, with its outer "shades".
class EmotionCore {
  final String key;
  final String label;
  final Color color;
  final List<String> subs;
  const EmotionCore(this.key, this.label, this.color, this.subs);

  factory EmotionCore.fromJson(Map<String, dynamic> j) =>
      EmotionCore(_s(j['key']), _s(j['label']), havenHex(_s(j['color'])), _strings(j['subs']));
}

/// A craving-intensity band: everything up to [max] reads as [label]/[color].
class IntensityBand {
  final int max;
  final String label;
  final Color color;
  const IntensityBand(this.max, this.label, this.color);

  factory IntensityBand.fromJson(Map<String, dynamic> j) =>
      IntensityBand((j['max'] as num).toInt(), _s(j['label']), havenHex(_s(j['color'])));
}

/// A threshold-keyed piece of copy (energy read-out, intensity hint): the
/// [text] applies to any value up to [max].
class Threshold {
  final int max;
  final String text;
  const Threshold(this.max, this.text);

  factory Threshold.fromJson(Map<String, dynamic> j) =>
      Threshold((j['max'] as num).toInt(), _s(j['text']));
}

/// A `value` plus an optional human label/description, used for the log-flow
/// single-choice form options (periods, places, triggers, outcomes).
class ContentOption {
  final String value;
  final String? label;
  final String? desc;
  const ContentOption(this.value, this.label, this.desc);

  factory ContentOption.fromJson(Map<String, dynamic> j) =>
      ContentOption(_s(j['value']), j['label'] as String?, j['desc'] as String?);

  /// The display label, falling back to the raw value.
  String get display => label ?? value;
}

/// One mood slider (key + label) inside an [EmotionGroup].
class MoodItem {
  final String key;
  final String label;
  const MoodItem(this.key, this.label);

  factory MoodItem.fromJson(Map<String, dynamic> j) => MoodItem(_s(j['key']), _s(j['label']));
}

/// A coloured group of mood sliders on the "what's present emotionally" step.
class EmotionGroup {
  final String label;
  final Color color;
  final List<MoodItem> items;
  const EmotionGroup(this.label, this.color, this.items);

  factory EmotionGroup.fromJson(Map<String, dynamic> j) => EmotionGroup(
        _s(j['label']),
        havenHex(_s(j['color'])),
        ((j['items'] ?? []) as List)
            .map((e) => MoodItem.fromJson((e as Map).cast<String, dynamic>()))
            .toList(),
      );
}

/// An export format choice (title + description).
class ExportFormat {
  final String title;
  final String desc;
  const ExportFormat(this.title, this.desc);

  factory ExportFormat.fromJson(Map<String, dynamic> j) =>
      ExportFormat(_s(j['title']), _s(j['desc']));
}

/// The whole reference-content bundle served by `GET /content`. Everything the
/// app renders as fixed copy/options lives here instead of being hardcoded.
class AppContent {
  final List<EnergyState> states;
  final List<EmotionCore> emotionCores;
  final List<IntensityBand> intensityBands;
  final List<Threshold> energyLabels;
  final List<Threshold> intensityHints;
  final List<EmotionGroup> emotionGroups;
  final List<ContentOption> periods;
  final List<ContentOption> places;
  final List<String> durations;
  final List<ContentOption> triggers;
  final List<String> autopilots;
  final List<String> sleepHours;
  final List<ContentOption> outcomes;
  final List<String> medTimes;
  final List<String> medForms;
  final List<String> exportRanges;
  final List<ExportFormat> exportFormats;
  final List<String> exportIncluded;
  final List<String> ridePrompts;

  const AppContent({
    required this.states,
    required this.emotionCores,
    required this.intensityBands,
    required this.energyLabels,
    required this.intensityHints,
    required this.emotionGroups,
    required this.periods,
    required this.places,
    required this.durations,
    required this.triggers,
    required this.autopilots,
    required this.sleepHours,
    required this.outcomes,
    required this.medTimes,
    required this.medForms,
    required this.exportRanges,
    required this.exportFormats,
    required this.exportIncluded,
    required this.ridePrompts,
  });

  static List<T> _objs<T>(dynamic v, T Function(Map<String, dynamic>) fromJson) =>
      ((v ?? []) as List).map((e) => fromJson((e as Map).cast<String, dynamic>())).toList();

  factory AppContent.fromJson(Map<String, dynamic> j) => AppContent(
        states: _objs(j['states'], EnergyState.fromJson),
        emotionCores: _objs(j['emotion_cores'], EmotionCore.fromJson),
        intensityBands: _objs(j['intensity_bands'], IntensityBand.fromJson),
        energyLabels: _objs(j['energy_labels'], Threshold.fromJson),
        intensityHints: _objs(j['intensity_hints'], Threshold.fromJson),
        emotionGroups: _objs(j['emotion_groups'], EmotionGroup.fromJson),
        periods: _objs(j['periods'], ContentOption.fromJson),
        places: _objs(j['places'], ContentOption.fromJson),
        durations: _strings(j['durations']),
        triggers: _objs(j['triggers'], ContentOption.fromJson),
        autopilots: _strings(j['autopilots']),
        sleepHours: _strings(j['sleep_hours']),
        outcomes: _objs(j['outcomes'], ContentOption.fromJson),
        medTimes: _strings(j['med_times']),
        medForms: _strings(j['med_forms']),
        exportRanges: _strings(j['export_ranges']),
        exportFormats: _objs(j['export_formats'], ExportFormat.fromJson),
        exportIncluded: _strings(j['export_included']),
        ridePrompts: _strings(j['ride_prompts']),
      );

  // --- helpers replacing the old top-level functions ------------------------

  /// The state metadata for [code], falling back to the second state (the old
  /// `stateMeta` default) and then the first.
  EnergyState stateMeta(String code) => states.firstWhere(
        (s) => s.code == code,
        orElse: () => states.length > 1 ? states[1] : states.first,
      );

  IntensityBand _band(num v) =>
      intensityBands.firstWhere((b) => v <= b.max, orElse: () => intensityBands.last);

  /// Craving-intensity colour band.
  Color intColor(num v) => _band(v).color;

  /// Craving-intensity word band (Low / Moderate / Severe).
  String intBand(num v) => _band(v).label;

  String _threshold(List<Threshold> ts, num v) =>
      ts.firstWhere((t) => v <= t.max, orElse: () => ts.last).text;

  /// Energy-slider read-out for [v].
  String energyLabel(num v) => _threshold(energyLabels, v);

  /// Intensity-slider guidance for [v].
  String intensityHint(num v) => _threshold(intensityHints, v);
}
