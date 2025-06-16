// lib/screens/main_pages/home_page.dart

import 'package:flutter/material.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart'; // Import Bootstrap Icons
import 'package:cloud_firestore/cloud_firestore.dart'; // Untuk Timestamp
import 'package:firebase_auth/firebase_auth.dart'; // Untuk mendapatkan user ID saat ini (untuk likes)
import 'package:intl/intl.dart'; // Untuk format tanggal/waktu yang lebih mudah

import 'package:altarlink4/screens/main_pages/create_post_page.dart';
import 'package:altarlink4/services/post_service.dart'; // Import PostService
import 'package:altarlink4/models/post_model.dart'; // Import PostModel

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PostService _postService = PostService();
  final FirebaseAuth _auth = FirebaseAuth.instance; // Instance Firebase Auth

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Image.asset(
              'assets/images/altarlink_logo.webp',
              height: 50,
              width: 150,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.error, color: Colors.red);
              },
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(BootstrapIcons.plus_square,
                color: Color(0xFF25242E)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CreatePostPage()),
              );
            },
          ),
          IconButton(
            icon:
                const Icon(BootstrapIcons.chat_dots, color: Color(0xFF25242E)),
            onPressed: () {
              // TODO: Aksi untuk tombol chat
            },
          ),
        ],
      ),
      body: StreamBuilder<List<PostModel>>(
        stream: _postService
            .getPosts(), // Mendengarkan stream postingan dari Firestore
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator()); // Tampilkan loading
          } else if (snapshot.hasError) {
            print('Error fetching posts: ${snapshot.error}'); // Debugging error
            return Center(
                child: Text(
                    'Error memuat postingan: ${snapshot.error}')); // Tampilkan error
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
                child: Text('Belum ada postingan.')); // Jika tidak ada data
          } else {
            List<PostModel> posts = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.only(
                  top: 8,
                  bottom: 100), // Padding bawah agar tidak terhalang nav bar
              itemCount: posts.length + 1, // +1 untuk GlobalHeaderWidget
              itemBuilder: (context, index) {
                if (index == 0) {
                  // Widget pertama adalah GlobalHeaderWidget
                  return const GlobalHeaderWidget();
                }
                // Postingan dimulai dari index 1
                PostModel post = posts[
                    index - 1]; // Sesuaikan index untuk mengambil postingan

                // Mendapatkan user ID untuk mengecek status like
                final String? currentUserId = _auth.currentUser?.uid;
                bool isLiked =
                    currentUserId != null && post.likes.contains(currentUserId);

                return PostCard(
                  post: post,
                  isLiked: isLiked,
                  onLikeToggle: () {
                    if (currentUserId != null) {
                      _postService.toggleLike(
                          postId: post.id, userId: currentUserId);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                'Anda perlu login untuk menyukai postingan.')),
                      );
                    }
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}

// Widget untuk Global Header (tanggal, perayaan, ayat, motivasi)
class GlobalHeaderWidget extends StatelessWidget {
  const GlobalHeaderWidget({super.key});

