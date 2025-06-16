// lib/widgets/next_mass_card.dart (file baru)
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:altarlink4/models/mass_model.dart';
import 'package:altarlink4/services/mass_service.dart';
import 'package:altarlink4/screens/main_pages/mass_information_page.dart'; // Untuk navigasi

class NextMassCard extends StatelessWidget {
  final MassService massService;
  final Function(Timestamp) formatMassDateTime;
  final double screenWidth;

  const NextMassCard({
    super.key,
    required this.massService,
    required this.formatMassDateTime,
    required this.screenWidth,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<MassModel?>(
      stream: massService.getNextMass(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingOrErrorContainer(screenWidth, isError: false);
        } else if (snapshot.hasError) {
          print('Error fetching next mass: ${snapshot.error}');
          return _buildLoadingOrErrorContainer(screenWidth,
              isError: true, error: snapshot.error.toString());
        } else if (!snapshot.hasData || snapshot.data == null) {
          return _buildNoMassContainer(screenWidth);
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
                  // Format khusus untuk MassInformationPage
                  ModalRoute.of(context)?.settings.name == '/mass_information'
                      ? formatMassDateTime(nextMass.massDateTime)
                      : 'Misa Mendatang',
                  style: TextStyle(
                    fontFamily: 'Work Sans',
                    fontWeight: ModalRoute.of(context)?.settings.name ==
                            '/mass_information'
                        ? FontWeight.w500 // Untuk MassInformationPage
                        : FontWeight.bold, // Untuk NotificationsPage
                    fontSize: screenWidth * 0.045,
                    color: const Color(0xFF535353),
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
                // Hanya tampilkan waktu di NotificationsPage jika tidak sudah ada di judul
                if (ModalRoute.of(context)?.settings.name !=
                    '/mass_information')
                  Text(
                    formatMassDateTime(nextMass.massDateTime),
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
                      // Navigasi ke MassInformationPage hanya jika sedang di NotificationsPage
                      if (ModalRoute.of(context)?.settings.name !=
                          '/mass_information') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MassInformationPage(),
                            settings: const RouteSettings(
                                name:
                                    '/mass_information'), // Tambahkan nama rute
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Aksi untuk Detail Misa')),
                        );
                      }
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
                      // Ubah teks tombol berdasarkan halaman
                      ModalRoute.of(context)?.settings.name ==
                              '/mass_information'
                          ? 'Detail Misa' // Untuk MassInformationPage
                          : 'Lihat Detail Misa', // Untuk NotificationsPage
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
    );
  }

  Widget _buildLoadingOrErrorContainer(double screenWidth,
      {required bool isError, String? error}) {
    return Container(
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.all(20.0),
      height: 200, // Atau sesuaikan tinggi
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: isError ? Colors.red.shade100 : null,
        gradient: isError
            ? null
            : const LinearGradient(
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
        child: isError
            ? Text('Error: ${error ?? "Terjadi kesalahan"}',
                style: TextStyle(color: Colors.red.shade700))
            : const CircularProgressIndicator(color: Colors.white),
      ),
    );
  }

  Widget _buildNoMassContainer(double screenWidth) {
    return Container(
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.all(20.0),
      height: 200, // Atau sesuaikan tinggi
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
          'Tidak ada Misa mendatang.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Work Sans',
            fontWeight: FontWeight.w500,
            fontSize: screenWidth * 0.05,
            color: const Color(0xFF535353),
          ),
        ),
      ),
    );
  }
}
