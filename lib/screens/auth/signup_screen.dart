// lib/screens/auth/signup_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Digunakan untuk tipe data User
import 'package:altarlink4/services/auth/auth_service.dart'; // Pastikan path ini benar
import 'package:altarlink4/main.dart'; // Untuk MainScreen setelah sign up

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  // text controllers
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _obscureText = true; // Untuk toggle visibility password
  bool _obscureConfirmText =
      true; // Untuk toggle visibility konfirmasi password

  final AuthService _auth = AuthService(); // Instance of AuthService

  void _signUp() async {
    // Reset pesan error
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Password dan Konfirmasi Password tidak cocok.')),
      );
      return;
    }

    try {
      User? user = await _auth.signUpWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _fullNameController.text.trim(),
      );

      if (user != null) {
        // Jika sign up berhasil, navigasi ke MainScreen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      } else {
        // Handle sign up failure (e.g., show error message)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Pendaftaran gagal. Email mungkin sudah terdaftar atau password terlalu lemah.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saat pendaftaran: ${e.toString()}')),
      );
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background Ovals (blur effect) - sama seperti login_page
          Positioned(
            left: -screenWidth * 0.35,
            top: -screenHeight * 0.05,
            child: Container(
              width: screenWidth * 1.2,
              height: screenWidth * 1.2,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFFF7F7F7), Color(0xFFF9F5E1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.5),
                    blurRadius: 25.0,
                    spreadRadius: 10.0,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            right: -screenWidth * 0.35,
            bottom: -screenHeight * 0.05,
            child: Container(
              width: screenWidth * 1.2,
              height: screenWidth * 1.2,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFFF9F5E1), Color(0xFFFFD4D4)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.5),
                    blurRadius: 25.0,
                    spreadRadius: 10.0,
                  ),
                ],
              ),
            ),
          ),

          // Main Content
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo AltarLink
                  Image.asset(
                    'assets/images/altarlink_logo.webp',
                    height: screenHeight * 0.15,
                    width: screenWidth * 0.9,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.error,
                          color: Colors.red, size: 50);
                    },
                  ),
                  SizedBox(height: screenHeight * 0.1),

                  // Full Name Input
                  _buildInputField(
                    controller: _fullNameController,
                    hintText: 'Nama Lengkap',
                    keyboardType: TextInputType.text,
                  ),
                  SizedBox(height: screenHeight * 0.03),

                  // Email Input
                  _buildInputField(
                    controller: _emailController,
                    hintText: 'Email Address',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  SizedBox(height: screenHeight * 0.03),

                  // Password Input
                  _buildInputField(
                    controller: _passwordController,
                    hintText: 'Password',
                    obscureText: _obscureText,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureText ? Icons.visibility_off : Icons.visibility,
                        color: const Color(0xFF535353),
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.03),

                  // Confirm Password Input
                  _buildInputField(
                    controller: _confirmPasswordController,
                    hintText: 'Konfirmasi Password',
                    obscureText: _obscureConfirmText,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmText
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: const Color(0xFF535353),
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmText = !_obscureConfirmText;
                        });
                      },
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.05),

                  // Daftar Button
                  GestureDetector(
                    onTap: _signUp,
                    child: Container(
                      width: screenWidth * 0.4,
                      height: screenHeight * 0.07,
                      decoration: BoxDecoration(
                        color:
                            const Color(0xFFFF5252), // Warna merah dari desain
                        borderRadius: BorderRadius.circular(139),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            spreadRadius: 2,
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          'Daftar', // Teks tombol "Daftar"
                          style: TextStyle(
                            fontFamily: 'Work Sans',
                            fontSize: screenWidth * 0.05,
                            fontWeight: FontWeight.w400,
                            color: const Color(
                                0xFFFFF1A8), // Warna kuning dari desain
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.08),

                  // Back to Login Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Sudah punya akun? ",
                        style: TextStyle(
                          fontFamily: 'Work Sans',
                          fontSize: screenWidth * 0.035,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF535353),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context); // Kembali ke halaman login
                        },
                        child: Text(
                          "Login di sini",
                          style: TextStyle(
                            fontFamily: 'Work Sans',
                            fontSize: screenWidth * 0.035,
                            fontWeight: FontWeight.w400,
                            color: const Color(
                                0xFF007BFF), // Contoh warna link biru
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper Widget for Input Fields - reusable
  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: const Color(0xFFECECEC),
        borderRadius: BorderRadius.circular(139),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        style: TextStyle(
          fontFamily: 'Work Sans',
          fontSize: 18,
          color: const Color(0xFF535353),
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            fontFamily: 'Work Sans',
            fontSize: 18,
            color: const Color(0xFF535353).withOpacity(0.7),
          ),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }
}
