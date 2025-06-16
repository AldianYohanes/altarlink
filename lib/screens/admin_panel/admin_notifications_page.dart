// lib/screens/admin_panel/admin_notifications_page.dart

import 'package:flutter/material.dart';
import 'package:altarlink4/services/notification_service.dart';
import 'package:altarlink4/models/notification_model.dart';
import 'package:altarlink4/screens/admin_panel/add_notification_page.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:url_launcher/url_launcher.dart'; // <--- Import BARU

class AdminNotificationsPage extends StatefulWidget {
  const AdminNotificationsPage({super.key});

  @override
  State<AdminNotificationsPage> createState() => _AdminNotificationsPageState();
}

class _AdminNotificationsPageState extends State<AdminNotificationsPage> {
  final NotificationService _notificationService = NotificationService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Definisikan warna yang konsisten
  static const Color primaryTextColor =
      Color(0xFFFFFFFF); // Background Card (bukan AppBar)
  static const Color orangeAccent = Color(0xFFFFA852);
  static const Color backgroundWhite =
      Color(0xFFF5F5F5); // Latar belakang utama Scaffold/Container
  static const Color darkGreyText = Color(0xFF535353);
  static const Color redAccent = Color(0xFFFF5252);
  static const Color borderColor = Color(0xFFBDBDBD);

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
    });
  }

  // Helper untuk mendapatkan ikon berdasarkan tipe notifikasi
  IconData _getIconForNotificationType(String type) {
    switch (type.toLowerCase()) {
      case 'announcement':
        return BootstrapIcons.megaphone;
      case 'warning':
        return BootstrapIcons.exclamation_triangle;
      case 'event':
        return BootstrapIcons.calendar_event;
      case 'update':
        return BootstrapIcons.arrow_clockwise;
      case 'message':
        return BootstrapIcons.chat_dots;
      case 'notice':
        return BootstrapIcons.info_circle;
      default:
        return BootstrapIcons.info_circle;
    }
  }

  // Fungsi untuk konfirmasi dan menghapus notifikasi
  Future<void> _confirmDelete(String notificationId, String title) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: primaryTextColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          title: Text(
            'Hapus Notifikasi?',
            style: TextStyle(
                fontFamily: 'Work Sans',
                fontWeight: FontWeight.bold,
                color: darkGreyText),
          ),
          content: Text(
            'Anda yakin ingin menghapus notifikasi "$title"?',
            style: TextStyle(fontFamily: 'Work Sans', color: darkGreyText),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: Text(
                'Batal',
                style: TextStyle(fontFamily: 'Work Sans', color: darkGreyText),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                try {
                  await _notificationService.deleteNotification(notificationId);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Notifikasi berhasil dihapus!')),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(
                              'Gagal menghapus notifikasi: ${e.toString()}')),
                    );
                  }
                  print('Error deleting notification: $e');
                }
              },
              child: Text('Hapus',
                  style: TextStyle(fontFamily: 'Work Sans', color: redAccent)),
            ),
          ],
        );
      },
    );
  }

  // Fungsi untuk membuka URL
  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tidak bisa membuka link: $urlString')),
        );
      }
      print('Could not launch $urlString');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundWhite,
      child: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Cari notifikasi...',
                    hintStyle: TextStyle(
                        fontFamily: 'Work Sans',
                        color: darkGreyText.withOpacity(0.6)),
                    prefixIcon:
                        Icon(BootstrapIcons.search, color: darkGreyText),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: Icon(BootstrapIcons.x_circle,
                                color: darkGreyText),
                            onPressed: () {
                              _searchController.clear();
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(100),
                      borderSide: BorderSide(color: borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(100),
                      borderSide: BorderSide(color: orangeAccent, width: 2),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(100),
                      borderSide: BorderSide(color: borderColor),
                    ),
                    filled: true,
                    fillColor: primaryTextColor,
                  ),
                  style: const TextStyle(
                      fontFamily: 'Work Sans', color: darkGreyText),
                  cursorColor: orangeAccent,
                ),
              ),
              Expanded(
                child: StreamBuilder<List<NotificationModel>>(
                  stream: _notificationService.getNotifications(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                          child:
                              CircularProgressIndicator(color: orangeAccent));
                    } else if (snapshot.hasError) {
                      print(
                          'Error fetching notifications for admin: ${snapshot.error}');
                      return Center(
                        child: Text(
                          'Error memuat notifikasi: ${snapshot.error}',
                          style: TextStyle(
                              fontFamily: 'Work Sans', color: darkGreyText),
                        ),
                      );
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(BootstrapIcons.bell_slash,
                                size: 80, color: darkGreyText),
                            SizedBox(height: 16),
                            Text(
                              'Belum ada notifikasi untuk dikelola.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontFamily: 'Work Sans',
                                  fontSize: 16,
                                  color: darkGreyText),
                            ),
                          ],
                        ),
                      );
                    } else {
                      List<NotificationModel> notifications = snapshot.data!;
                      final filteredNotifications =
                          notifications.where((notification) {
                        final titleLower = notification.title.toLowerCase();
                        final descriptionLower =
                            notification.description.toLowerCase();
                        final typeLower = notification.type.toLowerCase();
                        final queryLower = _searchQuery.toLowerCase();

                        return titleLower.contains(queryLower) ||
                            descriptionLower.contains(queryLower) ||
                            typeLower.contains(queryLower);
                      }).toList();

                      if (filteredNotifications.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(BootstrapIcons.search_heart_fill,
                                  size: 80, color: darkGreyText),
                              SizedBox(height: 16),
                              Text(
                                'Tidak ada notifikasi yang cocok dengan pencarian Anda.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontFamily: 'Work Sans',
                                    fontSize: 16,
                                    color: darkGreyText),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        itemCount: filteredNotifications.length,
                        itemBuilder: (context, index) {
                          NotificationModel notification =
                              filteredNotifications[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            elevation: 0,
                            color: primaryTextColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ListTile(
                              // Jika ada targetLink, ListTile bisa diklik untuk membuka link
                              onTap: notification.targetLink != null &&
                                      notification.targetLink!.isNotEmpty
                                  ? () => _launchUrl(notification.targetLink!)
                                  : null,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 12.0),
                              leading: Icon(
                                _getIconForNotificationType(notification.type),
                                color: orangeAccent,
                              ),
                              title: Text(
                                notification.title,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Work Sans',
                                    color: darkGreyText),
                              ),
                              subtitle: Column(
                                // Menggunakan Column untuk subtitle
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    notification.description,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontFamily: 'Work Sans',
                                        color: darkGreyText),
                                  ),
                                  if (notification.targetLink != null &&
                                      notification.targetLink!.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4.0),
                                      child: Row(
                                        children: [
                                          Icon(BootstrapIcons.link_45deg,
                                              size: 16, color: orangeAccent),
                                          SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              notification.targetLink!,
                                              style: TextStyle(
                                                fontFamily: 'Work Sans',
                                                color: Colors.blue.shade700,
                                                decoration:
                                                    TextDecoration.underline,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                              isThreeLine: notification.targetLink != null &&
                                  notification.targetLink!
                                      .isNotEmpty, // Jadikan three-line jika ada link
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                        BootstrapIcons.pencil_square,
                                        color: darkGreyText),
                                    onPressed: () async {
                                      final result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              AddNotificationPage(
                                                  notification: notification),
                                        ),
                                      );
                                      if (result == true) {
                                        setState(() {});
                                      }
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(BootstrapIcons.trash,
                                        color: redAccent),
                                    onPressed: () => _confirmDelete(
                                        notification.id, notification.title),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    }
                  },
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 16.0,
            right: 16.0,
            child: FloatingActionButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AddNotificationPage()),
                );
                if (result == true) {
                  setState(() {});
                }
              },
              backgroundColor: orangeAccent,
              foregroundColor: Colors.white,
              child: const Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }
}
