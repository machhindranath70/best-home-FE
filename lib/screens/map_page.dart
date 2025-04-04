import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'dart:html' as html;

class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final String viewID = 'leaflet-map';

  @override
  void initState() {
    super.initState();

    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(viewID, (int viewId) {
      final html.IFrameElement element = html.IFrameElement()
        ..width = '100%'
        ..height = '100%'
        ..src = 'assets/map.html' // We’ll create this next
        ..style.border = 'none';

      return element;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🌍 Interactive Map')),
      body: const HtmlElementView(viewType: 'leaflet-map'),
    );
  }
}
