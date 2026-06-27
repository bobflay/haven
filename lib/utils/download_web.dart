import 'dart:convert';
import 'dart:js_interop';

import 'package:web/web.dart' as web;

/// Hand a generated export to the browser as a file download (web only).
void downloadFile(String filename, String content, String mime) {
  final bytes = utf8.encode(content);
  final blob = web.Blob(
    <JSAny>[bytes.toJS].toJS,
    web.BlobPropertyBag(type: mime),
  );
  final url = web.URL.createObjectURL(blob);
  final anchor = web.HTMLAnchorElement()
    ..href = url
    ..download = filename
    ..style.display = 'none';
  web.document.body?.appendChild(anchor);
  anchor.click();
  anchor.remove();
  web.URL.revokeObjectURL(url);
}