  // Data ini bisa diambil dari Firestore terpisah di masa depan (misal: daily_announcements)
  // Untuk saat ini, kita hardcode sesuai permintaan.
  final String date = '5 Juni 2025';
  final String celebration = 'Misa Hari Raya Tubuh dan Darah Kristus';
  final String verseReference = '1 Tesalonika 5:17';
  final String dailyMotivation = '"Doa bukan soal mood, tetapi disiplin kasih"';

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
          16.0, 0, 16.0, 16.0), // Margin bottom untuk pemisah
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      date,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF535353),
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Work Sans',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      celebration,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'Work Sans',
                        color: Color(0xFF535353),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.menu,
                  color: Color(0xFF535353), size: 24), // Ikon menu (tiga garis)
            ],
          ),
          const Divider(height: 20, thickness: 1, color: Color(0xFFE0E0E0)),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFECECEC),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dailyMotivation,
                  style: const TextStyle(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: Color(0xFF535353),
                    fontFamily: 'Work Sans',
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    verseReference,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                      color: Color(0xFF535353),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Widget untuk setiap Postingan
class PostCard extends StatelessWidget {
  final PostModel post; // Sekarang menerima objek PostModel
  final bool isLiked; // Status apakah user sudah like postingan ini
  final VoidCallback onLikeToggle; // Callback saat tombol like ditekan

  const PostCard({
    super.key,
    required this.post,
    required this.isLiked,
    required this.onLikeToggle,
  });

  // Helper untuk format waktu
  String _formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    Duration difference = DateTime.now().difference(dateTime);

    if (difference.inSeconds < 60) {
      return '${difference.inSeconds} seconds ago';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return DateFormat('d MMM yyyy').format(dateTime); // Contoh: 1 Jan 2023
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bagian atas postingan (Profil, Username, Timestamp)
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: const Color(0xFFFF5252), // Warna merah default
                backgroundImage: post.authorProfileImageUrl != null &&
                        post.authorProfileImageUrl!.isNotEmpty
                    ? NetworkImage(
                        post.authorProfileImageUrl!) // Jika ada gambar profil
                    : null,
                child: post.authorProfileImageUrl == null ||
                        post.authorProfileImageUrl!.isEmpty
                    ? Icon(Icons.person,
                        color: Colors.white.withOpacity(0.8),
                        size: 25) // Icon default jika tidak ada gambar
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.authorUsername, // Username dari PostModel
                      style: const TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 15,
                        fontFamily: 'Work Sans',
                        color: Color(0xFF535353),
                      ),
                    ),
                    Text(
                      _formatTimestamp(
                          post.createdAt), // Timestamp dari PostModel
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF8E8DAA),
                        fontFamily: 'Work Sans',
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.more_vert,
                  color: Color(0xFF535353),
                  size: 24), // Opsi postingan (menu 3 titik)
            ],
          ),
          const SizedBox(height: 16),

          // Gambar Postingan (kotak merah atau gambar asli)
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: post.imageUrl == null || post.imageUrl!.isEmpty
                ? Container(
                    height: 200,
                    width: double.infinity,
                    color: const Color(0xFFFF5252), // Warna merah dari CSS
                    child: Center(
                      child: Text(
                        post.caption ??
                            'No Caption', // Tampilkan caption jika ada
                        style:
                            const TextStyle(color: Colors.white, fontSize: 18),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : Image.network(
                    post.imageUrl!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 200,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: 200,
                        color: Colors.grey.shade300,
                        child: Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      print(
                          'Error loading image: $error'); // Debugging error loading image
                      return Container(
                        height: 200,
                        width: double.infinity,
                        color: Colors.red.shade600,
                        child: const Center(
                          child: Icon(Icons.broken_image,
                              color: Colors.white, size: 50),
                        ),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 16),

          // Caption Postingan (jika ada gambar)
          if (post.caption != null &&
              post.imageUrl !=
                  null) // Tampilkan caption jika ada dan ada gambar
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Text(
                post.caption!,
                style: const TextStyle(
                  fontSize: 14,
                  fontFamily: 'Work Sans',
                  color: Color(0xFF535353),
                ),
              ),
            ),

          // Tombol Like dan Komentar
          Row(
            children: [
              GestureDetector(
                onTap:
                    onLikeToggle, // Panggil callback saat tombol like ditekan
                child: Icon(
                  isLiked
                      ? BootstrapIcons.heart_fill
                      : BootstrapIcons.heart, // Ikon like (filled/outline)
                  color: isLiked
                      ? Colors.red
                      : const Color(0xFF8E8DAA), // Warna merah jika dilike
                  size: 20,
                ),
              ),
              const SizedBox(width: 5),
              Text(
                post.likes.length.toString(), // Jumlah like dari PostModel
                style: const TextStyle(
                    color: Color(0xFF8E8DAA),
                    fontSize: 16,
                    fontFamily: 'Work Sans'),
              ),
              const SizedBox(width: 20),
              GestureDetector(
                onTap: () {
                  // TODO: Aksi untuk tombol komentar (misal: buka halaman komentar)
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content:
                            Text('Komentar untuk postingan ID: ${post.id}')),
                  );
                },
                child: const Icon(BootstrapIcons.chat,
                    color: Color(0xFF8E8DAA), size: 20), // Ikon komentar
              ),
              const SizedBox(width: 5),
              Text(
                post.commentCount.toString(), // Jumlah komentar dari PostModel
                style: const TextStyle(
                    color: Color(0xFF8E8DAA),
                    fontSize: 16,
                    fontFamily: 'Work Sans'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Duplikasi informasi penulis di bagian bawah (sesuai desain)
          Row(
            children: [
              CircleAvatar(
                radius: 15,
                backgroundColor: const Color(0xFFFF5252),
                backgroundImage: post.authorProfileImageUrl != null &&
                        post.authorProfileImageUrl!.isNotEmpty
                    ? NetworkImage(post.authorProfileImageUrl!)
                    : null,
                child: post.authorProfileImageUrl == null ||
                        post.authorProfileImageUrl!.isEmpty
                    ? Icon(Icons.person,
                        color: Colors.white.withOpacity(0.8), size: 18)
                    : null,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.authorUsername, // Username dari PostModel
                      style: const TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 13,
                        fontFamily: 'Work Sans',
                        color: Color(0xFF535353),
                      ),
                    ),
                    Text(
                      _formatTimestamp(
                          post.createdAt), // Timestamp dari PostModel
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF8E8DAA),
                        fontFamily: 'Work Sans',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
