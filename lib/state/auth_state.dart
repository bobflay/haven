import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/models.dart';
import '../services/api_service.dart';

/// Owns the bearer token + signed-in user, and persists the token so a refresh
/// keeps you in your space.
class AuthState extends ChangeNotifier {
  AuthState(this.api);

  final ApiService api;
  static const _tokenKey = 'haven_token';

  HavenUser? user;
  bool ready = false; // bootstrap finished

  bool get isAuthed => user != null;

  /// On launch: restore a saved token and confirm it still works.
  Future<void> bootstrap() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_tokenKey);
    if (saved != null) {
      api.token = saved;
      try {
        user = await api.me();
      } catch (_) {
        api.token = null;
        await prefs.remove(_tokenKey);
      }
    }
    ready = true;
    notifyListeners();
  }

  Future<void> register(String name, String email, String password, String confirm) async {
    final (token, u) = await api.register(name, email, password, confirm);
    await _persist(token, u);
  }

  Future<void> login(String email, String password) async {
    final (token, u) = await api.login(email, password);
    await _persist(token, u);
  }

  Future<void> logout() async {
    try {
      await api.logout();
    } catch (_) {
      // best effort — clear locally regardless
    }
    api.token = null;
    user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    notifyListeners();
  }

  Future<void> _persist(String token, HavenUser u) async {
    api.token = token;
    user = u;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    notifyListeners();
  }
}
