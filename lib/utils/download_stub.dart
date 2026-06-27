/// Non-web fallback for [downloadFile]. The app only runs on the web, so this
/// is a no-op kept solely to let off-web targets (the `flutter test` VM) compile.
void downloadFile(String filename, String content, String mime) {}
