// lib/screens/admin_panel/edit_post_page.dart

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:altarlink4/models/post_model.dart';
import 'package:altarlink4/services/post_service.dart';
import 'dart:io';

class EditPostPage extends StatefulWidget {
  final PostModel post; // Postingan yang akan diedit oleh admin

  const EditPostPage({super.key, required this.post});

  @override
  State<EditPostPage> createState() => _EditPostPageState();
}

class _EditPostPageState extends State<EditPostPage> {
  final TextEditingController _captionController = TextEditingController();
  final PostService _postService = PostService();
  XFile? _selectedImage; // Untuk menyimpan gambar baru yang dipilih
  bool _isLoading = false;
  String? _errorMessage;

  // Definisikan warna yang konsisten
  static const Color primaryTextColor = Color(0xFFF5F5F5); // Background AppBar
  static const Color orangeAccent = Color(0xFFFFA852); // Tombol, fokus border
  static const Color backgroundWhite =
      Color(0xFFF5F5F5); // Latar belakang Scaffold
  static const Color darkGreyText = Color(0xFF535353); // Warna teks dan ikon
  static const Color redAccent = Color(0xFFFF5252); // Untuk pesan error
  static const Color borderColor = Color(0xFFBDBDBD); // Untuk border

  @override
  void initState() {
    super.initState();
    _captionController.text = widget.post.caption ?? '';
  }

  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image =
        await picker.pickImage(source: source, imageQuality: 80);

    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  }

  void _showImageSourceActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.camera_alt,
                    color: darkGreyText), // Warna ikon
                title: const Text('Ambil dari Kamera',
                    style: TextStyle(
                        fontFamily: 'Work Sans', color: darkGreyText)),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library,
                    color: darkGreyText), // Warna ikon
                title: const Text('Pilih dari Galeri',
                    style: TextStyle(
                        fontFamily: 'Work Sans', color: darkGreyText)),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _savePostChanges() async {
    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    try {
      String? updatedImageUrl;
      if (_selectedImage != null) {
        updatedImageUrl = await _postService.uploadImage(_selectedImage!);
      } else {
        updatedImageUrl = widget.post.imageUrl;
      }

      Map<String, dynamic> updateData = {
        'caption': _captionController.text.trim(),
        'imageUrl': updatedImageUrl,
      };

      await _postService.updatePost(widget.post.id, updateData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Postingan berhasil diperbarui!')),
        );
        Navigator.pop(context, true); // Kembali dan berikan sinyal berhasil
      }
    } on Exception catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
      print('Error saving post by admin: $e');
      if (e.toString().contains('firebase_storage')) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'Error Storage: ${e.toString()}\nPastikan billing Firebase aktif dan aturan Storage benar.')),
          );
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error menyimpan perubahan: ${e.toString()}';
      });
      print('Unexpected error saving post by admin: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundWhite, // Latar belakang konsisten
      appBar: AppBar(
        title: const Text(
          'Edit Postingan',
          style: TextStyle(
            color: darkGreyText, // Warna teks judul AppBar
            fontWeight: FontWeight.bold,
            fontFamily: 'Work Sans',
          ),
        ),
        backgroundColor: primaryTextColor, // Warna AppBar
        foregroundColor: darkGreyText, // Warna ikon dan panah kembali
        elevation: 1,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AspectRatio(
                    aspectRatio: 1 / 1,
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[
                                100], // Warna background gambar placeholder
                            borderRadius: BorderRadius.circular(10),
                            border:
                                Border.all(color: borderColor), // Warna border
                          ),
                          child: _selectedImage != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.file(
                                    File(_selectedImage!.path),
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                  ),
                                )
                              : (widget.post.imageUrl != null &&
                                      widget.post.imageUrl!.isNotEmpty
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.network(
                                        widget.post.imageUrl!,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: double.infinity,
                                        loadingBuilder:
                                            (context, child, loadingProgress) {
                                          if (loadingProgress == null)
                                            return child;
                                          return Center(
                                              child: CircularProgressIndicator(
                                                  color:
                                                      orangeAccent)); // Warna loading
                                        },
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Center(
                                              child: Icon(Icons.broken_image,
                                                  size: 50,
                                                  color:
                                                      darkGreyText)); // Warna ikon error
                                        },
                                      ),
                                    )
                                  : Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.photo_library_outlined,
                                              size: 50,
                                              color:
                                                  darkGreyText), // Warna ikon
                                          const SizedBox(height: 10),
                                          Text(
                                            'Tidak ada gambar',
                                            style: TextStyle(
                                                color: darkGreyText,
                                                fontFamily: 'Work Sans'),
                                          ),
                                        ],
                                      ),
                                    )),
                        ),
                        if (_selectedImage != null)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedImage = null;
                                });
                              },
                              child: const CircleAvatar(
                                radius: 15,
                                backgroundColor: Colors.black54,
                                child: Icon(Icons.close,
                                    color: Colors.white, size: 18),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () => _showImageSourceActionSheet(context),
                    icon: const Icon(Icons.add_photo_alternate_outlined,
                        color: orangeAccent), // Warna ikon
                    label: const Text('Pilih/Ubah Gambar Postingan'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: darkGreyText, // Warna teks
                      side:
                          const BorderSide(color: borderColor), // Warna border
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      textStyle: const TextStyle(
                          fontFamily: 'Work Sans', fontWeight: FontWeight.w500),
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _captionController,
                    decoration: InputDecoration(
                      hintText: 'Tulis caption Anda di sini...',
                      hintStyle: TextStyle(
                          fontFamily: 'Work Sans',
                          color: Colors.grey.shade600), // Warna hint
                      border: InputBorder.none,
                      focusedBorder: UnderlineInputBorder(
                        // Border saat fokus
                        borderSide: BorderSide(color: orangeAccent, width: 2),
                      ),
                      enabledBorder: UnderlineInputBorder(
                        // Border saat tidak fokus
                        borderSide: BorderSide(color: borderColor, width: 1),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 0, vertical: 8.0),
                    ),
                    maxLines: null,
                    minLines: 1,
                    keyboardType: TextInputType.multiline,
                    style: const TextStyle(
                        fontFamily: 'Work Sans',
                        fontSize: 16,
                        color: darkGreyText), // Warna teks input
                  ),
                  const SizedBox(height: 30),
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20.0),
                      child: Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: redAccent,
                            fontSize: 14,
                            fontFamily: 'Work Sans'), // Warna error
                      ),
                    ),
                  ElevatedButton(
                    onPressed: _savePostChanges,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: orangeAccent, // Warna tombol
                      foregroundColor: Colors.white, // Warna teks tombol
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Simpan Perubahan',
                        style:
                            TextStyle(fontSize: 18, fontFamily: 'Work Sans')),
                  ),
                ],
              ),
            ),
    );
  }
}
