// lib/screens/admin_panel/admin_learning_materials_page.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:altarlink4/services/learning_material_service.dart';
import 'package:altarlink4/models/learning_material_model.dart';
import 'package:altarlink4/screens/admin_panel/add_edit_learning_material_page.dart';
import 'package:intl/intl.dart'; // Untuk format tanggal
import 'package:url_launcher/url_launcher.dart'; // Untuk membuka link dari daftar
import 'package:bootstrap_icons/bootstrap_icons.dart'; // Import untuk ikon

class AdminLearningMaterialsPage extends StatefulWidget {
  const AdminLearningMaterialsPage({super.key});

  @override
  State<AdminLearningMaterialsPage> createState() =>
      _AdminLearningMaterialsPageState();
}

class _AdminLearningMaterialsPageState
    extends State<AdminLearningMaterialsPage> {
  final LearningMaterialService _learningMaterialService =
      LearningMaterialService();
  final TextEditingController _searchController =
      TextEditingController(); // Controller untuk search
  String _searchQuery = ''; // State untuk query pencarian

  // Definisikan warna yang konsisten sesuai tab notifikasi
  static const Color primaryTextColor =
      Color(0xFFFFFFFF); // Background Card, Input Fields
  static const Color orangeAccent =
      Color(0xFFFFA852); // Accent color for buttons, icons, focused borders
  static const Color backgroundWhite =
      Color(0xFFF5F5F5); // Main Scaffold/Container background
  static const Color darkGreyText = Color(0xFF535353); // General text color
  static const Color redAccent = Color(0xFFFF5252); // Delete icon/button color
  static const Color borderColor = Color(0xFFBDBDBD); // Outline border color

  @override
  void initState() {
    super.initState();
    _searchController.addListener(
        _onSearchChanged); // Listener untuk perubahan teks pencarian
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
    });
  }

  // Helper untuk mendapatkan ikon berdasarkan kategori atau tipe URL
  IconData _getIconForMaterialType(LearningMaterialModel material) {
    if (material.videoUrl != null && material.videoUrl!.isNotEmpty) {
      return BootstrapIcons.play_circle; // Ikon video dari BootstrapIcons
    } else if (material.documentUrl != null &&
        material.documentUrl!.isNotEmpty) {
      return BootstrapIcons
          .file_earmark_text; // Ikon dokumen dari BootstrapIcons
    } else {
      switch (material.category.toLowerCase()) {
        case 'liturgi':
          return BootstrapIcons.diamond;
        case 'doa':
          return BootstrapIcons.book;
        case 'organisasi':
          return BootstrapIcons.diagram_3;
        case 'sejarah':
          return BootstrapIcons.hourglass;
        case 'umum':
        default:
          return BootstrapIcons.lightbulb;
      }
    }
  }

  // Helper untuk format tanggal materi ditambahkan
  String _formatMaterialDate(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return DateFormat('d MMMM yyyy').format(dateTime); // Format tanggal lengkap
  }

  // Fungsi untuk konfirmasi dan menghapus materi
  Future<void> _confirmDeleteMaterial(String materialId, String title) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: primaryTextColor, // Warna background dialog
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)), // Sudut membulat
          title: Text(
            'Hapus Materi?',
            style: TextStyle(
                fontFamily: 'Work Sans',
                fontWeight: FontWeight.bold,
                color: darkGreyText),
          ),
          content: Text(
            'Anda yakin ingin menghapus materi "$title"?',
            style: TextStyle(fontFamily: 'Work Sans', color: darkGreyText),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: Text(
                'Batal',
                style: TextStyle(fontFamily: 'Work Sans', color: darkGreyText),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                try {
                  await _learningMaterialService
                      .deleteLearningMaterial(materialId);
                  if (mounted) {
                    // Pastikan widget masih ada sebelum showSnackBar
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Materi berhasil dihapus!')),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    // Pastikan widget masih ada sebelum showSnackBar
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content:
                              Text('Gagal menghapus materi: ${e.toString()}')),
                    );
                  }
                  print('Error deleting learning material: $e');
                }
              },
              child: Text('Hapus',
                  style: TextStyle(fontFamily: 'Work Sans', color: redAccent)),
            ),
          ],
        );
      },
    );
  }

  // Helper untuk membuka URL (sama seperti di LearningMaterialsPage utama)
  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri,
          mode: LaunchMode.externalApplication); // Buka di aplikasi eksternal
    } else {
      if (mounted) {
        // Pastikan widget masih ada sebelum showSnackBar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tidak dapat membuka link: $url')),
        );
      }
      print('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // Gunakan Container untuk warna background
      color: backgroundWhite,
      child: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Cari materi...',
                    hintStyle: TextStyle(
                        fontFamily: 'Work Sans',
                        color: darkGreyText.withOpacity(0.6)),
                    prefixIcon:
                        Icon(BootstrapIcons.search, color: darkGreyText),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: Icon(BootstrapIcons.x_circle,
                                color: darkGreyText),
                            onPressed: () {
                              _searchController.clear();
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                          100), // Mirip search bar notifikasi
                      borderSide: BorderSide(color: borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(100),
                      borderSide: BorderSide(color: orangeAccent, width: 2),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(100),
                      borderSide: BorderSide(color: borderColor),
                    ),
                    filled: true,
                    fillColor: primaryTextColor,
                  ),
                  style: const TextStyle(
                      fontFamily: 'Work Sans', color: darkGreyText),
                  cursorColor: orangeAccent,
                ),
              ),
              Expanded(
                child: StreamBuilder<List<LearningMaterialModel>>(
                  stream: _learningMaterialService.getLearningMaterials(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                          child: CircularProgressIndicator(
                              color: orangeAccent)); // Warna progress indicator
                    } else if (snapshot.hasError) {
                      print(
                          'Error fetching learning materials for admin: ${snapshot.error}');
                      return Center(
                          child: Text('Error memuat materi: ${snapshot.error}',
                              style: TextStyle(
                                  fontFamily: 'Work Sans',
                                  color: darkGreyText)));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(BootstrapIcons.book_half,
                                size: 80,
                                color: darkGreyText), // Ikon tanpa materi
                            SizedBox(height: 16),
                            Text(
                              'Belum ada materi pembelajaran untuk dikelola.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontFamily: 'Work Sans',
                                  fontSize: 16,
                                  color: darkGreyText),
                            ),
                          ],
                        ),
                      );
                    } else {
                      List<LearningMaterialModel> materials = snapshot.data!;
                      final filteredMaterials = materials.where((material) {
                        final titleLower = material.title.toLowerCase();
                        final descriptionLower =
                            material.description.toLowerCase();
                        final categoryLower = material.category.toLowerCase();
                        final queryLower = _searchQuery.toLowerCase();

                        return titleLower.contains(queryLower) ||
                            descriptionLower.contains(queryLower) ||
                            categoryLower.contains(queryLower);
                      }).toList();

                      if (filteredMaterials.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(BootstrapIcons.search_heart_fill,
                                  size: 80, color: darkGreyText),
                              SizedBox(height: 16),
                              Text(
                                'Tidak ada materi yang cocok dengan pencarian Anda.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontFamily: 'Work Sans',
                                    fontSize: 16,
                                    color: darkGreyText),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0), // Padding horizontal
                        itemCount: filteredMaterials.length,
                        itemBuilder: (context, index) {
                          LearningMaterialModel material =
                              filteredMaterials[index];
                          bool hasLink = (material.videoUrl != null &&
                                  material.videoUrl!.isNotEmpty) ||
                              (material.documentUrl != null &&
                                  material.documentUrl!.isNotEmpty);

                          return Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            elevation:
                                0, // Mirip notifikasi, elevation 0 untuk Card
                            color: primaryTextColor, // Background Card
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    10)), // Sudut membulat
                            child: ListTile(
                              onTap: () {
                                // Jika ada video atau dokumen, buka linknya
                                if (material.videoUrl != null &&
                                    material.videoUrl!.isNotEmpty) {
                                  _launchUrl(material.videoUrl!);
                                } else if (material.documentUrl != null &&
                                    material.documentUrl!.isNotEmpty) {
                                  _launchUrl(material.documentUrl!);
                                }
                              },
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 12.0),
                              leading: Icon(
                                _getIconForMaterialType(material),
                                color: orangeAccent, // Warna ikon agar menonjol
                                size:
                                    28, // Ukuran ikon agar serasi dengan notifikasi
                              ),
                              title: Text(
                                material.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Work Sans',
                                  color: darkGreyText,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    material.description,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontFamily: 'Work Sans',
                                      fontSize: 12,
                                      color: darkGreyText,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Kategori: ${material.category}',
                                    style: TextStyle(
                                      fontFamily: 'Work Sans',
                                      fontSize: 11,
                                      color: darkGreyText.withOpacity(0.7),
                                    ),
                                  ),
                                  if (material.videoUrl != null &&
                                      material.videoUrl!.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4.0),
                                      child: Row(
                                        children: [
                                          Icon(BootstrapIcons.link_45deg,
                                              size: 16, color: orangeAccent),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              'Link Video',
                                              style: TextStyle(
                                                color: Colors.blue.shade700,
                                                decoration:
                                                    TextDecoration.underline,
                                                fontSize: 12,
                                                fontFamily: 'Work Sans',
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  if (material.documentUrl != null &&
                                      material.documentUrl!.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4.0),
                                      child: Row(
                                        children: [
                                          Icon(BootstrapIcons.link_45deg,
                                              size: 16, color: orangeAccent),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              'Link Dokumen',
                                              style: TextStyle(
                                                color: Colors.blue.shade700,
                                                decoration:
                                                    TextDecoration.underline,
                                                fontSize: 12,
                                                fontFamily: 'Work Sans',
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                              isThreeLine:
                                  hasLink, // Jadikan three-line jika ada link video atau dokumen
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                        BootstrapIcons.pencil_square,
                                        color: darkGreyText), // Warna edit icon
                                    onPressed: () async {
                                      final result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              AddEditLearningMaterialPage(
                                                  material: material),
                                        ),
                                      );
                                      if (result == true) {
                                        // Refresh if changes were made
                                        setState(() {});
                                      }
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(BootstrapIcons.trash,
                                        color: redAccent), // Warna delete icon
                                    onPressed: () => _confirmDeleteMaterial(
                                        material.id, material.title),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    }
                  },
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 16.0,
            right: 16.0,
            child: FloatingActionButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          const AddEditLearningMaterialPage()),
                );
                if (result == true) {
                  // Refresh list if a new material was added
                  setState(() {});
                }
              },
              backgroundColor: orangeAccent, // Warna FAB
              foregroundColor: primaryTextColor, // Warna ikon FAB
              child: const Icon(BootstrapIcons.plus,
                  size: 30), // Ikon plus dari BootstrapIcons
            ),
          ),
        ],
      ),
    );
  }
}
