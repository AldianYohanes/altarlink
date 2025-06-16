// lib/services/learning_material_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:altarlink4/models/learning_material_model.dart';

class LearningMaterialService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Mengambil stream semua materi pembelajaran dari Firestore
  Stream<List<LearningMaterialModel>> getLearningMaterials() {
    return _firestore
        .collection('learning_materials')
        .orderBy('createdAt',
            descending: true) // Urutkan berdasarkan tanggal dibuat
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => LearningMaterialModel.fromFirestore(doc))
            .toList());
  }

  // Menambah materi pembelajaran baru
  Future<void> addLearningMaterial({
    required String title,
    required String description,
    required String category,
    String? videoUrl,
    String? documentUrl,
  }) async {
    LearningMaterialModel newMaterial = LearningMaterialModel(
      id: '', // ID akan digenerate Firestore
      title: title,
      description: description,
      category: category,
      videoUrl: videoUrl,
      documentUrl: documentUrl,
      createdAt: Timestamp.now(), // Gunakan Timestamp.now()
    );

    await _firestore
        .collection('learning_materials')
        .add(newMaterial.toFirestore());
  }

  // Mengupdate materi pembelajaran yang sudah ada
  // MODIFIKASI: Menerima objek LearningMaterialModel
  Future<void> updateLearningMaterial(LearningMaterialModel material) async {
    if (material.id.isEmpty) {
      throw Exception("Material ID cannot be empty for update operation.");
    }
    await _firestore
        .collection('learning_materials')
        .doc(material.id)
        .update(material.toFirestore());
  }

  // Menghapus materi pembelajaran
  Future<void> deleteLearningMaterial(String materialId) async {
    await _firestore.collection('learning_materials').doc(materialId).delete();
  }
}
