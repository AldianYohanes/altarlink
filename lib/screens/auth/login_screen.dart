// lib/screens/auth/login_screen.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:altarlink4/services/auth/auth_service.dart'; // Pastikan path ini benar
import 'package:altarlink4/screens/auth/signup_screen.dart'; // Pastikan path ini benar
import 'package:altarlink4/main.dart'; // Untuk MainScreen setelah login

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // text controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscureText = true; // Untuk toggle visibility password

  final AuthService _auth = AuthService(); // Instance of AuthService

  void _signIn() async {
    try {
      User? user = await _auth.signInWithEmailAndPassword(
        _emailController.text,
        _passwordController.text,
      );

      if (user != null) {
        // Jika login berhasil, navigasi ke MainScreen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      } else {
        // Handle login failure (e.g., show error message)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Login failed. Please check your credentials.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error during sign-in: ${e.toString()}')),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white, // Background utama putih
      body: Stack(
        children: [
          // Background Ovals (blur effect)
          Positioned(
            left: -screenWidth * 0.35, // Adjust as needed
            top: -screenHeight * 0.05, // Adjust as needed
            child: Container(
              width: screenWidth * 1.2,
              height: screenWidth * 1.2, // Make it circular
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFF7F7F7),
                    Color(0xFFF9F5E1)
                  ], // Top oval colors
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.5),
                    blurRadius: 25.0, // Equivalent to filter: blur(25px)
                    spreadRadius: 10.0,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            right: -screenWidth * 0.35, // Adjust as needed
            bottom: -screenHeight * 0.05, // Adjust as needed
            child: Container(
              width: screenWidth * 1.2,
              height: screenWidth * 1.2,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFF9F5E1),
                    Color(0xFFFFD4D4)
                  ], // Bottom oval colors
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
                  SizedBox(height: screenHeight * 0.1), // Jarak ke input fields

                  // Email Input
                  _buildInputField(
                    controller: _emailController,
                    hintText: 'Email Address',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  SizedBox(
                      height: screenHeight * 0.03), // Jarak antar input fields

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
                  SizedBox(
                      height: screenHeight * 0.05), // Jarak ke tombol login

                  // Login Button
                  GestureDetector(
                    onTap: _signIn,
                    child: Container(
                      width: screenWidth * 0.4, // Lebar tombol proporsional
                      height: screenHeight * 0.07, // Tinggi tombol proporsional
                      decoration: BoxDecoration(
                        color:
                            const Color(0xFFFF5252), // Warna merah dari desain
                        borderRadius:
                            BorderRadius.circular(139), // Border radius besar
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
                          'Log In',
                          style: TextStyle(
                            fontFamily: 'Work Sans',
                            fontSize:
                                screenWidth * 0.05, // Ukuran font proporsional
                            fontWeight: FontWeight.w400,
                            color: const Color(
                                0xFFFFF1A8), // Warna kuning dari desain
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                      height: screenHeight * 0.08), // Jarak ke teks "Sign In"

                  // Don't have an account? Sign In
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: TextStyle(
                          fontFamily: 'Work Sans',
                          fontSize: screenWidth * 0.035,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF535353),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const SignUpPage()),
                          );
                        },
                        child: Text(
                          "Sign In",
                          style: TextStyle(
                            fontFamily: 'Work Sans',
                            fontSize: screenWidth * 0.035,
                            fontWeight: FontWeight.w400,
                            color: const Color(
                                0xFF007BFF), // Contoh warna link biru
                            decoration:
                                TextDecoration.underline, // Opsional: underline
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

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return Container(
      height: 60, // Tinggi fixed untuk input field
      decoration: BoxDecoration(
        color: const Color(0xFFECECEC), // Warna background dari desain
        borderRadius: BorderRadius.circular(139), // Rounded corners
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        style: TextStyle(
          fontFamily: 'Work Sans',
          fontSize: 18, // Ukuran font dalam input
          color: const Color(0xFF535353),
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            fontFamily: 'Work Sans',
            fontSize: 18,
            color:
                const Color(0xFF535353).withOpacity(0.7), // Sedikit transparan
          ),
          border: InputBorder.none, // Hapus border default TextField
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 25, vertical: 15), // Padding teks
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }
}
