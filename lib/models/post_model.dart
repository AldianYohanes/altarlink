// altarlink4/lib/models/post_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String id; // ID dokumen dari Firestore
  final String authorId; // UID penulis postingan
  final String authorUsername; // Username penulis (misal: "aldianyhs")
  final String authorFullName; // Nama lengkap penulis
  final String? authorProfileImageUrl; // URL gambar profil penulis (opsional)
  final String?
      imageUrl; // URL gambar postingan (opsional, ini yang jadi kotak merah)
  final String? caption; // Opsional: teks deskripsi untuk gambar/postingan
  final Timestamp createdAt; // Waktu posting
  final List<String> likes; // List UID pengguna yang me-like
  final int
      commentCount; // Jumlah komentar (bisa dihitung dari sub-koleksi nanti)

  PostModel({
    required this.id,
    required this.authorId,
    required this.authorUsername,
    required this.authorFullName,
    this.authorProfileImageUrl,
    this.imageUrl,
    this.caption, // Tambahkan caption
    required this.createdAt,
    this.likes = const [], // Default kosong
    this.commentCount = 0, // Default 0
  });

  // Factory constructor untuk membuat PostModel dari Firestore DocumentSnapshot
  factory PostModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return PostModel(
      id: doc.id,
      authorId: data['authorId'] ?? '',
      authorUsername: data['authorUsername'] ?? '',
      authorFullName: data['authorFullName'] ?? '',
      authorProfileImageUrl: data['authorProfileImageUrl'],
      imageUrl: data['imageUrl'],
      caption: data['caption'], // Ambil caption
      createdAt: data['createdAt'] as Timestamp,
      likes: List<String>.from(data['likes'] ?? []),
      commentCount: data['commentCount'] ?? 0,
    );
  }

  // Metode untuk mengkonversi PostModel ke Map untuk disimpan di Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'authorId': authorId,
      'authorUsername': authorUsername,
      'authorFullName': authorFullName,
      'authorProfileImageUrl': authorProfileImageUrl,
      'imageUrl': imageUrl,
      'caption': caption, // Simpan caption
      'createdAt': createdAt,
      'likes': likes,
      'commentCount': commentCount,
    };
  }
}
