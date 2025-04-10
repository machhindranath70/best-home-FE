import 'package:flutter/material.dart';

final TextEditingController searchController = TextEditingController();

class MapHeader extends StatelessWidget {
  final TextEditingController radiusController;
  final TextEditingController searchController;
  final VoidCallback onFindTap;
  final VoidCallback onRegisterTap;
  final void Function(String) onSearch;

  const MapHeader({
    super.key,
    required this.radiusController,
    required this.searchController,
    required this.onFindTap,
    required this.onRegisterTap,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 85,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: Colors.teal,
        boxShadow: [
          BoxShadow(color: Colors.black26, offset: Offset(0, 4), blurRadius: 6),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left side: Logo + Title
          Row(
            children: [
              const FlutterLogo(size: 40),
              const SizedBox(width: 12),
              const Text(
                "Find your best home",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          // Right side: Search + Radius input + Buttons
          Row(
            children: [
              // 🔍 Search bar
              SizedBox(
                width: 250,
                height: 40,
                child: TextField(
                  controller: searchController,
                  onSubmitted: onSearch,
                  decoration: InputDecoration(
                    hintText: "Search place...",
                    hintStyle: const TextStyle(color: Colors.teal),
                    fillColor: Colors.white,
                    filled: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              const Text(
                "Radius (meters):",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 80,
                height: 40,
                child: TextField(
                  controller: radiusController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.teal),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    hintText: "e.g. 1000",
                    hintStyle: const TextStyle(color: Colors.teal),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              ElevatedButton(
                onPressed: onFindTap,
                child: const Text('Find Home'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.teal,
                ),
              ),
              const SizedBox(width: 12),

              ElevatedButton(
                onPressed: onRegisterTap,
                child: const Text('Register Property'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.teal,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
