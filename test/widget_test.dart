// Unit tests for Haven's data parsing and derived helpers.

import 'package:flutter_test/flutter_test.dart';

import 'package:haven_app/models/content.dart';
import 'package:haven_app/models/models.dart';
import 'package:haven_app/theme/haven_theme.dart';

/// A small slice of the `GET /content` payload, enough to exercise the helpers.
final _content = AppContent.fromJson({
  'states': [
    {'code': 'HW', 'label': 'Wired', 'desc': 'Mind racing, body moving.', 'color': '#C08A72'},
    {'code': 'RF', 'label': 'Restless Fog', 'desc': 'Body twitchy, brain empty.', 'color': '#8198AD'},
    {'code': 'TZ', 'label': 'Trapped', 'desc': "Body dead tired.", 'color': '#9B8AA8'},
    {'code': 'FC', 'label': 'Flatline', 'desc': 'Total system shutdown.', 'color': '#7A8893'},
  ],
  'intensity_bands': [
    {'max': 3, 'label': 'Low', 'color': '#7C9885'},
    {'max': 6, 'label': 'Moderate', 'color': '#BCA06A'},
    {'max': 10, 'label': 'Severe', 'color': '#C08A72'},
  ],
});

void main() {
  test('Entry.fromJson parses the API shape', () {
    final e = Entry.fromJson({
      'id': 1,
      'occurred_at': '2026-06-27T15:00:00.000000Z',
      'period': 'PM',
      'place': 'Safe-Zone',
      'state': 'TZ',
      'energy': 6,
      'intensity': 6,
      'duration': '~1 hour',
      'trigger': 'Emotional',
      'note': null,
      'mood': {
        'anxiety': 4,
        'irritability': 3,
        'depression': 3,
        'apathy': 2,
        'peace': 2,
        'connection': 2,
      },
      'sleep_hours': null,
      'sleep_quality': 3,
      'autopilot': <String>[],
      'coping': true,
      'outcome': 'De-escalated',
    });
    expect(e.state, 'TZ');
    expect(e.intensity, 6);
    expect(e.mood.anxiety, 4);
    expect(e.coping, true);
    expect(e.outcome, 'De-escalated');
  });

  test('Medication.fromJson surfaces today\'s taken slots', () {
    final m = Medication.fromJson({
      'id': 2,
      'name': 'Naltrexone',
      'dose': '50 mg',
      'form': 'tablet',
      'times': ['Morning'],
      'taken': ['Morning'],
    });
    expect(m.times, ['Morning']);
    expect(m.taken.contains('Morning'), isTrue);
  });

  test('Doctor.initials takes the first two name tokens (design behaviour)', () {
    expect(Doctor(name: 'Dr. Amara Osei', role: 'Psychiatrist').initials, 'DA');
    expect(Doctor(name: 'Jordan Reyes, LCSW', role: 'Counselor').initials, 'JR');
  });

  test('intensity colour bands match the design', () {
    expect(_content.intColor(3), HavenColors.sage);
    expect(_content.intColor(5), HavenColors.amber);
    expect(_content.intColor(9), HavenColors.clay);
    expect(_content.intBand(2), 'Low');
    expect(_content.intBand(5), 'Moderate');
    expect(_content.intBand(8), 'Severe');
  });

  test('stateMeta resolves energy-state codes', () {
    expect(_content.stateMeta('HW').label, 'Wired');
    expect(_content.stateMeta('FC').color, HavenColors.slate);
  });

  test('Mood.withKey updates immutably', () {
    const m = Mood();
    final updated = m.withKey('peace', 5);
    expect(m.peace, 2);
    expect(updated.peace, 5);
    expect(updated.anxiety, 2);
  });
}
