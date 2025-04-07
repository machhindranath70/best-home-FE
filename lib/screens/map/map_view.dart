import 'dart:html' as html;
import 'dart:ui_web' as ui; // ✅ Web-specific import
import 'package:flutter/material.dart';

class MapView extends StatelessWidget {
  const MapView({super.key});

  @override
  Widget build(BuildContext context) {
    const String viewID = 'leaflet-map';

    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(viewID, (int viewId) {
      final html.IFrameElement element =
          html.IFrameElement()
            ..width = '100%'
            ..height = '500px'
            ..src = 'assets/map.html'
            ..style.border = 'none'
            ..id =
                'leaflet-map'; // ✅ This gives it a DOM ID so Flutter can find it!
      return element;
    });

    return const SizedBox(
      height: 500,
      child: HtmlElementView(viewType: viewID),
    );
  }
}
