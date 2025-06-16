// lib/screens/main_pages/learning_materials_page.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Untuk Timestamp
import 'package:intl/intl.dart'; // Untuk format tanggal
import 'package:url_launcher/url_launcher.dart'; // Untuk membuka URL

import 'package:altarlink4/services/learning_material_service.dart'; // Import LearningMaterialService
import 'package:altarlink4/models/learning_material_model.dart'; // Import LearningMaterialModel

class LearningMaterialsPage extends StatefulWidget {
  const LearningMaterialsPage({super.key});

  @override
  State<LearningMaterialsPage> createState() => _LearningMaterialsPageState();
}

class _LearningMaterialsPageState extends State<LearningMaterialsPage> {
  final LearningMaterialService _learningMaterialService =
      LearningMaterialService();

  // Helper untuk membuka URL
  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tidak dapat membuka link: $url')),
      );
    }
  }

  // Helper untuk mendapatkan ikon berdasarkan kategori atau tipe URL
  IconData _getIconForMaterialType(LearningMaterialModel material) {
    if (material.videoUrl != null && material.videoUrl!.isNotEmpty) {
      return Icons.play_circle_outline; // Ikon video
    } else if (material.documentUrl != null &&
        material.documentUrl!.isNotEmpty) {
      return Icons.description_outlined; // Ikon dokumen
    } else {
      // Ikon berdasarkan kategori jika tidak ada URL
      switch (material.category.toLowerCase()) {
        case 'liturgi':
          return Icons.church_outlined;
        case 'doa':
          return Icons.auto_stories_outlined; // Ikon buku doa
        case 'organisasi':
          return Icons.group_outlined; // Ikon grup
        case 'umum':
        default:
          return Icons.lightbulb_outline; // Ikon ide/info umum
      }
    }
  }

  // Helper untuk format tanggal materi ditambahkan
  String _formatMaterialDate(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return DateFormat('d MMM yyyy').format(dateTime); // Contoh: 7 Juni 2025
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Image.asset(
              'assets/images/altarlink_logo.webp',
              height: 50,
              width: 150,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.error, color: Colors.red);
              },
            ),
          ],
        ),
        actions: const [], // Tidak ada ikon aksi di sini
      ),
      body: StreamBuilder<List<LearningMaterialModel>>(
        stream: _learningMaterialService
            .getLearningMaterials(), // Mengambil materi dari service
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator()); // Loading
          } else if (snapshot.hasError) {
            print(
                'Error fetching learning materials: ${snapshot.error}'); // Debugging error
            return Center(
                child: Text('Error memuat materi: ${snapshot.error}',
                    style: TextStyle(color: Colors.red))); // Tampilkan error
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
                child:
                    Text('Belum ada materi pembelajaran.')); // Tidak ada data
          } else {
            List<LearningMaterialModel> materials = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.only(
                  top: 8,
                  bottom: 100,
                  left: 16,
                  right: 16), // Padding bawah agar tidak terhalang nav bar
              itemCount: materials.length,
              itemBuilder: (context, index) {
                LearningMaterialModel material = materials[index];
                return Padding(
                  padding: const EdgeInsets.only(
                      bottom: 10), // Jarak antar LearningMaterialTile
                  child: LearningMaterialTile(
                    material: material,
                    getIconForMaterialType: _getIconForMaterialType,
                    formatMaterialDate: _formatMaterialDate,
                    onTap: () {
                      // Jika ada video URL, buka video
                      if (material.videoUrl != null &&
                          material.videoUrl!.isNotEmpty) {
                        _launchUrl(material.videoUrl!);
                      }
                      // Jika ada dokumen URL, buka dokumen
                      else if (material.documentUrl != null &&
                          material.documentUrl!.isNotEmpty) {
                        _launchUrl(material.documentUrl!);
                      }
                      // Opsional: Jika tidak ada URL, bisa tampilkan detail atau pesan
                      else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  'Tidak ada link terkait untuk materi ini.')),
                        );
                      }
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}

// Widget untuk setiap Materi Pembelajaran Individual
class LearningMaterialTile extends StatelessWidget {
  final LearningMaterialModel material;
  final Function(LearningMaterialModel) getIconForMaterialType;
  final Function(Timestamp) formatMaterialDate;
  final VoidCallback onTap; // Callback saat tile ditekan

  const LearningMaterialTile({
    super.key,
    required this.material,
    required this.getIconForMaterialType,
    required this.formatMaterialDate,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // Menambahkan onTap ke GestureDetector
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              getIconForMaterialType(
                  material), // Ambil ikon berdasarkan tipe/kategori
              color: const Color(0xFF8E8DAA),
              size: 30,
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    material.title, // Judul dari LearningMaterialModel
                    style: const TextStyle(
                      fontFamily: 'Work Sans',
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      color: Color(0xFF25242E), // Warna teks judul lebih gelap
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    material
                        .description, // Deskripsi dari LearningMaterialModel
                    style: const TextStyle(
                      fontFamily: 'Work Sans',
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      color: Color(0xFF535353), // Warna teks deskripsi
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Kategori: ${material.category}', // Tampilkan kategori
                    style: const TextStyle(
                      fontFamily: 'Work Sans',
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  formatMaterialDate(
                      material.createdAt), // Tanggal dari LearningMaterialModel
                  style: const TextStyle(
                    fontFamily: 'Work Sans',
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                    color: Color(0xFF8E8DAA),
                  ),
                ),
                if (material.videoUrl != null &&
                        material.videoUrl!.isNotEmpty ||
                    material.documentUrl != null &&
                        material.documentUrl!.isNotEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: Icon(Icons.open_in_new,
                        size: 20, color: Colors.blue), // Ikon link/buka
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
