// lib/screens/admin_panel/add_notification_page.dart

import 'package:flutter/material.dart';
import 'package:altarlink4/models/notification_model.dart';
import 'package:altarlink4/services/notification_service.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddNotificationPage extends StatefulWidget {
  final NotificationModel? notification;

  const AddNotificationPage({super.key, this.notification});

  @override
  State<AddNotificationPage> createState() => _AddNotificationPageState();
}

class _AddNotificationPageState extends State<AddNotificationPage> {
  final _formKey = GlobalKey<FormState>();
  final NotificationService _notificationService = NotificationService();

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _targetLinkController;
  late String _selectedNotificationType;

  static const Color primaryTextColor = Color(0xFFFFFFFF);
  static const Color orangeAccent = Color(0xFFFFA852);
  static const Color backgroundWhite = Color(0xFFF5F5F5);
  static const Color darkGreyText = Color(0xFF535353);
  static const Color borderColor = Color(0xFFBDBDBD);

  final List<String> _notificationTypes = [
    'Announcement',
    'Warning',
    'Event',
    'Update',
    'Message',
    'Notice',
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _targetLinkController = TextEditingController();

    if (widget.notification != null) {
      _titleController.text = widget.notification!.title;
      _descriptionController.text = widget.notification!.description;
      _targetLinkController.text = widget.notification!.targetLink ?? '';
      _selectedNotificationType = widget.notification!.type;
    } else {
      _selectedNotificationType =
          _notificationTypes.first; // Default value for new notification
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _targetLinkController.dispose();
    super.dispose();
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

  Future<void> _saveNotification() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      try {
        NotificationModel notificationData = NotificationModel(
          id: widget.notification?.id ?? '', // Gunakan ID lama jika mengedit
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          type: _selectedNotificationType,
          targetLink: _targetLinkController.text.trim().isEmpty
              ? null
              : _targetLinkController.text.trim(),
          createdAt: widget.notification?.createdAt ?? Timestamp.now(),
          readBy: widget.notification?.readBy ?? [], // <--- PERUBAHAN DI SINI
        );

        if (widget.notification == null) {
          // Tambah Notifikasi Baru
          await _notificationService.addNotification(
            title: notificationData.title,
            description: notificationData.description,
            type: notificationData.type,
            targetLink: notificationData.targetLink,
          );
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Notifikasi berhasil ditambahkan!')),
            );
          }
        } else {
          // Update Notifikasi
          await _notificationService.updateNotification(notificationData);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Notifikasi berhasil diperbarui!')),
            );
          }
        }
        if (mounted) {
          Navigator.pop(context,
              true); // Kembali ke halaman sebelumnya dan beritahu bahwa ada perubahan
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Gagal menyimpan notifikasi: ${e.toString()}')),
          );
        }
        print('Error saving notification: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundWhite,
      appBar: AppBar(
        backgroundColor: orangeAccent,
        title: Text(
          widget.notification == null
              ? 'Tambah Notifikasi Baru'
              : 'Edit Notifikasi',
          style: const TextStyle(
            fontFamily: 'Work Sans',
            fontWeight: FontWeight.bold,
            color: primaryTextColor,
          ),
        ),
        iconTheme: const IconThemeData(
          color: primaryTextColor,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bagian Tipe Notifikasi
              Text(
                'Tipe Notifikasi',
                style: TextStyle(
                    fontFamily: 'Work Sans',
                    fontWeight: FontWeight.bold,
                    color: darkGreyText,
                    fontSize: 16),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedNotificationType,
                decoration: InputDecoration(
                  hintText: 'Pilih tipe notifikasi',
                  filled: true,
                  fillColor: primaryTextColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: borderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: orangeAccent, width: 2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: borderColor),
                  ),
                ),
                dropdownColor: primaryTextColor,
                items: _notificationTypes.map((String type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Row(
                      children: [
                        Icon(
                          _getIconForNotificationType(type),
                          color: darkGreyText,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          type,
                          style: const TextStyle(
                              fontFamily: 'Work Sans', color: darkGreyText),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedNotificationType = newValue!;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Pilih tipe notifikasi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Bagian Judul Notifikasi
              Text(
                'Judul Notifikasi',
                style: TextStyle(
                    fontFamily: 'Work Sans',
                    fontWeight: FontWeight.bold,
                    color: darkGreyText,
                    fontSize: 16),
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    _getIconForNotificationType(_selectedNotificationType),
                    color: orangeAccent,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        hintText: 'Masukkan judul notifikasi',
                        filled: true,
                        fillColor: primaryTextColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: borderColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: orangeAccent, width: 2),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: borderColor),
                        ),
                      ),
                      style: const TextStyle(
                          fontFamily: 'Work Sans', color: darkGreyText),
                      cursorColor: orangeAccent,
                      maxLength: 50,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Judul tidak boleh kosong';
                        }
                        if (value.length > 50) {
                          return 'Judul tidak boleh lebih dari 50 karakter';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Bagian Deskripsi Notifikasi
              Text(
                'Deskripsi Notifikasi',
                style: TextStyle(
                    fontFamily: 'Work Sans',
                    fontWeight: FontWeight.bold,
                    color: darkGreyText,
                    fontSize: 16),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'Masukkan deskripsi notifikasi',
                  filled: true,
                  fillColor: primaryTextColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: borderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: orangeAccent, width: 2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: borderColor),
                  ),
                ),
                style: const TextStyle(
                    fontFamily: 'Work Sans', color: darkGreyText),
                cursorColor: orangeAccent,
                maxLength: 200,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Deskripsi tidak boleh kosong';
                  }
                  if (value.length > 200) {
                    return 'Deskripsi tidak boleh lebih dari 200 karakter';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Bagian Link Target (Opsional)
              Text(
                'Link Target (Opsional)',
                style: TextStyle(
                    fontFamily: 'Work Sans',
                    fontWeight: FontWeight.bold,
                    color: darkGreyText,
                    fontSize: 16),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _targetLinkController,
                decoration: InputDecoration(
                  hintText: 'Masukkan URL (mis: https://example.com)',
                  filled: true,
                  fillColor: primaryTextColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: borderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: orangeAccent, width: 2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: borderColor),
                  ),
                ),
                style: const TextStyle(
                    fontFamily: 'Work Sans', color: darkGreyText),
                cursorColor: orangeAccent,
                keyboardType: TextInputType.url,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final uri = Uri.tryParse(value);
                    if (uri == null || !uri.hasAbsolutePath) {
                      return 'Masukkan URL yang valid';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Tombol Simpan
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveNotification,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: orangeAccent,
                    foregroundColor: primaryTextColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    widget.notification == null
                        ? 'Tambah Notifikasi'
                        : 'Simpan Perubahan',
                    style: const TextStyle(
                        fontFamily: 'Work Sans',
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
