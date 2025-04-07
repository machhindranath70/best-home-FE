import 'package:flutter/material.dart';
import 'dart:html' as html;

class ResultCard extends StatelessWidget {
  final Map<String, dynamic> item;

  const ResultCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: ListTile(
        leading:
            item['photo'] != null
                ? Image.network(
                  item['photo'],
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                )
                : const Icon(Icons.home, size: 40, color: Colors.teal),
        title: Text(item['name'] ?? 'Unknown'),
        subtitle: Text(item['full_address'] ?? ''),
        trailing:
            item['rating'] != null
                ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.star, color: Colors.orange, size: 20),
                    Text(item['rating'].toString()),
                  ],
                )
                : null,
        onTap: () {
          if (item['reviews_link'] != null) {
            html.window.open(item['reviews_link'], '_blank');
          }
        },
      ),
    );
  }
}
