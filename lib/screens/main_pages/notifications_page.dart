// lib/screens/main_pages/notifications_page.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart'; // Untuk mengakses AuthService
import 'package:altarlink4/services/notification_service.dart';
import 'package:altarlink4/models/notification_model.dart'
    as app_notif; // Alias untuk menghindari konflik nama
import 'package:altarlink4/services/auth/auth_service.dart'; // FIX: Pastikan ini mengarah ke auth/auth_service.dart
import 'package:altarlink4/services/mass_service.dart';
import 'package:altarlink4/models/mass_model.dart';
import 'package:altarlink4/screens/main_pages/mass_information_page.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final NotificationService _notificationService = NotificationService();
  final MassService _massService = MassService();

  // Helper untuk format tanggal dan waktu Misa
  String _formatMassDateTime(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return DateFormat('EEEE, dd MMMMWriteHeader, HH:mm', 'id')
        .format(dateTime); // 'id' untuk bahasa Indonesia
  }

  // Helper untuk mendapatkan ikon berdasarkan tipe notifikasi
  IconData _getIconForNotificationType(String type) {
    switch (type.toLowerCase()) {
      case 'announcement':
        return Icons.campaign_outlined;
      case 'warning':
        return Icons.warning_amber_outlined;
      case 'event':
        return Icons.event_note_outlined;
      case 'update':
        return Icons.update_outlined;
      case 'message':
        return Icons.message_outlined;
      case 'notice':
        return Icons.mail_outlined;
      default:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Akses AuthService melalui Provider
    final authService = Provider.of<AuthService>(context);
    final currentUserId = authService.currentUser
        ?.uid; // <<-- FIX: Menggunakan getter currentUser dari AuthService
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notifikasi',
          style: TextStyle(
            color: Color(0xFF25242E),
            fontWeight: FontWeight.bold,
            fontFamily: 'Work Sans',
          ),
        ),
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bagian Misa Mendatang (Next Mass) - Kode ini tidak berubah dari sebelumnya
            StreamBuilder<MassModel?>(
              stream: _massService.getNextMass(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container(
                    margin: const EdgeInsets.all(16.0),
                    padding: const EdgeInsets.all(20.0),
                    height: 150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFEFA3), Color(0xFFFFA852)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          spreadRadius: 2,
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Center(
                        child: CircularProgressIndicator(color: Colors.white)),
                  );
                } else if (snapshot.hasError) {
                  print(
                      'Error fetching next mass for notification page: ${snapshot.error}');
                  return Container(
                    margin: const EdgeInsets.all(16.0),
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.red.shade100,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          spreadRadius: 2,
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Center(
                        child: Text(
                            'Error memuat Misa mendatang: ${snapshot.error}',
                            style: TextStyle(color: Colors.red.shade700))),
                  );
                } else if (!snapshot.hasData || snapshot.data == null) {
                  return Container(
                    margin: const EdgeInsets.all(16.0),
                    padding: const EdgeInsets.all(20.0),
                    height: 150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFEFA3), Color(0xFFFFA852)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          spreadRadius: 2,
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        'Tidak ada Misa mendatang',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Work Sans',
                          fontWeight: FontWeight.w500,
                          fontSize: screenWidth * 0.045,
                          color: const Color(0xFF535353),
                        ),
                      ),
                    ),
                  );
                } else {
                  MassModel nextMass = snapshot.data!;
                  return Container(
                    margin: const EdgeInsets.all(16.0),
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFEFA3), Color(0xFFFFA852)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          spreadRadius: 2,
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Misa Mendatang',
                          style: TextStyle(
                            fontFamily: 'Work Sans',
                            fontWeight: FontWeight.bold,
                            fontSize: screenWidth * 0.045,
                            color: const Color(0xFF25242E),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          nextMass.title,
                          style: TextStyle(
                            fontFamily: 'Work Sans',
                            fontWeight: FontWeight.w600,
                            fontSize: screenWidth * 0.055,
                            color: const Color(0xFF535353),
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatMassDateTime(nextMass.massDateTime),
                          style: TextStyle(
                            fontFamily: 'Work Sans',
                            fontWeight: FontWeight.w400,
                            fontSize: screenWidth * 0.04,
                            color: const Color(0xFF535353),
                          ),
                        ),
                        const SizedBox(height: 15),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const MassInformationPage()),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE39D4A),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 5),
                              elevation: 0,
                            ),
                            child: Text(
                              'Lihat Detail Misa',
                              style: TextStyle(
                                fontFamily: 'Work Sans',
                                fontWeight: FontWeight.w500,
                                fontSize: screenWidth * 0.038,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }
              },
            ),

            const Padding(
              padding: EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 10.0),
              child: Text(
                'Notifikasi Terbaru:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Work Sans',
                  color: Color(0xFF25242E),
                ),
              ),
            ),

            // Bagian Daftar Notifikasi
            StreamBuilder<List<app_notif.NotificationModel>>(
              stream: _notificationService.getNotifications(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  print('Error fetching notifications: ${snapshot.error}');
                  return Center(
                      child:
                          Text('Error memuat notifikasi: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                      child: Text('Tidak ada notifikasi saat ini.'));
                } else {
                  List<app_notif.NotificationModel> notifications =
                      snapshot.data!;
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      app_notif.NotificationModel notification =
                          notifications[index];
                      // <<-- FIX: Gunakan readBy dari NotificationModel
                      bool isRead = currentUserId != null &&
                          notification.readBy.contains(currentUserId);

                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12.0),
                          leading: Icon(
                            _getIconForNotificationType(notification
                                .type), // <<-- FIX: Gunakan fungsi helper
                            color: isRead ? Colors.grey : Colors.blue.shade700,
                            size: 30,
                          ),
                          title: Text(
                            notification.title,
                            style: TextStyle(
                              fontWeight:
                                  isRead ? FontWeight.normal : FontWeight.bold,
                              color: isRead
                                  ? Colors.grey
                                  : const Color(0xFF25242E),
                              fontFamily: 'Work Sans',
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                notification
                                    .description, // <<-- FIX: Gunakan description
                                style: TextStyle(
                                  color: isRead
                                      ? Colors.grey.shade600
                                      : const Color(0xFF535353),
                                  fontFamily: 'Work Sans',
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Diterbitkan: ${DateFormat('dd MMMMWriteHeader HH:mm').format(notification.createdAt.toDate())}', // <<-- FIX: Gunakan createdAt
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                  fontFamily: 'Work Sans',
                                ),
                              ),
                            ],
                          ),
                          onTap: () async {
                            if (currentUserId != null) {
                              // <<-- FIX: Panggil markNotificationAsRead
                              await _notificationService.markNotificationAsRead(
                                  notification.id, currentUserId);
                            }
                            // Tampilkan detail notifikasi dalam dialog
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  title: Text(
                                    notification.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Work Sans',
                                    ),
                                  ),
                                  content: SingleChildScrollView(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          notification
                                              .description, // <<-- FIX: Gunakan description
                                          style: const TextStyle(
                                              fontFamily: 'Work Sans'),
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          'Diterbitkan: ${DateFormat('dd MMMMWriteHeader HH:mm').format(notification.createdAt.toDate())}', // <<-- FIX: Gunakan createdAt
                                          style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                              fontFamily: 'Work Sans'),
                                        ),
                                      ],
                                    ),
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                      child: const Text('Tutup',
                                          style: TextStyle(
                                              fontFamily: 'Work Sans')),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      );
                    },
                  );
                }
              },
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}
