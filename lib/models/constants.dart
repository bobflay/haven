import 'package:flutter/material.dart';
import '../theme/haven_theme.dart';

/// A nervous-system "wiring" state (the HW/RF/TZ/FC chips).
class EnergyState {
  final String code;
  final String label;
  final String desc;
  final Color color;
  const EnergyState(this.code, this.label, this.desc, this.color);
}

const List<EnergyState> kStates = [
  EnergyState('HW', 'Wired', 'Mind racing, body moving.', HavenColors.clay),
  EnergyState('RF', 'Restless Fog', 'Body twitchy, brain empty.', HavenColors.blue),
  EnergyState('TZ', 'Trapped', "Body dead tired, mind won't stop.", HavenColors.dusk),
  EnergyState('FC', 'Flatline', 'Total system shutdown.', HavenColors.slate),
];

EnergyState stateMeta(String code) =>
    kStates.firstWhere((s) => s.code == code, orElse: () => kStates[1]);

/// A core feeling on the emotion wheel, with its outer "shades".
class EmotionCore {
  final String key;
  final String label;
  final Color color;
  final List<String> subs;
  const EmotionCore(this.key, this.label, this.color, this.subs);
}

const List<EmotionCore> kCores = [
  EmotionCore('peaceful', 'Peaceful', Color(0xFF7C9885),
      ['Content', 'Safe', 'Calm', 'Relieved', 'Grateful']),
  EmotionCore('hopeful', 'Hopeful', Color(0xFF8AA9B0),
      ['Open', 'Curious', 'Encouraged', 'Proud', 'Capable']),
  EmotionCore('sad', 'Sad', Color(0xFF8190A8),
      ['Lonely', 'Empty', 'Hurt', 'Ashamed', 'Tearful']),
  EmotionCore('anxious', 'Anxious', Color(0xFFBCA06A),
      ['On edge', 'Panicked', 'Restless', 'Dread', 'Tense']),
  EmotionCore('angry', 'Angry', Color(0xFFC08A72),
      ['Irritated', 'Frustrated', 'Resentful', 'Defensive', 'Bitter']),
  EmotionCore('numb', 'Numb', Color(0xFF9B8AA8),
      ['Flat', 'Distant', 'Bored', 'Apathetic', 'Foggy']),
];

/// Craving-intensity colour band: low → sage, moderate → amber, severe → clay.
Color intColorFor(num v) =>
    v <= 3 ? HavenColors.sage : (v <= 6 ? HavenColors.amber : HavenColors.clay);

String intBandFor(num v) => v <= 3 ? 'Low' : (v <= 6 ? 'Moderate' : 'Severe');

const List<String> kPeriods = ['AM', 'PM'];
const List<String> kPlaces = ['Safe-Zone', 'Unsafe-Zone'];
const List<String> kDurations = ['< 15 min', '15–30 min', '~1 hour', 'Lingering all day'];
const List<String> kTriggers = ['Physical', 'Environmental', 'Emotional'];
const List<String> kAutopilots = ['Isolation', 'Pacing', 'Avoidance', 'Defensiveness', 'Snapping'];
const List<String> kSleepHours = ['< 4h', '4–6h', '6–8h', '8h+'];
const List<String> kMedTimes = ['Morning', 'Midday', 'Evening', 'Night'];
const List<String> kMedForms = ['tablet', 'capsule', 'liquid', 'injection'];
const List<String> kOutcomes = ['De-escalated', 'Stayed steady', 'Got worse'];
const List<String> kExportRanges = ['Last 7 days', 'Last 30 days', 'All time'];
