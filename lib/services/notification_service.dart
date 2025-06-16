// altarlink4/lib/services/notification_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:altarlink4/models/notification_model.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Mengambil stream semua notifikasi dari Firestore
  Stream<List<NotificationModel>> getNotifications() {
    return _firestore
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NotificationModel.fromFirestore(doc))
            .toList());
  }

  // Menambah notifikasi baru
  Future<void> addNotification({
    required String title,
    required String description,
    String type = 'info', // Default 'info' sesuai definisi Anda
    String? imageUrl,
    String? targetLink,
  }) async {
    NotificationModel newNotification = NotificationModel(
      id: '', // ID akan digenerate Firestore
      title: title,
      description: description,
      createdAt: Timestamp.now(),
      type: type,
      imageUrl: imageUrl,
      targetLink: targetLink,
      readBy: [], // Ketika dibuat, belum ada yang membaca
    );

    await _firestore
        .collection('notifications')
        .add(newNotification.toFirestore());
  }

  // Mengupdate notifikasi yang sudah ada
  // MODIFIKASI: Sekarang menerima NotificationModel langsung
  Future<void> updateNotification(NotificationModel notification) async {
    if (notification.id.isEmpty) {
      // Ini seharusnya tidak terjadi jika kita mengedit notifikasi yang sudah ada
      // Tapi penting untuk ada penanganan error atau validasi
      throw Exception("Notification ID cannot be empty for update operation.");
    }
    await _firestore
        .collection('notifications')
        .doc(notification.id) // Gunakan ID dari objek NotificationModel
        .update(
            notification.toFirestore()); // Konversi objek ke Map untuk update
  }

  // Menghapus notifikasi
  Future<void> deleteNotification(String notificationId) async {
    await _firestore.collection('notifications').doc(notificationId).delete();
  }

  // Menandai notifikasi sebagai sudah dibaca oleh user tertentu
  Future<void> markNotificationAsRead(
      String notificationId, String userId) async {
    DocumentReference notificationRef =
        _firestore.collection('notifications').doc(notificationId);

    _firestore.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(notificationRef);

      if (!snapshot.exists) {
        throw Exception("Notification does not exist!");
      }

      // Ambil list 'readBy' yang sudah ada
      List<String> readBy = List<String>.from(snapshot.get('readBy') ?? []);

      // Jika user belum ada di list, tambahkan
      if (!readBy.contains(userId)) {
        readBy.add(userId);
        transaction.update(notificationRef, {'readBy': readBy});
      }
    });
  }
}
