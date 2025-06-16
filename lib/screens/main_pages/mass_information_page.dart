// lib/screens/main_pages/mass_information_page.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart'; // Import untuk mengakses AuthService
import 'package:bootstrap_icons/bootstrap_icons.dart'; // Import untuk ikon Bootstrap

import 'package:altarlink4/models/mass_model.dart';
import 'package:altarlink4/models/user_model.dart'; // Import user_model
import 'package:altarlink4/services/mass_service.dart';
import 'package:altarlink4/services/auth/auth_service.dart'; // Import auth_service

class MassInformationPage extends StatefulWidget {
  const MassInformationPage({super.key});

  @override
  State<MassInformationPage> createState() => _MassInformationPageState();
}

class _MassInformationPageState extends State<MassInformationPage> {
  final MassService _massService = MassService();
  // Map untuk menyimpan data user agar tidak request berulang kali ke Firestore
  Map<String, UserModel> _allUsers = {};

  // Definisikan warna yang konsisten
  static const Color primaryTextColor = Color(0xFFFFFFFF); // White
  static const Color orangeAccent = Color(0xFFFFA852); // Accent color
  static const Color backgroundWhite = Color(0xFFF5F5F5); // Main background
  static const Color darkGreyText = Color(0xFF535353); // General text color
  static const Color redAccent = Color(0xFFFF5252); // Error color
  // static const Color borderColor = Color(0xFFBDBDBD); // Tidak langsung digunakan di sini, tapi konsisten

  @override
  void initState() {
    super.initState();
    // Ambil daftar semua pengguna saat initState untuk mapping UID ke nama.
    // Stream ini akan tetap aktif dan memperbarui _allUsers jika ada perubahan data user.
    _fetchUsers();
  }

