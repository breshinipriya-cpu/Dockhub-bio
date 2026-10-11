// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

void registerIframeView(String viewId, String iframeUrl) {
  ui_web.platformViewRegistry.registerViewFactory(
    viewId,
    (int id) {
      final iframe = html.IFrameElement()
        ..src = iframeUrl
        ..style.border = 'none'
        ..style.width = '100%'
        ..style.height = '100%'
        ..allowFullscreen = true;
      return iframe;
    },
  );
}
