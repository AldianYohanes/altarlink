// lib/screens/admin_panel/admin_posts_page.dart

import 'package:flutter/material.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart'; // Import untuk ikon Bootstrap

class AdminPostsPage extends StatelessWidget {
  const AdminPostsPage({super.key});

  // Definisikan warna yang konsisten
  static const Color backgroundWhite =
      Color(0xFFF5F5F5); // Latar belakang Scaffold
  static const Color darkGreyText = Color(0xFF535353); // Warna teks dan ikon

  @override
  Widget build(BuildContext context) {
    // Halaman ini tidak memerlukan Scaffold atau AppBar karena sudah ada di AdminPanelPage (induk)
    return Container(
      color: backgroundWhite, // Latar belakang konsisten dengan tema
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(BootstrapIcons.newspaper,
                size: 80, color: darkGreyText), // Ikon Bootstrap
            SizedBox(height: 16),
            Text(
              'Halaman Manajemen Postingan',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Work Sans',
                color: darkGreyText,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Daftar dan kelola semua postingan di sini.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Work Sans',
                color: darkGreyText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
