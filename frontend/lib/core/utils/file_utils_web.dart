import 'dart:html' as html;
import 'dart:typed_data';

String openFileInBrowser(Uint8List bytes, String mimeType, String fileName) {
  final blob = html.Blob([bytes], mimeType);
  final url = html.Url.createObjectUrl(blob);
  html.window.open(url, '_blank');
  return url;
}

void openUrlInNewTab(String url) {
  html.window.open(url, '_blank');
}
