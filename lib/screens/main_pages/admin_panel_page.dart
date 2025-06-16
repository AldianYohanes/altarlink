// lib/screens/admin_panel/admin_panel_page.dart

import 'package:flutter/material.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart'; // <--- Import BARU untuk Bootstrap Icons
import 'package:altarlink4/screens/admin_panel/admin_posts_page.dart';
import 'package:altarlink4/screens/admin_panel/admin_users_page.dart';
import 'package:altarlink4/screens/admin_panel/admin_notifications_page.dart';
import 'package:altarlink4/screens/admin_panel/admin_learning_materials_page.dart';
import 'package:altarlink4/screens/admin_panel/admin_masses_page.dart';

class AdminPanelPage extends StatefulWidget {
  const AdminPanelPage({super.key});

  @override
  State<AdminPanelPage> createState() => _AdminPanelPageState();
}

class _AdminPanelPageState extends State<AdminPanelPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Definisikan warna yang konsisten dari tweak terakhir Anda
  static const Color primaryTextColor = Color(0xFFF5F5F5); // Background AppBar
  static const Color orangeAccent = Color(0xFFFFA852); // Indikator, label aktif
  static const Color backgroundWhite =
      Color(0xFFF5F5F5); // Latar belakang Scaffold
  static const Color darkGreyText =
      Color(0xFF535353); // Warna teks dan ikon tidak aktif, judul AppBar

  @override
  void initState() {
    super.initState();
    // Penting: Pastikan panjang TabController sesuai dengan jumlah tab
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundWhite,
      appBar: AppBar(
        title: const Text(
          'Panel Admin',
          style: TextStyle(
            color: darkGreyText, // Warna teks judul AppBar sesuai tweak
            fontWeight: FontWeight.bold,
            fontFamily: 'Work Sans',
          ),
        ),
        backgroundColor: primaryTextColor, // Warna AppBar
        foregroundColor: darkGreyText, // Warna ikon dan panah kembali
        elevation: 1, // Sedikit bayangan
        bottom: TabBar(
          controller: _tabController,
          isScrollable: false,
          labelColor: orangeAccent, // Warna label tab aktif
          unselectedLabelColor: darkGreyText, // Warna label tab tidak aktif
          indicatorColor:
              Colors.transparent, // <--- Menghapus garis pemisah di bawah tab
          indicatorWeight: 0.1, // Tidak perlu weight jika transparan
          tabs: const [
            // Susun ulang tab dan gunakan BootstrapIcons
            Tab(text: 'Postingan', icon: Icon(BootstrapIcons.newspaper)),
            Tab(text: 'Notifikasi', icon: Icon(BootstrapIcons.bell)),
            Tab(
                text: 'Misa',
                icon: Icon(BootstrapIcons
                    .file_earmark_post)), // Atau BootstrapIcons.file_earmark_post jika lebih sesuai
            Tab(text: 'Materi', icon: Icon(BootstrapIcons.book)),
            Tab(text: 'Pengguna', icon: Icon(BootstrapIcons.people)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        // Susun ulang children sesuai urutan tab
        children: const [
          AdminPostsPage(),
          AdminNotificationsPage(),
          AdminMassesPage(), // Pastikan ini sesuai dengan ikon BootstrapIcons.church
          AdminLearningMaterialsPage(),
          AdminUsersPage(),
        ],
      ),
    );
  }
}
