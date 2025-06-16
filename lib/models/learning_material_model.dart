// lib/models/learning_material_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class LearningMaterialModel {
  String id;
  String title;
  String description;
  String category;
  String? videoUrl;
  String? documentUrl;
  Timestamp createdAt; // Pastikan ini Timestamp

  LearningMaterialModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    this.videoUrl,
    this.documentUrl,
    required this.createdAt, // Pastikan konstruktor menerima Timestamp
  });

  factory LearningMaterialModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return LearningMaterialModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? 'Umum',
      videoUrl: data['videoUrl'],
      documentUrl: data['documentUrl'],
      createdAt: data['createdAt'] as Timestamp, // Cast langsung ke Timestamp
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'videoUrl': videoUrl,
      'documentUrl': documentUrl,
      'createdAt': createdAt, // Simpan sebagai Timestamp
    };
  }
}
