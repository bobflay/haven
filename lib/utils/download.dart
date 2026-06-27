// Picks the real browser download on web, and a no-op on the Dart VM (e.g. the
// one `flutter test` uses), so web-only libraries never compile off-web.
export 'download_web.dart' if (dart.library.io) 'download_stub.dart';
