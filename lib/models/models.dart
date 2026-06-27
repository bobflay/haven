// Plain data models mirroring the Laravel API JSON shapes.

class Mood {
  final int anxiety;
  final int irritability;
  final int depression;
  final int apathy;
  final int peace;
  final int connection;

  const Mood({
    this.anxiety = 2,
    this.irritability = 2,
    this.depression = 2,
    this.apathy = 2,
    this.peace = 2,
    this.connection = 2,
  });

  Mood copyWith({int? anxiety, int? irritability, int? depression, int? apathy, int? peace, int? connection}) {
    return Mood(
      anxiety: anxiety ?? this.anxiety,
      irritability: irritability ?? this.irritability,
      depression: depression ?? this.depression,
      apathy: apathy ?? this.apathy,
      peace: peace ?? this.peace,
      connection: connection ?? this.connection,
    );
  }

  int byKey(String key) => switch (key) {
        'anxiety' => anxiety,
        'irritability' => irritability,
        'depression' => depression,
        'apathy' => apathy,
        'peace' => peace,
        _ => connection,
      };

  Mood withKey(String key, int value) => switch (key) {
        'anxiety' => copyWith(anxiety: value),
        'irritability' => copyWith(irritability: value),
        'depression' => copyWith(depression: value),
        'apathy' => copyWith(apathy: value),
        'peace' => copyWith(peace: value),
        _ => copyWith(connection: value),
      };

  factory Mood.fromJson(Map<String, dynamic> j) => Mood(
        anxiety: (j['anxiety'] ?? 2) as int,
        irritability: (j['irritability'] ?? 2) as int,
        depression: (j['depression'] ?? 2) as int,
        apathy: (j['apathy'] ?? 2) as int,
        peace: (j['peace'] ?? 2) as int,
        connection: (j['connection'] ?? 2) as int,
      );

  Map<String, dynamic> toJson() => {
        'anxiety': anxiety,
        'irritability': irritability,
        'depression': depression,
        'apathy': apathy,
        'peace': peace,
        'connection': connection,
      };
}

class Entry {
  final int? id;
  final DateTime occurredAt;
  final String period;
  final String place;
  final String state;
  final int energy;
  final int intensity;
  final String duration;
  final String trigger;
  final String? note;
  final Mood mood;
  final String? sleepHours;
  final int sleepQuality;
  final List<String> autopilot;
  final bool? coping;
  final String outcome;

  Entry({
    this.id,
    required this.occurredAt,
    required this.period,
    required this.place,
    required this.state,
    required this.energy,
    required this.intensity,
    required this.duration,
    required this.trigger,
    this.note,
    required this.mood,
    this.sleepHours,
    required this.sleepQuality,
    required this.autopilot,
    this.coping,
    required this.outcome,
  });

  factory Entry.fromJson(Map<String, dynamic> j) => Entry(
        id: j['id'] as int?,
        occurredAt: DateTime.parse(j['occurred_at'] as String).toLocal(),
        period: j['period'] as String,
        place: j['place'] as String,
        state: j['state'] as String,
        energy: (j['energy'] ?? 5) as int,
        intensity: (j['intensity'] ?? 5) as int,
        duration: j['duration'] as String,
        trigger: j['trigger'] as String,
        note: j['note'] as String?,
        mood: Mood.fromJson((j['mood'] as Map).cast<String, dynamic>()),
        sleepHours: j['sleep_hours'] as String?,
        sleepQuality: (j['sleep_quality'] ?? 3) as int,
        autopilot: ((j['autopilot'] ?? []) as List).cast<String>(),
        coping: j['coping'] as bool?,
        outcome: j['outcome'] as String,
      );
}

class Doctor {
  final int? id;
  final String name;
  final String role;
  final String? specialty;
  final String? phone;
  final String? email;
  final String? location;
  final String? nextAppt;
  final String? notes;
  final bool isPrimary;

  Doctor({
    this.id,
    required this.name,
    required this.role,
    this.specialty,
    this.phone,
    this.email,
    this.location,
    this.nextAppt,
    this.notes,
    this.isPrimary = false,
  });

  factory Doctor.fromJson(Map<String, dynamic> j) => Doctor(
        id: j['id'] as int?,
        name: j['name'] as String,
        role: (j['role'] ?? 'Provider') as String,
        specialty: j['specialty'] as String?,
        phone: j['phone'] as String?,
        email: j['email'] as String?,
        location: j['location'] as String?,
        nextAppt: j['next_appt'] as String?,
        notes: j['notes'] as String?,
        isPrimary: (j['is_primary'] ?? false) as bool,
      );

  String get initials {
    final cleaned = name.replaceAll(RegExp(r'[^A-Za-z ]'), '').trim();
    final parts = cleaned.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    return parts.take(2).map((p) => p[0]).join().toUpperCase();
  }
}

class Medication {
  final int? id;
  final String name;
  final String dose;
  final String form;
  final List<String> times;
  final String? purpose;
  final String? prescriber;
  final int? supplyDays;
  final String? refillBy;
  final String? notes;
  final List<String> taken; // slots taken today

  Medication({
    this.id,
    required this.name,
    required this.dose,
    required this.form,
    required this.times,
    this.purpose,
    this.prescriber,
    this.supplyDays,
    this.refillBy,
    this.notes,
    required this.taken,
  });

  factory Medication.fromJson(Map<String, dynamic> j) => Medication(
        id: j['id'] as int?,
        name: j['name'] as String,
        dose: (j['dose'] ?? '—') as String,
        form: (j['form'] ?? 'tablet') as String,
        times: ((j['times'] ?? []) as List).cast<String>(),
        purpose: j['purpose'] as String?,
        prescriber: j['prescriber'] as String?,
        supplyDays: j['supply_days'] as int?,
        refillBy: j['refill_by'] as String?,
        notes: j['notes'] as String?,
        taken: ((j['taken'] ?? []) as List).cast<String>(),
      );
}

class ChatMessage {
  final int? id;
  final String role; // user / assistant
  final String text;

  ChatMessage({this.id, required this.role, required this.text});

  bool get isUser => role == 'user';

  factory ChatMessage.fromJson(Map<String, dynamic> j) => ChatMessage(
        id: j['id'] as int?,
        role: j['role'] as String,
        text: j['text'] as String,
      );
}

class CrisisContact {
  final int? id;
  final String label;
  final String? sub;
  final String tel;

  CrisisContact({this.id, required this.label, this.sub, required this.tel});

  factory CrisisContact.fromJson(Map<String, dynamic> j) => CrisisContact(
        id: j['id'] as int?,
        label: j['label'] as String,
        sub: j['sub'] as String?,
        tel: j['tel'] as String,
      );
}

class HavenUser {
  final int id;
  final String name;
  final String email;
  HavenUser({required this.id, required this.name, required this.email});

  factory HavenUser.fromJson(Map<String, dynamic> j) =>
      HavenUser(id: j['id'] as int, name: j['name'] as String, email: j['email'] as String);
}
