// lib/models/user_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String? fullName;
  final String? role;
  final String? profileImageUrl;
  final String? bio;
  final Timestamp createdAt; // Pastikan ini selalu ada

  UserModel({
    required this.uid,
    required this.email,
    this.fullName,
    this.role,
    this.profileImageUrl,
    this.bio,
    required this.createdAt,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      email: data['email'] as String? ?? '', // Pastikan email selalu String
      fullName: data['fullName'] as String?, // Cast eksplisit ke String?
      profileImageUrl:
          data['profileImageUrl'] as String?, // Cast eksplisit ke String?
      role: data['role'] as String?, // Cast eksplisit ke String?
      bio: data['bio'] as String?, // Cast eksplisit ke String?
      createdAt: data['createdAt'] as Timestamp? ??
          Timestamp.now(), // Fallback jika createdAt null/tidak ada
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'fullName': fullName,
      'role': role,
      'profileImageUrl': profileImageUrl,
      'bio': bio,
      'createdAt': createdAt,
    };
  }

  // Getter untuk displayName agar kompatibel dengan kode lain
  String get displayName => fullName ?? email;
}
