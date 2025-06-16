// lib/services/attendance_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:altarlink4/models/attendance_model.dart'; // Nanti akan kita buat

class AttendanceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Metode untuk merekam kehadiran (check-in/check-out)
  Future<void> recordAttendance({
    required String massId,
    required String userId,
    required double latitude,
    required double longitude,
    required String type, // 'check-in' atau 'check-out'
    String? scannedQrData,
  }) async {
    try {
      await _firestore.collection('attendance').add({
        'massId': massId,
        'userId': userId,
        'timestamp': Timestamp.now(),
        'latitude': latitude,
        'longitude': longitude,
        'type': type,
        'scannedQrData': scannedQrData,
      });
      print(
          'Kehadiran berhasil dicatat untuk Misa ID: $massId, User ID: $userId, Type: $type');
    } catch (e) {
      print('Error mencatat kehadiran: $e');
      rethrow; // Lempar kembali error agar bisa ditangani di UI
    }
  }

  // Metode untuk mendapatkan riwayat kehadiran pengguna tertentu
  Stream<List<AttendanceModel>> getUserAttendance(String userId) {
    return _firestore
        .collection('attendance')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AttendanceModel.fromFirestore(doc))
            .toList());
  }

  // Metode opsional: Dapatkan kehadiran untuk misa tertentu
  Stream<List<AttendanceModel>> getMassAttendance(String massId) {
    return _firestore
        .collection('attendance')
        .where('massId', isEqualTo: massId)
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AttendanceModel.fromFirestore(doc))
            .toList());
  }
}
