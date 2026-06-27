import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/models.dart';

class ApiException implements Exception {
  final String message;
  final int? status;
  ApiException(this.message, [this.status]);
  @override
  String toString() => message;
}

/// Thin wrapper around the Laravel API. Holds the bearer token and exposes a
/// typed method per endpoint.
class ApiService {
  /// Where the Laravel `php artisan serve` instance lives. Override with
  /// `--dart-define=HAVEN_API_BASE=...` for other hosts.
  static const String baseUrl =
      String.fromEnvironment('HAVEN_API_BASE', defaultValue: 'http://127.0.0.1:8000/api');

  String? token;

  Map<String, String> get _headers => {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

  Uri _uri(String path, [Map<String, String>? query]) =>
      Uri.parse('$baseUrl$path').replace(queryParameters: query);

  Future<dynamic> _decode(http.Response res) async {
    final body = res.body.isEmpty ? null : jsonDecode(res.body);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return body;
    }
    if (body is Map) {
      // Laravel validation errors → surface the first field message.
      if (body['errors'] is Map) {
        final errors = (body['errors'] as Map).values;
        if (errors.isNotEmpty && (errors.first as List).isNotEmpty) {
          throw ApiException((errors.first as List).first.toString(), res.statusCode);
        }
      }
      if (body['message'] is String) {
        throw ApiException(body['message'] as String, res.statusCode);
      }
    }
    throw ApiException('Something went wrong (${res.statusCode}).', res.statusCode);
  }

  Future<dynamic> _get(String path, [Map<String, String>? query]) async =>
      _decode(await http.get(_uri(path, query), headers: _headers));

  Future<dynamic> _post(String path, [Map<String, dynamic>? body]) async =>
      _decode(await http.post(_uri(path), headers: _headers, body: jsonEncode(body ?? {})));

  Future<dynamic> _put(String path, Map<String, dynamic> body) async =>
      _decode(await http.put(_uri(path), headers: _headers, body: jsonEncode(body)));

  Future<dynamic> _delete(String path) async =>
      _decode(await http.delete(_uri(path), headers: _headers));

  List<T> _list<T>(dynamic json, T Function(Map<String, dynamic>) fromJson) =>
      ((json['data'] ?? json) as List).map((e) => fromJson((e as Map).cast<String, dynamic>())).toList();

  // --- Auth -----------------------------------------------------------------
  Future<(String, HavenUser)> register(
      String name, String email, String password, String passwordConfirmation) async {
    final j = await _post('/register', {
      'name': name,
      'email': email,
      'password': password,
      'password_confirmation': passwordConfirmation,
      'agreed': true,
    });
    return (j['token'] as String, HavenUser.fromJson((j['user'] as Map).cast<String, dynamic>()));
  }

  Future<(String, HavenUser)> login(String email, String password) async {
    final j = await _post('/login', {'email': email, 'password': password});
    return (j['token'] as String, HavenUser.fromJson((j['user'] as Map).cast<String, dynamic>()));
  }

  Future<HavenUser> me() async {
    final j = await _get('/me');
    return HavenUser.fromJson((j['user'] as Map).cast<String, dynamic>());
  }

  Future<void> logout() async {
    await _post('/logout');
  }

  // --- Entries --------------------------------------------------------------
  Future<List<Entry>> getEntries() async => _list(await _get('/entries'), Entry.fromJson);

  Future<Entry> createEntry(Map<String, dynamic> payload) async {
    final j = await _post('/entries', payload);
    return Entry.fromJson(((j['data'] ?? j) as Map).cast<String, dynamic>());
  }

  // --- Care team ------------------------------------------------------------
  Future<List<CrisisContact>> getCrisisContacts() async =>
      _list(await _get('/crisis-contacts'), CrisisContact.fromJson);

  Future<List<Doctor>> getDoctors() async => _list(await _get('/doctors'), Doctor.fromJson);

  Future<Doctor> createDoctor(Map<String, dynamic> payload) async {
    final j = await _post('/doctors', payload);
    return Doctor.fromJson(((j['data'] ?? j) as Map).cast<String, dynamic>());
  }

  Future<Doctor> updateDoctor(int id, Map<String, dynamic> payload) async {
    final j = await _put('/doctors/$id', payload);
    return Doctor.fromJson(((j['data'] ?? j) as Map).cast<String, dynamic>());
  }

  Future<void> deleteDoctor(int id) async => _delete('/doctors/$id');

  // --- Medications ----------------------------------------------------------
  Future<List<Medication>> getMedications() async =>
      _list(await _get('/medications'), Medication.fromJson);

  Future<Medication> createMedication(Map<String, dynamic> payload) async {
    final j = await _post('/medications', payload);
    return Medication.fromJson(((j['data'] ?? j) as Map).cast<String, dynamic>());
  }

  Future<Medication> updateMedication(int id, Map<String, dynamic> payload) async {
    final j = await _put('/medications/$id', payload);
    return Medication.fromJson(((j['data'] ?? j) as Map).cast<String, dynamic>());
  }

  Future<void> deleteMedication(int id) async => _delete('/medications/$id');

  Future<Medication> toggleDose(int id, String slot) async {
    final j = await _post('/medications/$id/toggle-dose', {'slot': slot});
    return Medication.fromJson(((j['data'] ?? j) as Map).cast<String, dynamic>());
  }

  // --- Chat -----------------------------------------------------------------
  Future<List<ChatMessage>> getChat() async => _list(await _get('/chat'), ChatMessage.fromJson);

  Future<List<ChatMessage>> sendChat(String text) async =>
      _list(await _post('/chat', {'text': text}), ChatMessage.fromJson);

  // --- Export ---------------------------------------------------------------
  Future<Map<String, dynamic>> export(String range, String format) async {
    final j = await _get('/export', {'range': range, 'format': format});
    return (j as Map).cast<String, dynamic>();
  }
}