  // Metode untuk mengambil semua user dari AuthService
  void _fetchUsers() {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      // Menggunakan stream untuk mendapatkan update real-time dari daftar pengguna
      authService.getUsersStream().listen((users) {
        if (mounted) {
          setState(() {
            _allUsers = {for (var user in users) user.uid: user};
          });
        }
      }, onError: (error) {
        print("Error fetching all users for Mass Information Page: $error");
        // Anda bisa menampilkan SnackBar atau pesan error lain di UI jika diperlukan
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Gagal memuat daftar pengguna: $error',
                  style: const TextStyle(fontFamily: 'Work Sans'))),
        );
      });
    } catch (e) {
      print(
          "Error setting up AuthService listener in Mass Information Page: $e");
      // Ini mungkin terjadi jika AuthService belum disediakan di widget tree
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Pastikan AuthService telah disediakan di aplikasi Anda: $e',
                style: const TextStyle(fontFamily: 'Work Sans'))),
      );
    }
  }

  // Helper untuk mendapatkan nama misdinar dari UID
  // Digunakan oleh _buildMisdinarDetailRow dan MassListTile
  String _getMisdinarName(String uid) {
    // Mencari UserModel berdasarkan UID di _allUsers
    final user = _allUsers[uid];
    // Mengembalikan displayName jika ditemukan, jika tidak, email atau default 'Pengguna Tidak Dikenal'
    return user?.displayName ?? user?.email ?? 'Pengguna Tidak Dikenal';
  }

  // Helper untuk format tanggal dan waktu Misa
  String _formatMassDateTime(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    // Locale 'id' untuk format hari dan bulan dalam bahasa Indonesia
    return DateFormat('EEEE, dd MMMM, HH:mm', 'id').format(dateTime);
  }

  // Helper untuk membuka URL
  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri,
          mode: LaunchMode.externalApplication); // Buka di aplikasi eksternal
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Tidak dapat membuka link: $url',
                style: const TextStyle(fontFamily: 'Work Sans'))),
      );
    }
  }

  // Helper untuk mendapatkan warna ikon berdasarkan warna liturgi
  Color _getLiturgyColorIcon(String color) {
    switch (color.toLowerCase()) {
      case 'putih':
      case 'emas':
        return Colors.amber.shade700;
      case 'merah':
        return Colors.red.shade700;
      case 'hijau':
        return Colors.green.shade700;
      case 'ungu':
      case 'merah jambu':
        return Colors.purple.shade700;
      default:
        return darkGreyText; // Warna default jika tidak dikenali
    }
  }

  // Helper untuk mendapatkan ikon berdasarkan warna liturgi
  IconData _getIconForLiturgyColor(String color) {
    switch (color.toLowerCase()) {
      case 'putih':
      case 'emas':
        return BootstrapIcons.circle; // Simbol cahaya/kemuliaan
      case 'merah':
        return BootstrapIcons.circle; // Simbol darah/martir/roh kudus
      case 'hijau':
        return BootstrapIcons.circle; // Simbol pertumbuhan/harapan
      case 'ungu':
      case 'merah jambu': // Rose, mirip dengan ungu untuk masa tobat
        return BootstrapIcons.circle; // Simbol pertobatan/keagungan
      default:
        return BootstrapIcons
            .question_circle; // Ikon default jika warna tidak dikenal
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: backgroundWhite, // Background keseluruhan halaman
      appBar: AppBar(
        backgroundColor: primaryTextColor, // Warna AppBar putih
        elevation: 1,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Image.asset(
              'assets/images/altarlink_logo.webp', // Ganti dengan path logo Anda
              height: 50,
              width: 150,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.error, color: redAccent);
              },
            ),
          ],
        ),
        // actions: const [], // Tidak ada action di AppBar ini, sudah sesuai
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(
            bottom: 100), // Padding bawah agar tidak terhalang nav bar
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bagian Misa Mendatang (Next Mass)
            StreamBuilder<MassModel?>(
              stream: _massService.getNextMass(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildInfoCard(
                      screenWidth,
                      const Center(
                          child: CircularProgressIndicator(
                              color: primaryTextColor)),
                      isError: false,
                      isNoData: false);
                } else if (snapshot.hasError) {
                  print('Error fetching next mass: ${snapshot.error}');
                  return _buildInfoCard(
                      screenWidth,
                      Center(
                          child: Text('Error: ${snapshot.error}',
                              style: TextStyle(
                                  color: redAccent, fontFamily: 'Work Sans'))),
                      isError: true,
                      isNoData: false);
                } else if (!snapshot.hasData || snapshot.data == null) {
                  return _buildInfoCard(
                      screenWidth,
                      Center(
                        child: Text(
                          'Tidak ada Misa mendatang yang terdaftar.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Work Sans',
                            fontWeight: FontWeight.w500,
                            fontSize: screenWidth * 0.05,
                            color: darkGreyText,
                          ),
                        ),
                      ),
                      isError: false,
                      isNoData: true);
                } else {
                  MassModel nextMass = snapshot.data!;
                  return _buildNextMassDetailsCard(nextMass, screenWidth);
                }
              },
            ),

            const Padding(
              padding: EdgeInsets.fromLTRB(
                  16.0, 20.0, 16.0, 10.0), // Padding atas lebih besar
              child: Text(
                'Daftar Misa Lainnya:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Work Sans',
                  color: darkGreyText,
                ),
              ),
            ),

            // Bagian Daftar Semua Misa
            StreamBuilder<List<MassModel>>(
              stream: _massService.getMasses(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  print('Error fetching all masses: ${snapshot.error}');
                  return Center(
                      child: Text('Error memuat daftar Misa: ${snapshot.error}',
                          style: const TextStyle(
                              color: redAccent, fontFamily: 'Work Sans')));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                      child: Text('Belum ada Misa lain yang terdaftar.',
                          style: TextStyle(
                              fontFamily: 'Work Sans',
                              color: darkGreyText.withOpacity(0.7))));
                } else {
                  List<MassModel> allMasses = snapshot.data!;

                  // Dapatkan ID Misa mendatang agar tidak diduplikasi di daftar "Misa Lainnya"
                  String? nextMassId;
                  if (allMasses.isNotEmpty) {
                    // Logika untuk mendapatkan nextMassId dari getNextMass() bisa lebih kompleks
                    // Untuk saat ini, kita asumsikan yang pertama dari getMasses() adalah yang paling dekat
                    // dan mungkin juga yang diambil oleh getNextMass().
                    // Cara paling aman adalah mendapatkan ID dari stream getNextMass() langsung.
                    // Namun, karena itu di StreamBuilder terpisah, kita lakukan filter sederhana.
                    // Jika Anda menggunakan widget NextMassCard terpisah seperti rekomendasi sebelumnya,
                    // maka ID bisa diteruskan ke sini.
                    // Untuk sementara, kita akan cek ulang data pertama dari getMasses()
                    // dengan asumsi MassService.getNextMass() mengambil yang paling awal.
                    _massService.getNextMass().first.then((value) {
                      if (value != null && mounted) {
                        setState(() {
                          // Tidak perlu setState karena ini di dalam StreamBuilder List,
                          // tapi logika ini hanya untuk mendapatkan ID yang tepat.
                          // Sebaiknya id ini diambil di State _MassInformationPageState
                          // dan diteruskan ke sini sebagai variabel.
                        });
                        nextMassId = value.id;
                      }
                    });
                  }

                  // Filter Misa yang sudah ditampilkan di bagian "Misa Mendatang"
                  // Jika nextMassId tidak null, filter keluar misa dengan ID tersebut
                  final filteredMasses =
                      allMasses.where((mass) => mass.id != nextMassId).toList();

                  if (filteredMasses.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Misa mendatang yang ditampilkan di atas adalah satu-satunya Misa yang terdaftar saat ini.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontFamily: 'Work Sans',
                              fontSize: 14,
                              color: darkGreyText.withOpacity(0.7)),
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true, // Penting agar ListView bersarang bekerja
                    physics:
                        const NeverScrollableScrollPhysics(), // Nonaktifkan scroll ListView ini
                    itemCount: filteredMasses.length,
                    itemBuilder: (context, index) {
                      MassModel mass = filteredMasses[index];
                      return MassListTile(
                        mass: mass,
                        formatMassDateTime: _formatMassDateTime,
                        launchUrl: _launchUrl,
                        allUsers:
                            _allUsers, // Teruskan Map data user ke MassListTile
                      );
                    },
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // Helper untuk membangun card info (loading, error, no data)
  Widget _buildInfoCard(double screenWidth, Widget childContent,
      {required bool isError, required bool isNoData}) {
    return Container(
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.all(20.0),
      height: 250, // Tinggi konsisten untuk card info
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: isError
            ? LinearGradient(
                colors: [Colors.red.shade100, Colors.red.shade300],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : const LinearGradient(
                colors: [Color(0xFFFFEFA3), orangeAccent],
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
      child: Center(child: childContent),
    );
  }

  // Helper untuk membangun card detail Misa mendatang
  Widget _buildNextMassDetailsCard(MassModel nextMass, double screenWidth) {
    return Container(
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFFFFEFA3), orangeAccent],
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
            _formatMassDateTime(nextMass.massDateTime),
            style: TextStyle(
              fontFamily: 'Work Sans',
              fontWeight: FontWeight.w500,
              fontSize: screenWidth * 0.05,
              color: darkGreyText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            nextMass.title,
            style: TextStyle(
              fontFamily: 'Work Sans',
              fontWeight: FontWeight.w400,
              fontSize: screenWidth * 0.06,
              height: 1.2,
              color: darkGreyText,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),
          // Selebran
          if (nextMass.celebrant != null && nextMass.celebrant!.isNotEmpty)
            _buildDetailRow(
                BootstrapIcons.person_fill, 'Selebran', nextMass.celebrant!),
          // Misdinar
          if (nextMass.misdinarUids != null &&
              nextMass.misdinarUids!.isNotEmpty)
            _buildMisdinarDetailRow(nextMass.misdinarUids!),
          // Warna Liturgi
          _buildDetailRow(BootstrapIcons.palette_fill, 'Warna Liturgi',
              nextMass.liturgyColor,
              iconColor: _getLiturgyColorIcon(nextMass.liturgyColor)),
          // Deskripsi
          if (nextMass.description.isNotEmpty)
            _buildDetailRow(BootstrapIcons.info_circle_fill, 'Deskripsi',
                nextMass.description,
                maxLines: 3),

          // Bagian Liturgi Sabda (detail)
          const SizedBox(height: 15),
          Text(
            'Detail Liturgi Sabda:',
            style: TextStyle(
              fontFamily: 'Work Sans',
              fontWeight: FontWeight.bold,
              fontSize: screenWidth * 0.04,
              color: darkGreyText,
            ),
          ),
          const SizedBox(height: 8),
          if (nextMass.firstReading != null &&
              nextMass.firstReading!.isNotEmpty)
            _buildDetailRow(BootstrapIcons.book_fill, 'Bacaan Pertama',
                nextMass.firstReading!),
          if (nextMass.psalm != null && nextMass.psalm!.isNotEmpty)
            _buildDetailRow(BootstrapIcons.music_note_beamed,
                'Mazmur Tanggapan', nextMass.psalm!),
          if (nextMass.secondReading != null &&
              nextMass.secondReading!.isNotEmpty)
            _buildDetailRow(BootstrapIcons.book_fill, 'Bacaan Kedua',
                nextMass.secondReading!),
          if (nextMass.gospel != null && nextMass.gospel!.isNotEmpty)
            _buildDetailRow(
                BootstrapIcons.book_half, 'Bacaan Injil', nextMass.gospel!),

          const SizedBox(height: 15),
          Align(
            alignment: Alignment.bottomRight,
            child: ElevatedButton.icon(
              onPressed: () {
                String query = '';
                if (nextMass.firstReading != null &&
                    nextMass.firstReading!.isNotEmpty)
                  query += '${nextMass.firstReading!} ';
                if (nextMass.psalm != null && nextMass.psalm!.isNotEmpty)
                  query += '${nextMass.psalm!} ';
                if (nextMass.secondReading != null &&
                    nextMass.secondReading!.isNotEmpty)
                  query += '${nextMass.secondReading!} ';
                if (nextMass.gospel != null && nextMass.gospel!.isNotEmpty)
                  query += '${nextMass.gospel!} ';

                if (query.isNotEmpty) {
                  _launchUrl(
                      'https://www.google.com/search?q=${Uri.encodeComponent(query.trim())} bacaan misa hari ini');
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Tidak ada bacaan untuk dicari.',
                            style: TextStyle(fontFamily: 'Work Sans'))),
                  );
                }
              },
              icon: const Icon(BootstrapIcons.search,
                  size: 18, color: primaryTextColor),
              label: Text(
                'Cari Bacaan Online',
                style: TextStyle(
                  fontFamily: 'Work Sans',
                  fontWeight: FontWeight.w500,
                  fontSize: screenWidth * 0.038,
                  color: primaryTextColor,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE39D4A),
                foregroundColor: primaryTextColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget untuk baris detail
  Widget _buildDetailRow(IconData icon, String label, String value,
      {Color? iconColor, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: iconColor ?? orangeAccent),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$label:',
                  style: TextStyle(
                    fontFamily: 'Work Sans',
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: darkGreyText.withOpacity(0.8),
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontFamily: 'Work Sans',
                    fontSize: 14,
                    color: darkGreyText,
                  ),
                  maxLines: maxLines,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget khusus untuk baris detail Misdinar
  Widget _buildMisdinarDetailRow(List<String> misdinarUids) {
    if (misdinarUids.isEmpty) return const SizedBox.shrink();

    // Mengambil nama-nama misdinar yang tersedia dari _allUsers
    List<String> misdinarNames =
        misdinarUids.map((uid) => _getMisdinarName(uid)).toList();
    // Filter out 'Pengguna Tidak Dikenal' or similar if they don't exist in _allUsers
    misdinarNames.removeWhere((name) =>
        name == 'Pengguna Tidak Dikenal'); // Atau sesuaikan teks default Anda

    if (misdinarNames.isEmpty) {
      return const SizedBox.shrink(); // Jika semua UID tidak ditemukan
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(BootstrapIcons.person_badge_fill,
              size: 20, color: orangeAccent),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Misdinar yang Bertugas:',
                  style: TextStyle(
                    fontFamily: 'Work Sans',
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: darkGreyText.withOpacity(0.8),
                  ),
                ),
                Wrap(
                  spacing: 6.0,
                  runSpacing: 4.0,
                  children: misdinarNames.map((name) {
                    return Chip(
                      label: Text(name,
                          style: const TextStyle(
                              fontFamily: 'Work Sans',
                              fontSize: 12,
                              color: primaryTextColor)),
                      backgroundColor: orangeAccent.withOpacity(0.8),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Widget untuk setiap item Misa dalam daftar
class MassListTile extends StatelessWidget {
  final MassModel mass;
  final Function(Timestamp) formatMassDateTime;
  final Function(String) launchUrl;
  final Map<String, UserModel> allUsers; // Terima Map data user dari parent

  const MassListTile({
    super.key,
    required this.mass,
    required this.formatMassDateTime,
    required this.launchUrl,
    required this.allUsers, // Wajib diisi
  });

  // Helper untuk mendapatkan nama misdinar dari UID
  String _getMisdinarNames(List<String> uids) {
    if (uids.isEmpty) {
      return 'Tidak ada';
    }
    List<String> names = [];
    for (String uid in uids) {
      final user = allUsers[uid];
      if (user != null) {
        names.add(user.displayName);
      }
    }
    return names.isNotEmpty ? names.join(', ') : 'Nama tidak ditemukan';
  }

  // Helper untuk menggabungkan bacaan menjadi satu string
  String _getCombinedReadings(MassModel mass) {
    List<String> parts = [];
    if (mass.firstReading != null && mass.firstReading!.isNotEmpty) {
      parts.add('P1: ${mass.firstReading!}');
    }
    if (mass.psalm != null && mass.psalm!.isNotEmpty) {
      parts.add('Mazmur: ${mass.psalm!}');
    }
    if (mass.secondReading != null && mass.secondReading!.isNotEmpty) {
      parts.add('P2: ${mass.secondReading!}');
    }
    return parts.join(' | ');
  }

  @override
  Widget build(BuildContext context) {
    final combinedReadings = _getCombinedReadings(mass);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              mass.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                fontFamily: 'Work Sans',
                color: Color(0xFF25242E),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              formatMassDateTime(mass.massDateTime),
              style: const TextStyle(
                fontSize: 14,
                fontFamily: 'Work Sans',
                color: Color(0xFF535353),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Warna Liturgi: ${mass.liturgyColor}',
              style: const TextStyle(
                fontSize: 13,
                fontFamily: 'Work Sans',
                color: Color(0xFF8E8DAA),
              ),
            ),
            if (mass.celebrant != null && mass.celebrant!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text('Selebran: ${mass.celebrant!}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontFamily: 'Work Sans',
                      color: Color(0xFF535353),
                    )),
              ),
            if (mass.misdinarUids != null && mass.misdinarUids!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  'Misdinar: ${_getMisdinarNames(mass.misdinarUids!)}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontFamily: 'Work Sans',
                    color: Color(0xFF535353),
                  ),
                ),
              ),
            const SizedBox(height: 8),
            Text(
              mass.description,
              style: const TextStyle(
                fontSize: 14,
                fontFamily: 'Work Sans',
                color: Color(0xFF535353),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (combinedReadings.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text('Bacaan: $combinedReadings',
                    style: const TextStyle(
                        fontSize: 13, fontStyle: FontStyle.italic)),
              ),
            if (mass.gospel != null && mass.gospel!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text('Injil: ${mass.gospel!}',
                    style: const TextStyle(
                        fontSize: 13, fontStyle: FontStyle.italic)),
              ),
            const SizedBox(height: 8),
            // Tombol atau Teks untuk link (jika ada)
            if (combinedReadings.isNotEmpty ||
                (mass.gospel != null && mass.gospel!.isNotEmpty))
              Align(
                alignment: Alignment.bottomRight,
                child: TextButton.icon(
                  onPressed: () {
                    // Contoh: membuka Google Search untuk bacaan atau Injil
                    String query =
                        "${mass.firstReading ?? ''} ${mass.psalm ?? ''} ${mass.secondReading ?? ''} ${mass.gospel ?? ''} bacaan misa";
                    launchUrl(
                        'https://www.google.com/search?q=${Uri.encodeComponent(query.trim())}');
                  },
                  icon: const Icon(Icons.open_in_new, size: 18),
                  label: const Text('Cari Bacaan Online'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
