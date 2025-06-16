// lib/screens/admin_panel/edit_user_details_page.dart

import 'package:flutter/material.dart';
import 'package:altarlink4/models/user_model.dart';
import 'package:altarlink4/services/auth/auth_service.dart'; // Gunakan AuthService
import 'package:bootstrap_icons/bootstrap_icons.dart'; // Import untuk ikon Bootstrap

class EditUserDetailsPage extends StatefulWidget {
  final UserModel user; // Pengguna yang akan diedit oleh admin

  const EditUserDetailsPage({super.key, required this.user});

  @override
  State<EditUserDetailsPage> createState() => _EditUserDetailsPageState();
}

class _EditUserDetailsPageState extends State<EditUserDetailsPage> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  String? _selectedRole;
  final List<String> _roles = [
    'Anggota',
    'Ketua',
    'Sekretaris',
    'Bendahara',
    'Pembina',
    'Admin'
  ];

  final AuthService _authService = AuthService();
  bool _isLoading = false;
  String? _errorMessage;

  // Definisikan warna yang konsisten sesuai tab notifikasi dan materi
  static const Color primaryTextColor = Color(0xFFFFFFFF);
  static const Color orangeAccent = Color(0xFFFFA852);
  static const Color backgroundWhite = Color(0xFFF5F5F5);
  static const Color darkGreyText = Color(0xFF535353);
  static const Color borderColor = Color(0xFFBDBDBD);
  static const Color redAccent = Color(0xFFFF5252);

  @override
  void initState() {
    super.initState();
    // Isi controller dengan data pengguna yang diterima
    _fullNameController.text = widget.user.fullName ?? '';
    _bioController.text = widget.user.bio ?? '';
    _selectedRole = widget.user.role;
  }

  // Helper untuk mendapatkan ikon berdasarkan peran
  IconData _getIconForRole(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return BootstrapIcons.incognito; // Admin bisa ikon khusus
      case 'ketua':
        return BootstrapIcons.award;
      case 'sekretaris':
        return BootstrapIcons.pencil_square;
      case 'bendahara':
        return BootstrapIcons.cash_coin;
      case 'pembina':
        return BootstrapIcons.person_vcard;
      case 'anggota':
      default:
        return BootstrapIcons.person;
    }
  }

  Future<void> _saveUserChanges() async {
    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    try {
      Map<String, dynamic> updateData = {
        'fullName': _fullNameController.text.trim(),
        'bio': _bioController.text.trim(),
        'role': _selectedRole,
      };

      // Gunakan AuthService untuk mengupdate data pengguna
      await _authService.updateUserData(widget.user.uid, updateData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil pengguna berhasil diperbarui!')),
        );
      }

      if (mounted) {
        Navigator.pop(context,
            true); // Kembali ke halaman AdminUsersPage dan beri tahu bahwa ada perubahan
      }
    } on Exception catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
      print('Error saving user profile by admin: $e');
    } catch (e) {
      setState(() {
        _errorMessage = 'Error menyimpan perubahan: ${e.toString()}';
      });
      print('Unexpected error saving user profile by admin: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
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
    return Scaffold(
      backgroundColor: backgroundWhite, // Background Scaffold
      appBar: AppBar(
        title: Text(
          'Edit Pengguna: ${widget.user.fullName ?? widget.user.email}',
          style: const TextStyle(
              color: primaryTextColor,
              fontFamily: 'Work Sans',
              fontWeight: FontWeight.bold),
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
              padding: const EdgeInsets.all(16.0), // Consistent padding
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start, // Align labels to start
                children: [
                  Text(
                    'Email',
                    style: TextStyle(
                        fontFamily: 'Work Sans',
                        fontWeight: FontWeight.bold,
                        color: darkGreyText,
                        fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  // Email Field (Non-editable)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 15),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: primaryTextColor,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: borderColor),
                    ),
                    child: Text(
                      widget.user.email,
                      style: const TextStyle(
                          fontSize: 16,
                          color: darkGreyText,
                          fontFamily: 'Work Sans'),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Text(
                    'Nama Lengkap',
                    style: TextStyle(
                        fontFamily: 'Work Sans',
                        fontWeight: FontWeight.bold,
                        color: darkGreyText,
                        fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _fullNameController,
                    decoration: InputDecoration(
                      hintText: 'Masukkan nama lengkap',
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
                    style: const TextStyle(
                        fontFamily: 'Work Sans', color: darkGreyText),
                    cursorColor: orangeAccent,
                  ),
                  const SizedBox(height: 16),

                  Text(
                    'Peran di Misdinar',
                    style: TextStyle(
                        fontFamily: 'Work Sans',
                        fontWeight: FontWeight.bold,
                        color: darkGreyText,
                        fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedRole,
                    decoration: InputDecoration(
                      hintText: 'Pilih peran',
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
                    items: _roles.map((String role) {
                      return DropdownMenuItem<String>(
                        value: role,
                        child: Row(
                          // Tambahkan ikon di Dropdown
                          children: [
                            Icon(
                              _getIconForRole(role),
                              color: darkGreyText,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              role,
                              style: const TextStyle(
                                  fontFamily: 'Work Sans', color: darkGreyText),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedRole = newValue;
                      });
                    },
                    style: const TextStyle(
                        fontFamily: 'Work Sans', color: darkGreyText),
                    iconEnabledColor: darkGreyText,
                  ),
                  const SizedBox(height: 16),

                  Text(
                    'Bio / Deskripsi Diri (Opsional)',
                    style: TextStyle(
                        fontFamily: 'Work Sans',
                        fontWeight: FontWeight.bold,
                        color: darkGreyText,
                        fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _bioController,
                    decoration: InputDecoration(
                      hintText: 'Tulis bio singkat tentang pengguna ini',
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
                      alignLabelWithHint: true, // Untuk multiline label
                    ),
                    maxLines: 4,
                    keyboardType: TextInputType.multiline,
                    style: const TextStyle(
                        fontFamily: 'Work Sans', color: darkGreyText),
                    cursorColor: orangeAccent,
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
                            fontFamily: 'Work Sans'),
                      ),
                    ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveUserChanges,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: orangeAccent,
                        foregroundColor: primaryTextColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Simpan Perubahan',
                          style: TextStyle(
                              fontSize: 18,
                              fontFamily: 'Work Sans',
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
