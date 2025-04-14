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
import 'RetryableNetworkImage.dart';
import 'map/footer.dart';


import 'package:flutter/foundation.dart'; // For kIsWeb

bool isLoading = false;
bool isMarkerSelected = false;
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
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
  return Geolocator.distanceBetween(lat1, lon1, lat2, lon2); // in meters
  }



  Map<String, dynamic>? getBestRecommendedHome() {
    if (selectedLat == null || selectedLon == null || searchResults.isEmpty) return null;

    List<Map<String, dynamic>> enriched = searchResults.cast<Map<String, dynamic>>().map((item) {
      final lat = item['latitude'];
      final lon = item['longitude'];
      final rating = double.tryParse(item['rating']?.toString() ?? '0') ?? 0.0;
      final distance = _calculateDistance(selectedLat!, selectedLon!, lat, lon);

      return {
        ...item,
        'distance': distance,
        'rating': rating,
      };
    }).toList();

    enriched.sort((a, b) {
      final distCompare = a['distance'].compareTo(b['distance']);
      return distCompare != 0
          ? distCompare
          : b['rating'].compareTo(a['rating']); // prefer higher rating if distance equal
    });

    return enriched.first;
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

    Future.delayed(const Duration(seconds: 3), () {
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
            _handleFindHome();
          });
        }
        if (data['type'] == 'marker_clicked') {
          // final property = data['property'];
          final rawProperty = data['property'];

          if (rawProperty != null && rawProperty is Map) {
            final property = Map<String, dynamic>.from(rawProperty);

            setState(() {
              isMarkerSelected = true; // ✅ mark this as user-selected
              searchResults = [property];
              selectedLat = (property['latitude'] ?? 0).toDouble();
              selectedLon = (property['longitude'] ?? 0).toDouble();
            });
          }

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
                'property': e, // ✅ send full property
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
      setState(()  {
          radius = input;
          isMarkerSelected = false; // ✅ reset when using Find Home
        });

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
          // 🔼 Top Header
          MapHeader(
            radiusController: radiusController,
            searchController: searchController,
            onFindTap: _handleFindHome,
            onRegisterTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RegistrationPage()),
              );
            },
            onSearch: _searchPlace,
          ),

          // 🔁 Main Content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // 🌍 Map + Recommendation Side-by-Side
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 🗺️ Map (70%)
                      Expanded(
                        flex: 7,
                        child: const MapView(),
                      ),

                      // 🏠 Best Recommendation (30%)
                      Expanded(
                        flex: 3,
                        child: Container(
                          height: 500,
                          padding: const EdgeInsets.all(12),
                          color: const Color.fromARGB(255, 254, 255, 255),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 500),
                            child: getBestRecommendedHome() == null
                                ? Column(
                                    key: const ValueKey('placeholder'),
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text(
                                        '',
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Color.fromARGB(255, 250, 191, 65),
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      AnimatedDefaultTextStyle(
                                        duration: const Duration(milliseconds: 400),
                                        style: const TextStyle(
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.teal,
                                        ),
                                        child: const Text('Select your location'),
                                      ),
                                      const SizedBox(height: 12),
                                      AnimatedDefaultTextStyle(
                                        duration: const Duration(milliseconds: 400),
                                        style: const TextStyle(
                                          fontSize: 36,
                                          fontWeight: FontWeight.w500,
                                          color: Color.fromARGB(255, 1, 41, 61),
                                        ),
                                        child: const Text('Find Your Best Home'),
                                      ),
                                      const SizedBox(height: 24),
                                      Image.asset(
                                        'assets/icons8-search.gif',
                                        width: 90,
                                        height: 90,
                                        fit: BoxFit.cover,
                                      ),
                                    ],
                                  )
                                : Column(
                                    key: const ValueKey('card'),
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                      isMarkerSelected ? 'Your Selected Property' : 'Best Recommendation for You',
                                        style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.teal,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: RetryableNetworkImage(
                                          imageUrl: getBestRecommendedHome()?['photo'] ?? '',
                                          height: 150,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return Image.asset(
                                              'assets/10751558.png',
                                              height: 150,
                                              width: double.infinity,
                                              fit: BoxFit.cover,
                                            );
                                          },
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        getBestRecommendedHome()?['name'] ?? 'Unknown Property',
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Icon(Icons.location_on, size: 18, color: Colors.grey),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                              getBestRecommendedHome()?['full_address'] ?? 'No address',
                                              style: const TextStyle(fontSize: 14, color: Colors.black54),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          const Icon(Icons.phone, size: 18, color: Colors.grey),
                                          const SizedBox(width: 6),
                                          Text(
                                            getBestRecommendedHome()?['phone'] ?? 'N/A',
                                            style: const TextStyle(fontSize: 14, color: Colors.black87),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          const Icon(Icons.star, size: 18, color: Colors.amber),
                                          const SizedBox(width: 6),
                                          Text(
                                            'Rating: ${getBestRecommendedHome()?['rating'] ?? 'N/A'}',
                                            style: const TextStyle(fontSize: 14, color: Colors.black87),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          const Icon(Icons.directions_walk, size: 18, color: Colors.blueGrey),
                                          const SizedBox(width: 6),
                                          Text(
                                            'Distance: ${(getBestRecommendedHome()?['distance'] / 1000).toStringAsFixed(2)} km',
                                            style: const TextStyle(fontSize: 14, color: Colors.black87),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Builder(
                                        builder: (_) {
                                          final reviewLink = getBestRecommendedHome()?['reviews_link']?.toString();
                                          if (reviewLink != null && reviewLink.startsWith('http')) {
                                            return Center( // 👉 Center the button
                                              child: TextButton.icon(
                                                onPressed: () {
                                                  html.window.open(reviewLink, '_blank');
                                                },
                                                icon: const Icon(Icons.reviews),
                                                label: const Text('Open Reviews'),
                                                style: TextButton.styleFrom(
                                                  foregroundColor: Colors.white,
                                                  backgroundColor: Colors.teal,
                                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                ),
                                              ),
                                            );
                                          }
                                          return const SizedBox.shrink();
                                        },
                                      ),

                                    ],
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // 🔽 Full-width Result Grid (as it was before)
                  if (isLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: CircularProgressIndicator(),
                    ),

                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          height: 50,
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.teal.shade100,
                            borderRadius: BorderRadius.circular(6),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Text(
                            '🏘️ Nearby Houses for Accommodation',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 5, 126, 226),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        ResultGrid(
                          results: searchResults.cast<Map<String, dynamic>>(),
                        ),
                      ],
                    ),
                  ),
                  const Footer(), // 👈 Add this here
                ],
               ),
            ),
          ),
        ],
      ),
    );
  }
}