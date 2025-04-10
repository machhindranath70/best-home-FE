import 'package:flutter/material.dart';
import 'dart:html' as html;

class ResultCard extends StatelessWidget {
  final Map<String, dynamic> item;

  const ResultCard({super.key, required this.item});

  void _showDetailsPopup(BuildContext context) {
    final rating = double.tryParse(item['rating']?.toString() ?? '0') ?? 0;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(item['name'] ?? 'Property Details'),
        content: SizedBox(
          width: 400, // ✅ important for Flutter web
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 📷 Safe image rendering
                SizedBox(
                  height: 180,
                  width: double.infinity,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: item['photo'] != null &&
                            item['photo'].toString().isNotEmpty
                        ? Image.network(
                            item['photo'],
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Image.asset('assets/10751558.png',
                                    fit: BoxFit.cover),
                          )
                        : Image.asset('assets/10751558.png',
                            fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(height: 16),

                // 📍 Address
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.location_on, color: Colors.teal),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        item['full_address'] ?? 'No address provided',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // 📞 Contact
                Row(
                  children: [
                    const Icon(Icons.phone_android, color: Colors.teal),
                    const SizedBox(width: 6),
                    Text(item['phone'] ?? 'Not available'),
                  ],
                ),
                const SizedBox(height: 10),

                // ⭐ Rating
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.orange),
                    const SizedBox(width: 6),
                    Text('Rating: ${item['rating'] ?? 'N/A'}'),
                  ],
                ),
                const SizedBox(height: 20),

                // 🌐 Review Link
                if (item['reviews_link'] != null &&
                    item['reviews_link'].toString().startsWith('http'))
                  ElevatedButton.icon(
                    onPressed: () {
                      html.window.open(item['reviews_link'], '_blank');
                    },
                    icon: const Icon(Icons.reviews),
                    label: const Text("Open Reviews"),
                  ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rating = double.tryParse(item['rating']?.toString() ?? '0') ?? 0;

    return GestureDetector(
      onTap: () => _showDetailsPopup(context),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 4,
        margin: const EdgeInsets.all(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // 📷 Image
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: item['photo'] != null &&
                        item['photo'].toString().isNotEmpty
                    ? Image.network(
                        item['photo'],
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Image.asset('assets/10751558.png',
                                width: 120, height: 120, fit: BoxFit.cover),
                      )
                    : Image.asset('assets/10751558.png',
                        width: 120, height: 120, fit: BoxFit.cover),
              ),
              const SizedBox(width: 16),

              // 🏠 Name + ⭐ Rating
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        item['name'] ?? 'Unknown Property',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: List.generate(5, (index) {
                          return Icon(
                            index < rating.round()
                                ? Icons.star
                                : Icons.star_border,
                            color: Colors.orange,
                            size: 20,
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
