// lib/screens/main_pages/edit_profile_page.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart'; // <<-- Import ini
import 'dart:io'; // <<-- Import ini untuk File
import 'package:firebase_storage/firebase_storage.dart'; // <<-- Import ini

import 'package:altarlink4/models/user_model.dart';
import 'package:altarlink4/services/auth/auth_service.dart'; // Pastikan ini diimpor

class EditProfilePage extends StatefulWidget {
  // FIX: Konstruktor tidak memiliki initialUserData
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  String? _selectedRole;
  final List<String> _roles = [
    'Anggota',
    'Ketua',
    'Sekretaris',
    'Bendahara',
    'Admin', // Pastikan 'Admin' ada jika ingin bisa dipilih
    'Pembina', // Pindahkan ini setelah Admin jika ingin urutan logis
  ];

  final AuthService _authService = AuthService();
  User? _currentUser;
  bool _isLoading = true; // Tetap true saat initState
  String? _errorMessage;

  File? _pickedImage; // Untuk gambar yang dipilih dari galeri/kamera
  String?
      _currentProfileImageUrl; // Untuk URL gambar profil yang sudah ada dari Firestore

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
    _loadUserData(); // Memuat data pengguna saat ini
  }

  Future<void> _loadUserData() async {
    if (_currentUser == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Tidak ada pengguna yang login.';
      });
      return;
    }

    try {
      UserModel? userData = await _authService.getUserData(_currentUser!.uid);
      if (userData != null) {
        _fullNameController.text = userData.fullName ?? '';
        _bioController.text = userData.bio ?? '';
        setState(() {
          _selectedRole = userData.role;
          _currentProfileImageUrl = userData
              .profileImageUrl; // FIX: Ambil URL gambar profil yang sudah ada
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage =
              'Gagal memuat data profil. Pastikan data profil ada di Firestore.';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error saat memuat data: ${e.toString()}';
      });
      print('Error loading user data for edit: $e');
    }
  }

  // Fungsi untuk memilih gambar dari galeri
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _pickedImage = File(pickedFile.path);
      });
    }
  }

  // Fungsi untuk mengunggah gambar ke Firebase Storage
  Future<String?> _uploadImage() async {
    if (_pickedImage == null) {
      return _currentProfileImageUrl; // Jika tidak ada gambar baru, gunakan URL yang sudah ada
    }

    if (_currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Tidak ada pengguna yang login untuk mengunggah gambar.')),
      );
      return null;
    }

    try {
      // Path di Firebase Storage: profile_images/{user_uid}.jpg
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child('${_currentUser!.uid}.jpg');

      await storageRef.putFile(_pickedImage!);
      final downloadUrl = await storageRef.getDownloadURL();
      print('Profile image uploaded to Storage: $downloadUrl');
      return downloadUrl;
    } on FirebaseException catch (e) {
      print('Firebase Storage Error uploading image: ${e.code} - ${e.message}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Gagal mengunggah foto profil (Storage Error): ${e.message}')),
      );
      return null;
    } catch (e) {
      print('General Error uploading image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Gagal mengunggah foto profil: ${e.toString()}')),
      );
      return null;
    }
  }

  Future<void> _saveProfile() async {
    setState(() {
      _errorMessage = null;
      _isLoading = true; // Set loading saat menyimpan
    });

    if (_currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Anda belum login untuk menyimpan profil.')),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      // Unggah gambar terlebih dahulu
      String? newProfileImageUrl = await _uploadImage();

      // Jika user memilih gambar baru tapi upload gagal, jangan lanjutkan
      if (_pickedImage != null && newProfileImageUrl == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      Map<String, dynamic> updateData = {
        'fullName': _fullNameController.text.trim(),
        'bio': _bioController.text.trim(),
        'role': _selectedRole,
        'profileImageUrl': newProfileImageUrl, // Update URL gambar profil
      };

      await _authService.updateUserData(_currentUser!.uid, updateData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil berhasil diperbarui!')),
      );

      if (mounted) {
        Navigator.pop(
            context, true); // Pop dengan hasil 'true' untuk refresh data
      }
    } on Exception catch (e) {
      setState(() {
        _isLoading = false; // Hentikan loading saat ada error
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
      print('Error saving profile via AuthService: $e');
    } catch (e) {
      setState(() {
        _isLoading = false; // Hentikan loading saat ada error
        _errorMessage = 'Error menyimpan profil: ${e.toString()}';
      });
      print('Unexpected error saving profile: $e');
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Edit Profil'),
          backgroundColor: Colors.blue.shade700,
          foregroundColor: Colors.white,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Edit Profil'),
          backgroundColor: Colors.blue.shade700,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red, fontSize: 16),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profil'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 70,
                    backgroundColor: Colors.grey.shade200,
                    // Menampilkan gambar yang baru dipilih atau gambar profil yang sudah ada
                    backgroundImage: _pickedImage != null
                        ? FileImage(_pickedImage!) as ImageProvider<Object>?
                        : (_currentProfileImageUrl != null &&
                                _currentProfileImageUrl!.isNotEmpty
                            ? NetworkImage(_currentProfileImageUrl!)
                                as ImageProvider<Object>?
                            : null),
                    // Jika tidak ada gambar (baru atau lama), tampilkan ikon person
                    child: (_pickedImage == null &&
                            (_currentProfileImageUrl == null ||
                                _currentProfileImageUrl!.isEmpty))
                        ? Icon(
                            Icons.person,
                            size: 70,
                            color: Colors.grey.shade700,
                          )
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _pickImage, // Panggil fungsi untuk memilih gambar
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _fullNameController,
              decoration: const InputDecoration(
                labelText: 'Nama Lengkap',
                border: OutlineInputBorder(),
              ),
              style: const TextStyle(fontFamily: 'Work Sans'),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _selectedRole,
              decoration: const InputDecoration(
                labelText: 'Peran di Misdinar',
                border: OutlineInputBorder(),
              ),
              items: _roles.map((String role) {
                return DropdownMenuItem<String>(
                  value: role,
                  child: Text(role,
                      style: const TextStyle(fontFamily: 'Work Sans')),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedRole = newValue;
                });
              },
              validator: (value) => value == null ? 'Pilih peran Anda' : null,
              style:
                  const TextStyle(fontFamily: 'Work Sans', color: Colors.black),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _bioController,
              decoration: const InputDecoration(
                labelText: 'Bio / Deskripsi Diri',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 3,
              keyboardType: TextInputType.multiline,
              style: const TextStyle(fontFamily: 'Work Sans'),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _saveProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade700,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              child: const Text('Simpan Perubahan',
                  style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
