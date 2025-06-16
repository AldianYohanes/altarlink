// lib/screens/main_pages/qr_scan_page.dart

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:altarlink4/models/mass_model.dart';
import 'package:altarlink4/services/mass_service.dart';
import 'package:altarlink4/services/attendance_service.dart';
import 'package:altarlink4/services/auth/auth_service.dart';

class QrScanPage extends StatefulWidget {
  const QrScanPage({super.key});

  @override
  State<QrScanPage> createState() => _QrScanPageState();
}

class _QrScanPageState extends State<QrScanPage> {
  MobileScannerController cameraController = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
    torchEnabled: false,
  );

  String _currentStatusMessage = 'Pindai kode QR untuk konfirmasi kehadiran...';
  bool _isProcessing = false;
  bool _cameraPermissionGranted = false;
  bool _isTorchOn = false;
  bool _isScanning = true; // <--- PASTIKAN BARIS INI ADA!

  @override
  void initState() {
    super.initState();
    _checkCameraPermission();
  }

  // Hanya cek izin kamera
  Future<void> _checkCameraPermission() async {
    final cameraStatus = await Permission.camera.status;
    if (cameraStatus.isGranted) {
      _cameraPermissionGranted = true;
    } else {
      final result = await Permission.camera.request();
      if (result.isGranted) {
        _cameraPermissionGranted = true;
      } else {
        _cameraPermissionGranted = false;
        _showPermissionDeniedDialog('kamera',
            permanentlyDenied: result.isPermanentlyDenied);
      }
    }

    // Mulai scanning jika izin kamera diberikan
    if (_cameraPermissionGranted) {
      _startScanning();
    } else {
      setState(() {
        _currentStatusMessage = 'Perlu izin kamera untuk melanjutkan.';
      });
    }

    if (mounted) {
      setState(() {}); // Perbarui UI setelah cek izin
    }
  }

  void _showPermissionDeniedDialog(String permissionType,
      {bool permanentlyDenied = false}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Izin $permissionType Diperlukan'),
        content: Text(permanentlyDenied
            ? 'Izin $permissionType ditolak secara permanen. Mohon berikan izin dari pengaturan aplikasi secara manual.'
            : 'Akses $permissionType diperlukan untuk memindai QR Code. Mohon berikan izin.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (permanentlyDenied) {
                openAppSettings(); // Membuka pengaturan aplikasi
              }
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _startScanning() {
    if (!_isScanning && _cameraPermissionGranted) {
      cameraController.start();
      setState(() {
        _isScanning = true;
        _currentStatusMessage = 'Pindai kode QR untuk konfirmasi kehadiran...';
      });
    }
  }

  void _stopScanning() {
    if (_isScanning) {
      cameraController.stop();
      setState(() {
        _isScanning = false;
      });
    }
  }

  void _toggleTorch() async {
    if (!_isProcessing) {
      await cameraController.toggleTorch();
      setState(() {
        _isTorchOn = !_isTorchOn;
      });
    }
  }

  Future<void> _onQrDetected(BarcodeCapture capture) async {
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty || _isProcessing) return;

    final barcode = barcodes.first;
    _stopScanning(); // Hentikan scan sementara

    setState(() {
      _isProcessing = true;
      _currentStatusMessage = 'Memproses QR code...';
    });

    try {
      final qrData = barcode.rawValue;
      if (qrData == null || !qrData.startsWith('altarlink_checkout:')) {
        _showSnackBar('QR code tidak valid atau bukan untuk kehadiran.');
        return;
      }

      // Contoh format QR: "altarlink_checkout:{massId}"
      final massId = qrData.split(':').last;

      // Ambil user ID saat ini
      final authService = Provider.of<AuthService>(context, listen: false);
      final userId = authService.currentUser?.uid;
      if (userId == null) {
        _showSnackBar('Anda harus login untuk mencatat kehadiran.');
        return;
      }

      final massService = Provider.of<MassService>(context, listen: false);
      final attendanceService =
          Provider.of<AttendanceService>(context, listen: false);

      // 1. Dapatkan detail misa dari Firestore
      MassModel? mass;
      try {
        final massSnapshot = await massService.getMassById(massId).first;
        mass = massSnapshot;
      } catch (e) {
        print('Error fetching mass: $e');
        _showSnackBar('Gagal mendapatkan detail misa. QR mungkin tidak valid.');
        return;
      }

      if (mass == null) {
        _showSnackBar('Misa tidak ditemukan untuk QR ini.');
        return;
      }

      // 2. Verifikasi apakah pengguna ini adalah misdinar di misa ini
      if (mass.misdinarUids == null || !mass.misdinarUids!.contains(userId)) {
        _showSnackBar('Anda tidak terdaftar sebagai misdinar di misa ini.');
        return;
      }

      // Karena tidak ada GPS, kita langsung catat kehadiran
      await attendanceService.recordAttendance(
        massId: massId,
        userId: userId,
        latitude: 0.0, // Default 0.0 karena tidak pakai GPS
        longitude: 0.0, // Default 0.0 karena tidak pakai GPS
        type: 'check-out', // Untuk konfirmasi selesai tugas
        scannedQrData: qrData,
      );
      _showSnackBar('Kehadiran berhasil dikonfirmasi!', success: true);
      setState(() {
        _currentStatusMessage = 'Kehadiran berhasil dikonfirmasi!';
      });
      // Opsional: Kembali ke halaman sebelumnya atau tampilkan sukses page
      // Navigator.pop(context);
    } catch (e) {
      print('Error processing QR code: $e');
      _showSnackBar('Terjadi kesalahan: ${e.toString()}');
      setState(() {
        _currentStatusMessage = 'Terjadi kesalahan saat memproses QR.';
      });
    } finally {
      setState(() {
        _isProcessing = false;
      });
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted && !_isProcessing) {
          _startScanning();
        }
      });
    }
  }

  void _showSnackBar(String message, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontFamily: 'Work Sans')),
        backgroundColor: success ? Colors.green : Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).colorScheme.primary;
    final Color primaryTextColor = Colors.white;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              'Scan QR Kehadiran',
              style:
                  TextStyle(color: primaryTextColor, fontFamily: 'Work Sans'),
            ),
          ],
        ),
        backgroundColor: primaryColor,
        foregroundColor: primaryTextColor,
        elevation: 1,
      ),
      body: _cameraPermissionGranted
          ? Stack(
              children: [
                MobileScanner(
                  controller: cameraController,
                  onDetect: _onQrDetected,
                ),
                Center(
                  child: Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      border: Border.all(color: primaryTextColor, width: 3),
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
                Positioned(
                  top: 20,
                  right: 20,
                  child: FloatingActionButton(
                    mini: true,
                    backgroundColor: primaryTextColor.withOpacity(0.8),
                    onPressed: _isProcessing
                        ? null
                        : () => cameraController.switchCamera(),
                    child: Icon(Icons.flip_camera_ios, color: primaryColor),
                  ),
                ),
                Positioned(
                  top: 80,
                  right: 20,
                  child: FloatingActionButton(
                    mini: true,
                    backgroundColor: primaryTextColor.withOpacity(0.8),
                    onPressed: _isProcessing ? null : _toggleTorch,
                    child: Icon(
                      _isTorchOn ? Icons.flash_on : Icons.flash_off,
                      color: _isTorchOn ? Colors.amber : Colors.grey,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    color: Colors.black.withOpacity(0.7),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _currentStatusMessage,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: primaryTextColor,
                            fontSize: 18,
                            fontFamily: 'Work Sans',
                          ),
                        ),
                        const SizedBox(height: 10),
                        if (_isProcessing)
                          CircularProgressIndicator(color: primaryTextColor),
                      ],
                    ),
                  ),
                ),
              ],
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.camera_alt_outlined,
                      size: 100, color: Colors.grey),
                  const SizedBox(height: 20),
                  const Text(
                    'Aplikasi memerlukan izin kamera untuk memindai QR Code.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                        fontFamily: 'Work Sans'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed:
                        _checkCameraPermission, // Panggil ulang untuk minta izin kamera
                    child: const Text('Berikan Izin Kamera',
                        style: TextStyle(fontFamily: 'Work Sans')),
                  ),
                ],
              ),
            ),
    );
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }
}
