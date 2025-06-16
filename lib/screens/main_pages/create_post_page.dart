// lib/screens/main_pages/create_post_page.dart

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // For picking images
import 'package:altarlink4/services/post_service.dart'; // For uploading posts
import 'dart:io'; // For File

class CreatePostPage extends StatefulWidget {
  const CreatePostPage({super.key});

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final TextEditingController _captionController = TextEditingController();
  final PostService _postService = PostService();
  XFile? _selectedImage; // To store the selected image file
  bool _isLoading = false; // Loading status when posting

  // Function to pick image from gallery or camera
  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    // Compress image quality to 80% for faster upload and reduced storage
    final XFile? image =
        await picker.pickImage(source: source, imageQuality: 80);

    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  }

  // Function to create a new post
  Future<void> _createPost() async {
    // Validate: Post cannot be empty (must have either an image or a caption)
    if (_selectedImage == null && _captionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Postingan tidak boleh kosong (gambar atau caption).')),
      );
      return;
    }

    setState(() {
      _isLoading = true; // Set loading status to true
    });

    try {
      // Add the post via PostService
      await _postService.addPost(
        caption: _captionController.text.trim(),
        imageFile: _selectedImage,
      );

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Postingan berhasil dibuat!')),
      );

      // Navigate back to the previous page (HomePage) after successful post
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      // Show error message if posting fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal membuat postingan: ${e.toString()}')),
      );
      print('Error creating post: $e'); // Log error for debugging
    } finally {
      setState(() {
        _isLoading = false; // Set loading status to false
      });
    }
  }

  // Dialog to choose image source (gallery/camera)
  void _showImageSourceActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Ambil dari Kamera'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Pilih dari Galeri'),
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

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white, // White AppBar background
        elevation: 1, // Subtle shadow below AppBar
        // Replicate the title row with AltarLink logo
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Image.asset(
              'assets/images/altarlink_logo.webp',
              height: 50, // Adjusted height for logo
              width: 150, // Adjusted width for logo
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.error, color: Colors.red);
              },
            ),
          ],
        ),
        // Action buttons on the right side of AppBar
        actions: [
          _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                      color: Color(0xFF25242E))) // Dark spinner
              : TextButton(
                  onPressed: _createPost,
                  child: const Text(
                    'Bagikan', // "Share" text like Instagram
                    style: TextStyle(
                      color: Color(
                          0xFF25242E), // Dark text color for contrast on white AppBar
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image Preview Area
            AspectRatio(
              // Using AspectRatio to maintain aspect ratio for the image
              aspectRatio:
                  1 / 1, // 1:1 aspect ratio, common for Instagram feed images
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: _selectedImage != null
                        ? ClipRRect(
                            // ClipRRect for rounded corners on the image itself
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(
                              File(_selectedImage!.path),
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                          )
                        : Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.photo_library_outlined,
                                    size: 50, color: Colors.grey[500]),
                                const SizedBox(height: 10),
                                Text(
                                  'Ketuk untuk memilih gambar',
                                  style: TextStyle(
                                      color: Colors.grey[600],
                                      fontFamily: 'Work Sans'),
                                ),
                              ],
                            ),
                          ),
                  ),
                  // Delete image button (only visible if an image is selected)
                  if (_selectedImage != null)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedImage = null; // Clear the selected image
                          });
                        },
                        child: const CircleAvatar(
                          radius: 15,
                          backgroundColor:
                              Colors.black54, // Dark transparent background
                          child: Icon(Icons.close,
                              color: Colors.white,
                              size: 18), // White close icon
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Button to pick image (minimalist style)
            OutlinedButton.icon(
              onPressed: () => _showImageSourceActionSheet(context),
              icon: const Icon(Icons.add_photo_alternate_outlined),
              label: const Text('Ubah/Tambah Gambar'),
              style: OutlinedButton.styleFrom(
                foregroundColor:
                    const Color(0xFF25242E), // Dark text/icon color
                side: const BorderSide(
                    color: Color(0xFFE0E0E0)), // Light grey border
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10), // Rounded corners
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
                textStyle: const TextStyle(
                    fontFamily: 'Work Sans', fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(height: 24),

            // Caption Input (minimalist Instagram style)
            TextField(
              controller: _captionController,
              decoration: const InputDecoration(
                hintText: 'Tulis caption Anda di sini...',
                border: InputBorder.none, // No border
                focusedBorder: InputBorder.none, // No border when focused
                enabledBorder: InputBorder.none, // No border when enabled
                contentPadding: EdgeInsets.symmetric(
                    horizontal: 0, vertical: 8.0), // Adjusted padding
                hintStyle:
                    TextStyle(fontFamily: 'Work Sans', color: Colors.grey),
              ),
              maxLines: null, // Auto-expand
              minLines: 1,
              keyboardType: TextInputType.multiline,
              style: const TextStyle(
                  fontFamily: 'Work Sans',
                  fontSize: 16,
                  color: Color(0xFF25242E)),
            ),
            // Optional: Divider below caption for aesthetic separation
            const Divider(height: 1, thickness: 0.5, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
