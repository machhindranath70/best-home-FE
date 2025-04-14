import 'package:flutter/material.dart';
import 'dart:html' as html;

class Footer extends StatelessWidget {
  const Footer({super.key});

  void _openLinkedIn() {
    html.window.open('https://www.linkedin.com/company/cotfe/?viewAsMember=true', '_blank');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color.fromARGB(255, 211, 149, 190),
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo + Company Info
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(
                    'assets/logo_cote.png', // ✅ Your logo
                    height: 50,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Centralized Online Technology for Earth (COTE)',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),

              // Quick Links
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Quick Links',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  SizedBox(height: 10),
                  Text('About Us', style: TextStyle(color: Colors.white70)),
                  Text('Contact', style: TextStyle(color: Colors.white70)),
                  Text('Careers', style: TextStyle(color: Colors.white70)),
                  Text('Privacy Policy', style: TextStyle(color: Colors.white70)),
                  Text('Terms of Service', style: TextStyle(color: Colors.white70)),
                ],
              ),

              // Social
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Connect with Us',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: _openLinkedIn,
                    child: Row(
                      children: const [
                        Icon(Icons.link, color: Colors.white70),
                        SizedBox(width: 6),
                        Text('LinkedIn', style: TextStyle(color: Colors.white70)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 30),
          const Divider(color: Colors.white24),
          const SizedBox(height: 10),
          const Text(
            '© 2025 COTE. All rights reserved.',
            style: TextStyle(color: Colors.white54),
          ),
        ],
      ),
    );
  }
}
