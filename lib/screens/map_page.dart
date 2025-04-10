import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'dart:html' as html;

import 'registration_page.dart';
import 'map/map_header.dart';
import 'map/map_view.dart';
import 'map/result_card.dart';
import 'map/result_grid.dart';
import 'package:flutter/foundation.dart'; // for kIsWeb
import '../utils/web_iframe_util.dart';   // your web-safe iframe utility
import 'dart:html' as html;

import 'package:flutter/foundation.dart'; // For kIsWeb

bool isLoading = false;

final TextEditingController radiusController = TextEditingController(
  text: '1000',
);
final TextEditingController searchController =
    TextEditingController(); // ✅ Added

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  double? radius = 1000;
  double? selectedLat;
  double? selectedLon;
  List<dynamic> searchResults = [];

  @override
  void initState() {
    super.initState();
    _listenToMapEvents();
  }

  void _showAutoDismissDialog(String title, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 10,
            backgroundColor: Colors.orange[50],
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.search_off_rounded,
                      color: Colors.deepOrange,
                      size: 40,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepOrange,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
    );

    Future.delayed(const Duration(seconds: 5), () {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    });
  }

  Future<void> _searchPlace(String placeName) async {
    if (placeName.trim().isEmpty) return;

    final uri = Uri.parse(
      "https://nominatim.openstreetmap.org/search?q=$placeName&format=json&limit=1",
    );

    try {
      final response = await http.get(
        uri,
        headers: {'User-Agent': 'FlutterApp'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          final lat = double.parse(data[0]['lat']);
          final lon = double.parse(data[0]['lon']);

          html.IFrameElement? mapIframe =
              html.document.getElementById('leaflet-map')
                  as html.IFrameElement?;
          mapIframe?.contentWindow?.postMessage({
            'type': 'move_to_location',
            'lat': lat,
            'lon': lon,
          }, "*");
        } else {
          _showAutoDismissDialog("Not Found", "No matching location found.");
        }
      }
    } catch (e) {
      print("Error during geocoding: $e");
    }
  }

  void _listenToMapEvents() {
    html.window.onMessage.listen((event) {
      final data = event.data;
      if (data is Map) {
        if (data['type'] == 'user_location') {
          _fetchNearbyProperties(data['lat'], data['lon'], radius ?? 1000);
        }
        if (data['type'] == 'selected_point') {
          setState(() {
            selectedLat = data['lat'];
            selectedLon = data['lon'];
          });
        }
      }
    });
  }

  void _sendMarkersToMap(List<dynamic> data) {
    final markerData =
        data
            .map(
              (e) => {
                'lat': e['latitude'],
                'lon': e['longitude'],
                'name': e['name'],
              },
            )
            .toList();

    final mapIframe =
        html.document.getElementById('leaflet-map') as html.IFrameElement?;
    mapIframe?.contentWindow?.postMessage({
      'type': 'add_markers',
      'data': markerData,
    }, "*");
  }

  Future<void> _fetchNearbyProperties(
    double lat,
    double lon,
    double radius,
  ) async {
    setState(() => isLoading = true);

    final url = Uri.parse(
      'https://best-home-be-2.onrender.com/api/property-info-nearby/?lat=$lat&lon=$lon&radius=$radius',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data is List ? data : [data];

        if (results.isEmpty) {
          _showAutoDismissDialog(
            "No homes nearby",
            "No homes found near the selected location within the provided radius.\nPlease change the location or increase the radius.",
          );
        }

        setState(() {
          searchResults = results;
        });
        _sendMarkersToMap(results);
      } else {
        throw Exception('Failed to load properties');
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('❌ API error: $e')));
    } finally {
      setState(() => isLoading = false);
    }
  }



  void _handleFindHome() {
    final input = double.tryParse(radiusController.text);
    if (selectedLat != null && selectedLon != null && input != null) {
      setState(() => radius = input);

      // ✅ Only run iframe communication on Web
      if (kIsWeb) {
        final iframe = html.document.getElementById('leaflet-map') as html.IFrameElement?;
        iframe?.contentWindow?.postMessage({
          'type': 'set_radius',
          'radius': input,
        }, '*');

        iframe?.contentWindow?.postMessage({
          'type': 'move_to_location',
          'lat': selectedLat,
          'lon': selectedLon,
        }, '*');
      }

      _fetchNearbyProperties(selectedLat!, selectedLon!, input);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('📍 Please enter radius & select location'),
        ),
      );
    }
  }


 //_fetchNearbyProperties(selectedLat!, selectedLon!, input);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          MapHeader(
            radiusController: radiusController,
            searchController: searchController, // ✅ Pass search controller
            onFindTap: _handleFindHome,
            onRegisterTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RegistrationPage()),
              );
            },
            onSearch: _searchPlace, // ✅ Hook search function
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  const MapView(),
                  if (isLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: CircularProgressIndicator(),
                    ),
                  if (searchResults.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Column(
                        children: [
                          const Text(
                            '🏘️ Nearby Homes',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          ResultGrid(
                            results: searchResults.cast<Map<String, dynamic>>(),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
