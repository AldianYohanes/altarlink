// lib/screens/admin_panel/add_edit_learning_material_page.dart

import 'package:flutter/material.dart';
import 'package:altarlink4/models/learning_material_model.dart';
import 'package:altarlink4/services/learning_material_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Perlu Timestamp
import 'package:bootstrap_icons/bootstrap_icons.dart'; // Import untuk ikon

class AddEditLearningMaterialPage extends StatefulWidget {
  final LearningMaterialModel? material; // Materi yang akan diedit (opsional)

  const AddEditLearningMaterialPage({super.key, this.material});

  @override
  State<AddEditLearningMaterialPage> createState() =>
      _AddEditLearningMaterialPageState();
}

class _AddEditLearningMaterialPageState
    extends State<AddEditLearningMaterialPage> {
  final _formKey = GlobalKey<FormState>();
  final LearningMaterialService _learningMaterialService =
      LearningMaterialService();

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _videoUrlController;
  late TextEditingController _documentUrlController;

  late String _selectedCategory; // Untuk dropdown kategori
  final List<String> _categories = [
    'Umum',
    'Liturgi',
    'Doa',
    'Organisasi',
    'Sejarah'
  ]; // Contoh kategori

  bool _isLoading = false;

  // Definisikan warna yang konsisten sesuai tab notifikasi
  static const Color primaryTextColor =
      Color(0xFFFFFFFF); // Background Card, Input Fields
  static const Color orangeAccent =
      Color(0xFFFFA852); // Accent color for buttons, icons, focused borders
  static const Color backgroundWhite =
      Color(0xFFF5F5F5); // Main Scaffold/Container background
  static const Color darkGreyText = Color(0xFF535353); // General text color
  static const Color borderColor = Color(0xFFBDBDBD); // Outline border color

  final int _kMaxDescriptionLength = 250; // Batasan karakter untuk deskripsi

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _videoUrlController = TextEditingController();
    _documentUrlController = TextEditingController();

    // Jika ada materi yang diteruskan (mode edit), isi form
    if (widget.material != null) {
      _titleController.text = widget.material!.title;
      _descriptionController.text = widget.material!.description;
      _videoUrlController.text = widget.material!.videoUrl ?? '';
      _documentUrlController.text = widget.material!.documentUrl ?? '';
      _selectedCategory = widget.material!.category;
    } else {
      // Set default category untuk mode tambah baru
      _selectedCategory = 'Umum';
    }
  }

  // Helper untuk mendapatkan ikon berdasarkan kategori
  IconData _getIconForCategory(String category) {
    switch (category.toLowerCase()) {
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

  // Fungsi untuk menyimpan atau memperbarui materi pembelajaran
  Future<void> _saveLearningMaterial() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final String? videoUrl = _videoUrlController.text.trim().isEmpty
            ? null
            : _videoUrlController.text.trim();
        final String? documentUrl = _documentUrlController.text.trim().isEmpty
            ? null
            : _documentUrlController.text.trim();

        if (widget.material == null) {
          // Mode Create: Tambah materi baru
          await _learningMaterialService.addLearningMaterial(
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim(),
            videoUrl: videoUrl,
            documentUrl: documentUrl,
            category: _selectedCategory,
          );
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Materi berhasil ditambahkan!')),
            );
          }
        } else {
          // Mode Update: Perbarui materi yang sudah ada
          LearningMaterialModel updatedMaterial = LearningMaterialModel(
            id: widget.material!.id,
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim(),
            videoUrl: videoUrl,
            documentUrl: documentUrl,
            category: _selectedCategory,
            createdAt: widget
                .material!.createdAt, // Pertahankan tanggal pembuatan asli
          );
          await _learningMaterialService
              .updateLearningMaterial(updatedMaterial);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Materi berhasil diperbarui!')),
            );
          }
        }
        if (mounted) {
          Navigator.pop(context,
              true); // Kembali ke halaman sebelumnya dan beritahu ada perubahan
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal menyimpan materi: ${e.toString()}')),
          );
        }
        print('Error saving learning material: $e');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _videoUrlController.dispose();
    _documentUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundWhite, // Background Scaffold
      appBar: AppBar(
        title: Text(
          widget.material == null ? 'Tambah Materi Baru' : 'Edit Materi',
          style: const TextStyle(
            color: primaryTextColor, // Warna teks di AppBar
            fontFamily: 'Work Sans',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: orangeAccent, // Background AppBar
        foregroundColor: primaryTextColor, // Warna ikon back di AppBar
        elevation: 1,
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                  color: orangeAccent)) // Warna progress indicator
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start, // Align to start for labels
                  children: [
                    Text(
                      'Judul Materi',
                      style: TextStyle(
                          fontFamily: 'Work Sans',
                          fontWeight: FontWeight.bold,
                          color: darkGreyText,
                          fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        hintText: 'Masukkan judul materi',
                        filled: true,
                        fillColor: primaryTextColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: borderColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: orangeAccent, width: 2),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: borderColor),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Judul tidak boleh kosong';
                        }
                        return null;
                      },
                      style: const TextStyle(
                          fontFamily: 'Work Sans', color: darkGreyText),
                      cursorColor: orangeAccent,
                      maxLength: 100, // Batasan karakter
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Deskripsi Singkat',
                      style: TextStyle(
                          fontFamily: 'Work Sans',
                          fontWeight: FontWeight.bold,
                          color: darkGreyText,
                          fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: 'Masukkan deskripsi singkat materi',
                        filled: true,
                        fillColor: primaryTextColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: borderColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: orangeAccent, width: 2),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: borderColor),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Deskripsi tidak boleh kosong';
                        }
                        return null;
                      },
                      style: const TextStyle(
                          fontFamily: 'Work Sans', color: darkGreyText),
                      cursorColor: orangeAccent,
                      maxLength: _kMaxDescriptionLength, // Batasan karakter
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Kategori Materi',
                      style: TextStyle(
                          fontFamily: 'Work Sans',
                          fontWeight: FontWeight.bold,
                          color: darkGreyText,
                          fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: InputDecoration(
                        hintText: 'Pilih kategori',
                        filled: true,
                        fillColor: primaryTextColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: borderColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: orangeAccent, width: 2),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: borderColor),
                        ),
                      ),
                      dropdownColor:
                          primaryTextColor, // Warna background dropdown
                      items: _categories.map((String category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Row(
                            // Tambahkan ikon di Dropdown
                            children: [
                              Icon(
                                _getIconForCategory(category),
                                color: darkGreyText,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                category,
                                style: const TextStyle(
                                    fontFamily: 'Work Sans',
                                    color: darkGreyText),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedCategory = newValue!;
                        });
                      },
                      validator: (value) =>
                          value == null ? 'Pilih kategori materi' : null,
                      style: const TextStyle(
                          fontFamily: 'Work Sans',
                          color: darkGreyText), // Warna teks selected
                      iconEnabledColor: darkGreyText, // Warna ikon dropdown
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'URL Video (Opsional)',
                      style: TextStyle(
                          fontFamily: 'Work Sans',
                          fontWeight: FontWeight.bold,
                          color: darkGreyText,
                          fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _videoUrlController,
                      decoration: InputDecoration(
                        hintText:
                            'Misal: https://www.youtube.com/watch?v=xxxxxxxx',
                        filled: true,
                        fillColor: primaryTextColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: borderColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: orangeAccent, width: 2),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: borderColor),
                        ),
                      ),
                      keyboardType: TextInputType.url,
                      style: const TextStyle(
                          fontFamily: 'Work Sans', color: darkGreyText),
                      cursorColor: orangeAccent,
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          final uri = Uri.tryParse(value);
                          if (uri == null || !uri.hasAbsolutePath) {
                            return 'Masukkan URL yang valid';
                          }
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'URL Dokumen (Opsional)',
                      style: TextStyle(
                          fontFamily: 'Work Sans',
                          fontWeight: FontWeight.bold,
                          color: darkGreyText,
                          fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _documentUrlController,
                      decoration: InputDecoration(
                        hintText:
                            'Misal: https://docs.google.com/document/d/xxxxxxxx/edit',
                        filled: true,
                        fillColor: primaryTextColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: borderColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: orangeAccent, width: 2),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: borderColor),
                        ),
                      ),
                      keyboardType: TextInputType.url,
                      style: const TextStyle(
                          fontFamily: 'Work Sans', color: darkGreyText),
                      cursorColor: orangeAccent,
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          final uri = Uri.tryParse(value);
                          if (uri == null || !uri.hasAbsolutePath) {
                            return 'Masukkan URL yang valid';
                          }
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveLearningMaterial,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: orangeAccent, // Warna tombol
                          foregroundColor:
                              primaryTextColor, // Warna teks tombol
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          widget.material == null
                              ? 'Tambah Materi'
                              : 'Simpan Perubahan',
                          style: const TextStyle(
                              fontSize: 18,
                              fontFamily: 'Work Sans',
                              fontWeight: FontWeight.bold),
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
