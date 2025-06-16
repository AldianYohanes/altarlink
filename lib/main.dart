// lib/main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';

// FIX: Pastikan ini diimpor! Ini berisi konfigurasi Firebase spesifik proyek Anda.
import 'package:altarlink4/firebase_options.dart';

import 'package:altarlink4/services/auth/auth_service.dart';
import 'package:altarlink4/services/mass_service.dart'; // Import MassService
import 'package:altarlink4/services/attendance_service.dart'; // Import AttendanceService
import 'package:altarlink4/screens/auth/login_screen.dart';
import 'package:altarlink4/screens/auth/signup_screen.dart';
import 'package:altarlink4/screens/main_pages/home_page.dart';
import 'package:altarlink4/screens/main_pages/notifications_page.dart';
import 'package:altarlink4/screens/main_pages/qr_scan_page.dart';
import 'package:altarlink4/screens/main_pages/learning_materials_page.dart';
import 'package:altarlink4/screens/main_pages/account_page.dart';
import 'package:altarlink4/screens/main_pages/mass_information_page.dart';
import 'package:altarlink4/screens/main_pages/admin_panel_page.dart';

import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // FIX PENTING: Inisialisasi Firebase dengan opsi spesifik platform
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await initializeDateFormatting();

  runApp(
    MultiProvider(
      providers: [
        // AuthService sekarang tersedia di seluruh aplikasi
        Provider<AuthService>(create: (_) => AuthService()),
        // FIX: Tambahkan MassService ke provider
        Provider<MassService>(create: (_) => MassService()),
        // FIX: Tambahkan AttendanceService ke provider
        Provider<AttendanceService>(create: (_) => AttendanceService()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AltarLink',
      theme: ThemeData(
        // primarySwatch deprecated, gunakan colorScheme
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(
                0xFFFFA852)), // Menggunakan warna utama dari project Anda
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Work Sans',
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.grey.shade100,
      ),
      debugShowCheckedModeBanner: false,
      home: const AuthWrapper(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const SignUpPage(),
        '/mass_information': (context) => const MassInformationPage(),
        '/admin_panel': (context) => const AdminPanelPage(),
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return StreamBuilder<User?>(
      stream: authService.user,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final User? user = snapshot.data;
          // Mengarahkan ke LoginPage jika user null, jika tidak ke MainScreen
          return user == null ? const LoginPage() : const MainScreen();
        } else {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const NotificationsPage(),
    const QrScanPage(),
    const LearningMaterialsPage(),
    const AccountPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Transform.translate(
        offset: const Offset(0, 10),
        child: SizedBox(
          height: 80,
          width: 80,
          child: FloatingActionButton(
            shape: const CircleBorder(),
            onPressed: () => _onItemTapped(2),
            backgroundColor: const Color(0xFFFFEFA3),
            elevation: 8,
            child: const Icon(
              BootstrapIcons.qr_code_scan,
              color: Color(0xFF25242E),
              size: 38,
            ),
          ),
        ),
      ),
      bottomNavigationBar: CustomFloatingNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}

class CustomFloatingNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const CustomFloatingNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  static const Color _unselectedOutlineIconColor = Color(0xFF8E8DAA);
  static const Color _darkIconColor = Color(0xFF25242E);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 20),
      color: Colors.transparent,
      child: Container(
        height: 65,
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(
              0,
              selectedIndex == 0
                  ? BootstrapIcons.house_fill
                  : BootstrapIcons.house,
              selectedColor: _darkIconColor,
              unselectedColor: _unselectedOutlineIconColor,
            ),
            _buildNavItem(
              1,
              selectedIndex == 1
                  ? BootstrapIcons.bell_fill
                  : BootstrapIcons.bell,
              selectedColor: _darkIconColor,
              unselectedColor: _unselectedOutlineIconColor,
            ),
            const SizedBox(width: 60),
            _buildNavItem(
              3,
              selectedIndex == 3
                  ? BootstrapIcons.book_fill
                  : BootstrapIcons.book,
              selectedColor: _darkIconColor,
              unselectedColor: _unselectedOutlineIconColor,
            ),
            _buildNavItem(
              4,
              selectedIndex == 4
                  ? BootstrapIcons.person_fill
                  : BootstrapIcons.person,
              selectedColor: _darkIconColor,
              unselectedColor: _unselectedOutlineIconColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon,
      {required Color selectedColor, required Color unselectedColor}) {
    bool isSelected = selectedIndex == index;
    return GestureDetector(
      onTap: () => onItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? selectedColor : unselectedColor,
            size: isSelected ? 28 : 24,
          ),
        ],
      ),
    );
  }
}
