// lib/screens/main_pages/full_schedule_page.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // Untuk membuka URL

class FullSchedulePage extends StatelessWidget {
  const FullSchedulePage({super.key});

  final String _googleDriveUrl =
      'https://docs.google.com/document/d/1234567890/edit?usp=sharing'; // Ganti dengan URL dummy atau asli Anda

  Future<void> _launchUrl() async {
    if (!await launchUrl(Uri.parse(_googleDriveUrl))) {
      throw 'Could not launch $_googleDriveUrl';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jadwal Lengkap'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Anda akan diarahkan ke Google Drive untuk melihat jadwal lengkap.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _launchUrl,
                child: const Text('Buka Google Drive'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
