// lib/models/notification_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  String id;
  String title;
  String description;
  final Timestamp createdAt; // PASTIKAN TIPE INI ADALAH 'Timestamp'
  String type;
  String? imageUrl;
  String? targetLink;
  List<String> readBy;

  NotificationModel({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt, // Konstruktor juga menerima 'Timestamp'
    required this.type,
    this.imageUrl,
    this.targetLink,
    required this.readBy,
  });

  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return NotificationModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      createdAt: data['createdAt'] as Timestamp, // Langsung cast ke Timestamp
      type: data['type'] ?? 'info',
      imageUrl: data['imageUrl'],
      targetLink: data['targetLink'],
      readBy: List<String>.from(data['readBy'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'createdAt': createdAt, // Langsung gunakan 'Timestamp'
      'type': type,
      'imageUrl': imageUrl,
      'targetLink': targetLink,
      'readBy': readBy,
    };
  }
}
