// lib/screens/main_pages/full_screen_image_page.dart

import 'package:flutter/material.dart';

class FullScreenImagePage extends StatelessWidget {
  final String? imageUrl; // Ubah menjadi nullable
  final String? userName;

  const FullScreenImagePage({super.key, this.imageUrl, this.userName});

  @override
  Widget build(BuildContext context) {
    // Gunakan placeholder jika imageUrl null atau kosong
    final String displayImageUrl = imageUrl != null && imageUrl!.isNotEmpty
        ? imageUrl!
        : 'https://picsum.photos/id/1005/800/800'; // Gambar placeholder dari Picsum

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          userName != null ? 'Foto Profil ${userName!}' : 'Foto Profil',
          style: const TextStyle(color: Colors.white, fontFamily: 'Work Sans'),
        ),
      ),
      body: Center(
        child: Hero(
          tag: displayImageUrl, // Tag unik
          child: Image.network(
            displayImageUrl,
            fit: BoxFit.contain,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                  color: Colors.white,
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey[800],
                child: const Center(
                  child:
                      Icon(Icons.broken_image, size: 80, color: Colors.white),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
