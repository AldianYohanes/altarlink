// lib/models/attendance_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceModel {
  final String id;
  final String massId; // ID Misa yang dihadiri
  final String userId; // ID Pengguna yang hadir
  final Timestamp timestamp; // Waktu pencatatan kehadiran
  final double latitude; // Latitude saat pencatatan
  final double longitude; // Longitude saat pencatatan
  final String type; // 'check-in' atau 'check-out'
  final String? scannedQrData; // Data mentah dari QR code yang discan

  AttendanceModel({
    required this.id,
    required this.massId,
    required this.userId,
    required this.timestamp,
    required this.latitude,
    required this.longitude,
    required this.type,
    this.scannedQrData,
  });

  factory AttendanceModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return AttendanceModel(
      id: doc.id,
      massId: data['massId'] as String? ?? '',
      userId: data['userId'] as String? ?? '',
      timestamp: data['timestamp'] as Timestamp? ?? Timestamp.now(),
      latitude: (data['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (data['longitude'] as num?)?.toDouble() ?? 0.0,
      type: data['type'] as String? ?? 'unknown',
      scannedQrData: data['scannedQrData'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'massId': massId,
      'userId': userId,
      'timestamp': timestamp,
      'latitude': latitude,
      'longitude': longitude,
      'type': type,
      'scannedQrData': scannedQrData,
    };
  }
}
