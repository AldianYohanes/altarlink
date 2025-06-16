// lib/screens/main_pages/account_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Import untuk DateFormat

import 'package:altarlink4/services/auth/auth_service.dart';
import 'package:altarlink4/models/user_model.dart';
import 'package:altarlink4/screens/main_pages/edit_profile_page.dart';
import 'package:altarlink4/screens/auth/login_screen.dart';
import 'package:altarlink4/services/post_service.dart';
import 'package:altarlink4/models/post_model.dart';
import 'package:altarlink4/screens/main_pages/admin_panel_page.dart';
import 'package:altarlink4/screens/main_pages/full_screen_image_page.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  UserModel? _currentUserData;
  bool _isLoading = true;
  int _selectedTabIndex = 0; // State baru: 0 untuk Posts, 1 untuk About

  final PostService _postService = PostService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // URL gambar random dari Picsum Photos untuk placeholder dan testing
  final String _headerImageUrl =
      'https://picsum.photos/id/1018/1000/300'; // Landscape
  final String _profilePlaceholderUrl =
      'https://picsum.photos/id/1005/200/200'; // Square, untuk profile

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser != null) {
      try {
        final userData = await authService.getUserData(firebaseUser.uid);
        setState(() {
          _currentUserData = userData;
          _isLoading = false;
        });
      } catch (e) {
        print("Error fetching user data: $e");
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Gagal memuat data pengguna: ${e.toString()}')),
        );
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _formatPostTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return DateFormat('d MMMM, HH:mm', 'id').format(dateTime);
  }

  String _formatJoinDate(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return DateFormat('d MMMM yyyy', 'id').format(dateTime);
  }

  bool _isAdminOrOfficer(String? role) {
    return role == 'Admin' ||
        role == 'Ketua' ||
        role == 'Sekretaris' ||
        role == 'Bendahara' ||
        role == 'Pembina';
  }

  void _signOut() async {
    await Provider.of<AuthService>(context, listen: false).signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryTextColor = Color(0xFF25242E);
    const Color redAccent = Color(0xFFFF5252);
    const Color orangeAccent = Color(0xFFFFA852);
    const Color borderColor = Color(0xFFBDBDBD);
    const Color backgroundWhite = Color(0xFFF5F5F5);
    const Color darkGreyText = Color(0xFF535353);

    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: backgroundWhite,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Image.asset(
          'assets/images/altarlink_logo.webp',
          height: 50,
          width: 150,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(Icons.error, color: Colors.red);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _signOut,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _currentUserData == null
              ? const Center(
                  child: Text(
                      'Data pengguna tidak ditemukan. Silakan coba login ulang.'),
                )
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Image (Background Banner) dengan Avatar
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            height: 240,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: NetworkImage(_headerImageUrl),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned.fill(
                            child: Container(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Color(0x99000000),
                                    Color(0x00000000),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 20,
                            bottom: -50,
                            child: GestureDetector(
                              onTap: () {
                                print(
                                    'DEBUG: Profile picture tapped! Navigating to FullScreenImagePage...');
                                final String displayProfileUrl =
                                    _currentUserData!.profileImageUrl != null &&
                                            _currentUserData!
                                                .profileImageUrl!.isNotEmpty
                                        ? _currentUserData!.profileImageUrl!
                                        : _profilePlaceholderUrl;

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => FullScreenImagePage(
                                      imageUrl: displayProfileUrl,
                                      userName: _currentUserData!.fullName,
                                    ),
                                  ),
                                );
                              },
                              child: Hero(
                                tag: _currentUserData!.profileImageUrl ??
                                    'default_profile_pic_hero_tag',
                                child: CircleAvatar(
                                  radius: 50,
                                  backgroundColor: redAccent,
                                  child: ClipOval(
                                    child: Image.network(
                                      (_currentUserData!.profileImageUrl !=
                                                  null &&
                                              _currentUserData!
                                                  .profileImageUrl!.isNotEmpty)
                                          ? _currentUserData!.profileImageUrl!
                                          : _profilePlaceholderUrl,
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                      loadingBuilder:
                                          (context, child, loadingProgress) {
                                        if (loadingProgress == null)
                                          return child;
                                        return Center(
                                          child: CircularProgressIndicator(
                                            value: loadingProgress
                                                        .expectedTotalBytes !=
                                                    null
                                                ? loadingProgress
                                                        .cumulativeBytesLoaded /
                                                    loadingProgress
                                                        .expectedTotalBytes!
                                                : null,
                                            color: Colors.white,
                                          ),
                                        );
                                      },
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        print(
                                            'DEBUG: Error loading profile image in CircleAvatar: $error');
                                        return Icon(Icons.person,
                                            size: 50, color: Colors.white);
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // Tombol Edit Profile & Admin Panel (di dalam Stack, sejajar dengan bagian bawah avatar)
                          Positioned(
                            top:
                                180, // Sesuaikan nilai ini agar tombol pas di bawah banner dan sejajar dengan avatar
                            right: 20,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Flexible(
                                  child: OutlinedButton(
                                    onPressed: () {
                                      print(
                                          'DEBUG: Edit Profile button onPressed triggered.');
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const EditProfilePage(),
                                        ),
                                      ).then((result) {
                                        if (result == true) {
                                          _fetchUserData();
                                        }
                                      });
                                    },
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(
                                          color: borderColor, width: 2),
                                      foregroundColor: borderColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 8),
                                      minimumSize: const Size(100, 30),
                                    ),
                                    child: const Text(
                                      'Edit Profile',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.normal,
                                        fontFamily: 'Work Sans',
                                        color: borderColor,
                                      ),
                                    ),
                                  ),
                                ),
                                if (_isAdminOrOfficer(_currentUserData!.role))
                                  const SizedBox(width: 10),
                                if (_isAdminOrOfficer(_currentUserData!.role))
                                  Flexible(
                                    child: ElevatedButton(
                                      onPressed: () {
                                        print(
                                            'DEBUG: Admin Panel button onPressed triggered.');
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const AdminPanelPage()),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: orangeAccent,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 8),
                                        minimumSize: const Size(100, 30),
                                      ),
                                      child: const Text(
                                        'Admin Panel',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.normal,
                                          fontFamily: 'Work Sans',
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      // Jarak dari bottom Stack ke konten berikutnya
                      // Diperhitungkan dari tinggi Stack (240) dikurangi overlap avatar (50)
                      // 240 - 50 = 190. Sizedbox ini adalah jarak yang tersisa di bawah avatar.
                      // Semakin kecil nilai ini, semakin dekat nama ke avatar.
                      const SizedBox(height: 70), // <--- Mengurangi jarak lagi

                      // Konten utama profil (Nama, Email, Followers, Bio)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20.0, vertical: 10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _currentUserData!.fullName ??
                                  'Nama Tidak Tersedia',
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Work Sans',
                                color: darkGreyText,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _currentUserData!.email,
                              style: TextStyle(
                                fontSize: 18,
                                color: darkGreyText,
                                fontFamily: 'Work Sans',
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Following/Followers dengan bold angka
                            Row(
                              children: [
                                RichText(
                                  text: TextSpan(
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontFamily: 'Work Sans',
                                      color: darkGreyText,
                                    ),
                                    children: <TextSpan>[
                                      TextSpan(
                                        text: '4',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      TextSpan(text: ' Following'),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                RichText(
                                  text: TextSpan(
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontFamily: 'Work Sans',
                                      color: darkGreyText,
                                    ),
                                    children: <TextSpan>[
                                      TextSpan(
                                        text: '5',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      TextSpan(text: ' Followers'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            // Bio (jika ada)
                            if (_currentUserData!.bio != null &&
                                _currentUserData!.bio!.isNotEmpty)
                              Text(
                                _currentUserData!.bio!,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade700,
                                  fontFamily: 'Work Sans',
                                ),
                              ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),

                      // Tab "Posts" / "About"
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              // Jadikan tab Posts bisa diklik
                              onTap: () {
                                setState(() {
                                  _selectedTabIndex = 0; // Set ke tab Posts
                                });
                              },
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 15),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: _selectedTabIndex == 0
                                          ? Colors.black
                                          : Colors
                                              .grey, // Garis hitam jika aktif
                                      width: _selectedTabIndex == 0
                                          ? 2.0
                                          : 1.0, // Tebal jika aktif
                                    ),
                                  ),
                                ),
                                child: Text(
                                  'Posts',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: _selectedTabIndex == 0
                                        ? FontWeight.bold
                                        : FontWeight.normal, // Bold jika aktif
                                    fontFamily: 'Work Sans',
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              // Jadikan tab About bisa diklik
                              onTap: () {
                                setState(() {
                                  _selectedTabIndex = 1; // Set ke tab About
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text('Menampilkan Halaman About')),
                                );
                              },
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 15),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: _selectedTabIndex == 1
                                          ? Colors.black
                                          : Colors
                                              .grey, // Garis hitam jika aktif
                                      width: _selectedTabIndex == 1
                                          ? 2.0
                                          : 1.0, // Tebal jika aktif
                                    ),
                                  ),
                                ),
                                child: Text(
                                  'About',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: _selectedTabIndex == 1
                                        ? FontWeight.bold
                                        : FontWeight.normal, // Bold jika aktif
                                    fontFamily: 'Work Sans',
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Konten berdasarkan tab yang dipilih
                      _selectedTabIndex == 0
                          ? (_currentUserData!.uid.isEmpty
                              ? const Center(
                                  child: Text(
                                      'Tidak dapat memuat postingan tanpa User ID.'))
                              : StreamBuilder<List<PostModel>>(
                                  stream: _postService
                                      .getUserPosts(_currentUserData!.uid),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const Center(
                                          child: CircularProgressIndicator());
                                    } else if (snapshot.hasError) {
                                      print(
                                          'Error fetching user posts: ${snapshot.error}');
                                      return Center(
                                          child: Text(
                                              'Error memuat postingan: ${snapshot.error}',
                                              style: const TextStyle(
                                                  color: Colors.red)));
                                    } else if (!snapshot.hasData ||
                                        snapshot.data!.isEmpty) {
                                      return const Padding(
                                        padding: EdgeInsets.all(20.0),
                                        child: Center(
                                            child: Text(
                                                'Anda belum membuat postingan.')),
                                      );
                                    } else {
                                      List<PostModel> userPosts =
                                          snapshot.data!;
                                      return ListView.builder(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemCount: userPosts.length,
                                        itemBuilder: (context, index) {
                                          PostModel post = userPosts[index];
                                          return _buildPostFeedItem(
                                              context, post);
                                        },
                                      );
                                    }
                                  },
                                ))
                          : _buildAboutContent(), // Menampilkan konten About jika tab 1 aktif
                    ],
                  ),
                ),
    );
  }

  // Widget terpisah untuk menampilkan setiap item feed postingan
  Widget _buildPostFeedItem(BuildContext context, PostModel post) {
    const Color redAccent = Color(0xFFFF5252);
    const Color darkGreyText = Color(0xFF535353);
    final String postAuthorPlaceholderUrl =
        'https://picsum.photos/id/1005/200/200';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: redAccent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    print(
                        'DEBUG: Author profile picture tapped! Navigating...');
                    final String displayAuthorProfileUrl =
                        post.authorProfileImageUrl != null &&
                                post.authorProfileImageUrl!.isNotEmpty
                            ? post.authorProfileImageUrl!
                            : postAuthorPlaceholderUrl;

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FullScreenImagePage(
                          imageUrl: displayAuthorProfileUrl,
                          userName: post.authorFullName,
                        ),
                      ),
                    );
                  },
                  child: Hero(
                    tag: post.authorProfileImageUrl ??
                        'default_author_pic_hero_tag_${post.id}',
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: redAccent,
                      child: ClipOval(
                        child: Image.network(
                          (post.authorProfileImageUrl != null &&
                                  post.authorProfileImageUrl!.isNotEmpty)
                              ? post.authorProfileImageUrl!
                              : postAuthorPlaceholderUrl,
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes !=
                                        null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                                color: Colors.white,
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            print(
                                'DEBUG: Error loading author image in CircleAvatar: $error');
                            return const Icon(Icons.person,
                                size: 20, color: Colors.white);
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  post.authorUsername,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.normal,
                    fontFamily: 'Work Sans',
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                Text(
                  _formatPostTimestamp(post.createdAt),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                    fontFamily: 'Work Sans',
                  ),
                ),
              ],
            ),
          ),
          if (post.imageUrl != null && post.imageUrl!.isNotEmpty)
            Container(
              height: 250,
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(post.imageUrl!),
                  fit: BoxFit.cover,
                ),
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(20)),
              ),
              child: null,
            )
          else
            Container(
              height: 250,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(20)),
              ),
              child: const Center(
                child: Icon(Icons.image_not_supported,
                    size: 60, color: Colors.grey),
              ),
            ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            child: Text(
              post.caption ?? '',
              style: const TextStyle(
                fontSize: 16,
                fontFamily: 'Work Sans',
                color: Colors.white,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  // Widget baru untuk menampilkan konten "About"
  Widget _buildAboutContent() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tentang ${_currentUserData!.fullName ?? 'Pengguna Ini'}',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              fontFamily: 'Work Sans',
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 1,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Bio:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Work Sans',
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _currentUserData!.bio != null &&
                            _currentUserData!.bio!.isNotEmpty
                        ? _currentUserData!.bio!
                        : 'Tidak ada bio yang tersedia.',
                    style: const TextStyle(
                      fontSize: 16,
                      fontFamily: 'Work Sans',
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Tanggal Bergabung:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Work Sans',
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _currentUserData!.createdAt != null
                        ? _formatJoinDate(_currentUserData!.createdAt)
                        : 'Tanggal tidak tersedia.',
                    style: const TextStyle(
                      fontSize: 16,
                      fontFamily: 'Work Sans',
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Peran:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Work Sans',
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _currentUserData!.role ?? 'Anggota',
                    style: const TextStyle(
                      fontSize: 16,
                      fontFamily: 'Work Sans',
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Anda bisa menambahkan informasi lain di sini, seperti:
          // Text('Detail lainnya...', style: TextStyle(fontSize: 16, color: Colors.black54)),
        ],
      ),
    );
  }
}
