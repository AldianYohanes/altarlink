// lib/screens/admin_panel/admin_users_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:altarlink4/services/auth/auth_service.dart';
import 'package:altarlink4/models/user_model.dart';
import 'package:altarlink4/screens/admin_panel/edit_user_details_page.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart'; // Import untuk ikon Bootstrap

class AdminUsersPage extends StatefulWidget {
  const AdminUsersPage({super.key});

  @override
  State<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends State<AdminUsersPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Daftar peran yang tersedia
  final List<String> _roles = [
    'Anggota',
    'Ketua',
    'Sekretaris',
    'Bendahara',
    'Pembina',
    'Admin'
  ];

  // Definisikan warna yang konsisten sesuai tab notifikasi dan materi
  static const Color primaryTextColor =
      Color(0xFFFFFFFF); // Background Card, Input Fields, FAB Icon
  static const Color orangeAccent =
      Color(0xFFFFA852); // Accent color for buttons, icons, focused borders
  static const Color backgroundWhite =
      Color(0xFFF5F5F5); // Main Scaffold/Container background
  static const Color darkGreyText =
      Color(0xFF535353); // General text color, primary for dark elements
  static const Color redAccent = Color(0xFFFF5252); // Delete icon/button color
  static const Color borderColor = Color(0xFFBDBDBD); // Outline border color
  static const Color currentUserHighlightColor = Color(
      0xFFFFF8E1); // Warna background khusus untuk user saat ini (krem muda)

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
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

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return Container(
      color: backgroundWhite,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari pengguna...',
                hintStyle: TextStyle(
                    fontFamily: 'Work Sans',
                    color: darkGreyText.withOpacity(0.6)),
                prefixIcon: Icon(BootstrapIcons.search, color: darkGreyText),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon:
                            Icon(BootstrapIcons.x_circle, color: darkGreyText),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(100), // Mirip search bar notifikasi
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
              style:
                  const TextStyle(fontFamily: 'Work Sans', color: darkGreyText),
              cursorColor: orangeAccent,
            ),
          ),
          Expanded(
            child: StreamBuilder<List<UserModel>>(
              stream: authService
                  .getUsersStream(), // Mengambil semua pengguna dari AuthService
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                      child: CircularProgressIndicator(color: orangeAccent));
                } else if (snapshot.hasError) {
                  print(
                      "Error fetching users for admin panel: ${snapshot.error}");
                  return Center(
                      child: Text(
                    'Error memuat pengguna: ${snapshot.error}',
                    style: const TextStyle(
                        fontFamily: 'Work Sans', color: redAccent),
                  ));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(BootstrapIcons.person_x,
                            size: 80, color: darkGreyText),
                        const SizedBox(height: 16),
                        Text(
                          'Tidak ada pengguna ditemukan.',
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
                  List<UserModel> users = snapshot.data!;
                  final currentAdminUid = authService.currentUser?.uid;

                  // Cari pengguna saat ini
                  UserModel? currentUserModel;
                  List<UserModel> otherUsers = [];

                  for (var user in users) {
                    if (user.uid == currentAdminUid) {
                      currentUserModel = user;
                    } else {
                      otherUsers.add(user);
                    }
                  }

                  // Gabungkan list: current user (jika ada) di paling atas, diikuti user lainnya
                  List<UserModel> displayUsers = [];
                  if (currentUserModel != null) {
                    displayUsers.add(currentUserModel);
                  }
                  displayUsers.addAll(otherUsers);

                  // Filter pengguna berdasarkan query pencarian (terapkan pada displayUsers)
                  final filteredUsers = displayUsers.where((user) {
                    final fullNameLower = user.fullName?.toLowerCase() ?? '';
                    final emailLower = user.email.toLowerCase();
                    final roleLower = user.role?.toLowerCase() ?? '';
                    final queryLower = _searchQuery.toLowerCase();

                    return fullNameLower.contains(queryLower) ||
                        emailLower.contains(queryLower) ||
                        roleLower.contains(queryLower);
                  }).toList();

                  if (filteredUsers.isEmpty && _searchQuery.isNotEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(BootstrapIcons.search_heart_fill,
                              size: 80, color: darkGreyText),
                          const SizedBox(height: 16),
                          Text(
                            'Tidak ada pengguna yang cocok dengan pencarian Anda.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontFamily: 'Work Sans',
                                fontSize: 16,
                                color: darkGreyText),
                          ),
                        ],
                      ),
                    );
                  } else if (filteredUsers.isEmpty && _searchQuery.isEmpty) {
                    return Center(
                      // Kondisi jika data kosong dan tidak ada pencarian
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(BootstrapIcons.person_x,
                              size: 80, color: darkGreyText),
                          const SizedBox(height: 16),
                          Text(
                            'Tidak ada pengguna ditemukan.',
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
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: filteredUsers.length,
                    itemBuilder: (context, index) {
                      UserModel user = filteredUsers[index];
                      final bool isCurrentUser = user.uid == currentAdminUid;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        elevation: 0,
                        color: isCurrentUser
                            ? currentUserHighlightColor // Warna background khusus
                            : primaryTextColor, // Warna background default
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 12.0),
                          leading: CircleAvatar(
                            radius: 25,
                            backgroundColor: borderColor,
                            backgroundImage: (user.profileImageUrl != null &&
                                    user.profileImageUrl!.isNotEmpty)
                                ? NetworkImage(user.profileImageUrl!)
                                : null,
                            child: (user.profileImageUrl == null ||
                                    user.profileImageUrl!.isEmpty)
                                ? const Icon(BootstrapIcons.person_fill,
                                    size: 25, color: primaryTextColor)
                                : null,
                          ),
                          title: Row(
                            children: [
                              Text(
                                user.fullName ?? user.email,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Work Sans',
                                  color: darkGreyText,
                                ),
                              ),
                              if (isCurrentUser)
                                const Padding(
                                  padding: EdgeInsets.only(left: 8.0),
                                  child: Chip(
                                    label: Text('Anda (Admin)',
                                        style: TextStyle(
                                            fontFamily: 'Work Sans',
                                            fontSize: 12,
                                            color: primaryTextColor)),
                                    backgroundColor: orangeAccent,
                                    materialTapTargetSize: MaterialTapTargetSize
                                        .shrinkWrap, // Membuat chip lebih kecil
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 0),
                                  ),
                                ),
                            ],
                          ),
                          subtitle: Text(
                            'Peran: ${user.role ?? 'Anggota'}\nEmail: ${user.email}',
                            style: const TextStyle(
                              fontFamily: 'Work Sans',
                              color: darkGreyText,
                            ),
                          ),
                          trailing: isCurrentUser
                              ? null // Tidak ada tombol edit untuk user sendiri
                              : IconButton(
                                  icon: const Icon(BootstrapIcons.pencil_square,
                                      color: darkGreyText), // Ikon edit
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            EditUserDetailsPage(user: user),
                                      ),
                                    );
                                  },
                                ),
                          isThreeLine: true,
                          onTap: () {
                            print('DEBUG: Tapped on user: ${user.fullName}');
                          },
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
    );
  }
}
