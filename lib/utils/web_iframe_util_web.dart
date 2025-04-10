// lib/utils/web_iframe_util_web.dart
import 'dart:html' as html;

void postRadiusToIframe(double radius) {
  final iframe = html.document.getElementById('leaflet-map') as html.IFrameElement?;
  iframe?.contentWindow?.postMessage({
    'type': 'set_radius',
    'radius': radius,
  }, '*');
}

void postLocationToIframe(double lat, double lon) {
  final iframe = html.document.getElementById('leaflet-map') as html.IFrameElement?;
  iframe?.contentWindow?.postMessage({
    'type': 'move_to_location',
    'lat': lat,
    'lon': lon,
  }, '*');
}
