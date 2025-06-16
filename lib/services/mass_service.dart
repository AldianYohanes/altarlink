// lib/services/mass_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:altarlink4/models/mass_model.dart';

class MassService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get all masses, ordered by massDateTime
  Stream<List<MassModel>> getMasses() {
    return _firestore
        .collection('masses')
        .orderBy('massDateTime',
            descending: false) // Urutkan dari yang terdekat
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => MassModel.fromFirestore(doc)).toList());
  }

  // Get the single next upcoming mass
  Stream<MassModel?> getNextMass() {
    return _firestore
        .collection('masses')
        .where('massDateTime',
            isGreaterThanOrEqualTo:
                Timestamp.now()) // Ambil yang tanggalnya >= sekarang
        .orderBy('massDateTime',
            descending: false) // Urutkan dari yang terdekat
        .limit(1) // Ambil hanya satu dokumen
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        return MassModel.fromFirestore(snapshot.docs.first);
      }
      return null; // Tidak ada misa mendatang
    });
  }

  // Get a specific mass by its ID (Ditambahkan untuk kebutuhan QR Scan)
  Stream<MassModel?> getMassById(String massId) {
    return _firestore.collection('masses').doc(massId).snapshots().map((doc) {
      if (doc.exists) {
        return MassModel.fromFirestore(doc);
      } else {
        return null;
      }
    });
  }

  // Add a new mass
  Future<void> addMass({
    required String title,
    required String description,
    required Timestamp massDateTime,
    required String liturgyColor,
    String? celebrant,
    String? firstReading,
    String? psalm,
    String? secondReading,
    String? gospel,
    List<String>? misdinarUids,
  }) async {
    await _firestore.collection('masses').add({
      'title': title,
      'description': description,
      'massDateTime': massDateTime,
      'liturgyColor': liturgyColor,
      'celebrant': celebrant,
      'firstReading': firstReading,
      'psalm': psalm,
      'secondReading': secondReading,
      'gospel': gospel,
      'misdinarUids': misdinarUids,
      'createdAt': Timestamp.now(), // Tambahkan timestamp pembuatan
    });
  }

  // Update an existing mass
  Future<void> updateMass(String id, Map<String, dynamic> data) async {
    await _firestore.collection('masses').doc(id).update(data);
  }

  // Delete a mass
  Future<void> deleteMass(String id) async {
    await _firestore.collection('masses').doc(id).delete();
  }
}
