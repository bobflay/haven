import 'package:flutter/foundation.dart';

enum HavenScreen { home, history, wheel, log, coping, doctors, meds, export, chat }

/// Drives which screen is showing inside the phone frame, plus the side drawer.
class NavState extends ChangeNotifier {
  HavenScreen current = HavenScreen.home;
  bool menuOpen = false;

  /// The bottom tab bar only shows on the three "home" surfaces.
  bool get showTabs =>
      current == HavenScreen.home || current == HavenScreen.history || current == HavenScreen.wheel;

  void go(HavenScreen screen) {
    current = screen;
    menuOpen = false;
    notifyListeners();
  }

  void openMenu() {
    menuOpen = true;
    notifyListeners();
  }

  void closeMenu() {
    menuOpen = false;
    notifyListeners();
  }

  void resetToHome() {
    current = HavenScreen.home;
    menuOpen = false;
  }
}
