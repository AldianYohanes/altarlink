// lib/screens/admin_panel/admin_masses_page.dart

import 'package:flutter/material.dart';
import 'package:altarlink4/services/mass_service.dart';
import 'package:altarlink4/models/mass_model.dart';
import 'package:altarlink4/screens/admin_panel/add_edit_mass_page.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart'; // Ini mungkin tidak terpakai jika tidak ada link di data misa
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart'; // Import untuk ikon Bootstrap

class AdminMassesPage extends StatefulWidget {
  const AdminMassesPage({super.key});

  @override
  State<AdminMassesPage> createState() => _AdminMassesPageState();
}

class _AdminMassesPageState extends State<AdminMassesPage> {
  final MassService _massService = MassService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Definisikan warna yang konsisten
  static const Color primaryTextColor =
      Color(0xFFFFFFFF); // White for card background, input fields, FAB Icon
  static const Color orangeAccent =
      Color(0xFFFFA852); // Accent color for buttons, icons, focused borders
  static const Color backgroundWhite =
      Color(0xFFF5F5F5); // Main Scaffold/Container background
  static const Color darkGreyText =
      Color(0xFF535353); // General text color, primary for dark elements
  static const Color redAccent = Color(0xFFFF5252); // Delete icon/button color
  static const Color borderColor = Color(0xFFBDBDBD); // Outline border color

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

  String _formatMassDateTime(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    // Menggunakan locale 'id' untuk nama hari dan bulan dalam Bahasa Indonesia
    return DateFormat('EEEE, dd MMMM yyyy, HH:mm', 'id').format(dateTime);
  }

  Color _getColorForLiturgy(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'putih':
        return Colors
            .white; // Or a very light grey if white is too bright on white background
      case 'hijau':
        return Colors.green.shade700;
      case 'merah':
        return Colors.red.shade700;
      case 'ungu':
        return Colors.purple.shade700;
      case 'merah jambu':
        return Colors.pink.shade300; // Rose color
      case 'emas':
        return Colors.amber.shade700;
      default:
        return darkGreyText; // Default color
    }
  }

  IconData _getIconForLiturgyColor(String color) {
    // Icons for liturgy colors, can be simplified or more specific if needed
    return BootstrapIcons.circle_fill; // Using a solid circle fill for all
  }

  Future<void> _confirmDeleteMass(String massId, String title) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          title: const Text(
            'Hapus Data Misa?',
            style: TextStyle(
                fontFamily: 'Work Sans',
                fontWeight: FontWeight.bold,
                color: darkGreyText),
          ),
          content: Text(
            'Anda yakin ingin menghapus data Misa "$title"? Tindakan ini tidak dapat dibatalkan.',
            style:
                const TextStyle(fontFamily: 'Work Sans', color: darkGreyText),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal',
                  style:
                      TextStyle(fontFamily: 'Work Sans', color: darkGreyText)),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text('Hapus',
                  style: TextStyle(fontFamily: 'Work Sans', color: redAccent)),
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                try {
                  await _massService.deleteMass(massId);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Data Misa berhasil dihapus!',
                            style: TextStyle(fontFamily: 'Work Sans'))),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            'Gagal menghapus data Misa: ${e.toString()}',
                            style: const TextStyle(fontFamily: 'Work Sans'))),
                  );
                  print('Error deleting mass: $e');
                }
              },
            ),
          ],
        );
      },
    );
  }

  // _launchUrl tidak lagi diperlukan jika tidak ada URL yang akan dibuka di halaman ini.
  // Anda bisa menghapusnya atau menyimpannya jika di masa depan ada fitur untuk membuka URL.
  // Future<void> _launchUrl(String url) async {
  //   final Uri uri = Uri.parse(url);
  //   if (await canLaunchUrl(uri)) {
  //     await launchUrl(uri);
  //   } else {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //           content: Text('Tidak dapat membuka link: $url',
  //               style: const TextStyle(fontFamily: 'Work Sans'))),
  //     );
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundWhite, // Background utama halaman
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari Misa...',
                hintStyle: TextStyle(
                    fontFamily: 'Work Sans',
                    color: darkGreyText.withOpacity(0.6)),
                prefixIcon: Icon(BootstrapIcons.search, color: darkGreyText),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon:
                            Icon(BootstrapIcons.x_circle, color: darkGreyText),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(100), // Mirip search bar notifikasi
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
              style:
                  const TextStyle(fontFamily: 'Work Sans', color: darkGreyText),
              cursorColor: orangeAccent,
            ),
          ),
          Expanded(
            child: StreamBuilder<List<MassModel>>(
              stream: _massService.getMasses(), // Pastikan ini memanggil stream
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                      child: CircularProgressIndicator(color: orangeAccent));
                } else if (snapshot.hasError) {
                  print('Error fetching masses for admin: ${snapshot.error}');
                  return Center(
                      child: Text(
                    'Error memuat data Misa: ${snapshot.error}',
                    style: const TextStyle(
                        fontFamily: 'Work Sans', color: redAccent),
                  ));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(BootstrapIcons.calendar_x,
                            size: 80, color: darkGreyText),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isNotEmpty
                              ? 'Tidak ada Misa yang cocok dengan pencarian Anda.'
                              : 'Belum ada data Misa untuk dikelola.\nKetuk tombol "+" untuk menambah Misa baru.',
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
                  List<MassModel> masses = snapshot.data!;

                  // Filter Misa berdasarkan query pencarian
                  final filteredMasses = masses.where((mass) {
                    final queryLower = _searchQuery.toLowerCase();
                    return mass.title.toLowerCase().contains(queryLower) ||
                        mass.description.toLowerCase().contains(queryLower) ||
                        (mass.celebrant?.toLowerCase() ?? '')
                            .contains(queryLower) || // Cek celebrant
                        mass.liturgyColor.toLowerCase().contains(queryLower) ||
                        (mass.firstReading?.toLowerCase() ?? '')
                            .contains(queryLower) || // Cek firstReading
                        (mass.psalm?.toLowerCase() ?? '')
                            .contains(queryLower) || // Cek psalm
                        (mass.secondReading?.toLowerCase() ?? '')
                            .contains(queryLower) || // Cek secondReading
                        (mass.gospel?.toLowerCase() ?? '')
                            .contains(queryLower); // Cek gospel
                  }).toList();

                  // Urutkan misa berdasarkan tanggal dan waktu terbaru
                  filteredMasses
                      .sort((a, b) => b.massDateTime.compareTo(a.massDateTime));

                  if (filteredMasses.isEmpty && _searchQuery.isNotEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(BootstrapIcons.search_heart_fill,
                              size: 80, color: darkGreyText),
                          const SizedBox(height: 16),
                          Text(
                            'Tidak ada Misa yang cocok dengan pencarian Anda.',
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
                    itemCount: filteredMasses.length,
                    itemBuilder: (context, index) {
                      MassModel mass = filteredMasses[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        elevation:
                            0, // Menggunakan elevation 0 agar desain lebih flat
                        color: primaryTextColor, // Warna background card
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 12.0),
                          leading: Icon(
                            _getIconForLiturgyColor(mass.liturgyColor),
                            color: _getColorForLiturgy(mass.liturgyColor),
                            size: 30,
                          ),
                          title: Text(
                            mass.title,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Work Sans',
                                color: darkGreyText),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${_formatMassDateTime(mass.massDateTime)}',
                                style: const TextStyle(
                                    fontFamily: 'Work Sans',
                                    fontSize: 12,
                                    color: darkGreyText),
                              ),
                              Text(
                                'Warna Liturgi: ${mass.liturgyColor}',
                                style: const TextStyle(
                                    fontFamily: 'Work Sans',
                                    fontSize: 12,
                                    color: darkGreyText),
                              ),
                              if (mass.celebrant != null &&
                                  mass.celebrant!.isNotEmpty)
                                Text(
                                  'Selebran: ${mass.celebrant}',
                                  style: const TextStyle(
                                      fontFamily: 'Work Sans',
                                      fontSize: 12,
                                      color: darkGreyText),
                                ),
                              // Menghapus pemotongan deskripsi di sini agar detail penuh ada di dialog
                              Text(
                                mass.description,
                                style: const TextStyle(
                                    fontFamily: 'Work Sans',
                                    fontSize: 12,
                                    color: darkGreyText),
                                maxLines: 2, // Batasi 2 baris di preview
                                overflow:
                                    TextOverflow.ellipsis, // Tambahkan elipsis
                              ),
                            ],
                          ),
                          isThreeLine:
                              false, // Menyesuaikan dengan konten subtitle yang dinamis
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(BootstrapIcons.pencil_square,
                                    color: orangeAccent), // Ikon edit
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          AddEditMassPage(mass: mass),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(BootstrapIcons.trash,
                                    color: redAccent), // Ikon hapus
                                onPressed: () =>
                                    _confirmDeleteMass(mass.id, mass.title),
                              ),
                            ],
                          ),
                          onTap: () {
                            // Opsi: Tampilkan detail misa lebih lanjut dalam dialog
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  title: Text(mass.title,
                                      style: const TextStyle(
                                          fontFamily: 'Work Sans',
                                          fontWeight: FontWeight.bold,
                                          color: darkGreyText)),
                                  content: SingleChildScrollView(
                                    child: ListBody(
                                      children: <Widget>[
                                        Text(
                                            'Waktu: ${_formatMassDateTime(mass.massDateTime)}',
                                            style: const TextStyle(
                                                fontFamily: 'Work Sans',
                                                color: darkGreyText)),
                                        const SizedBox(height: 8),
                                        Text(
                                            'Warna Liturgi: ${mass.liturgyColor}',
                                            style: const TextStyle(
                                                fontFamily: 'Work Sans',
                                                color: darkGreyText)),
                                        const SizedBox(height: 8),
                                        if (mass.celebrant != null &&
                                            mass.celebrant!.isNotEmpty) ...[
                                          Text('Selebran: ${mass.celebrant}',
                                              style: const TextStyle(
                                                  fontFamily: 'Work Sans',
                                                  color: darkGreyText)),
                                          const SizedBox(height: 8),
                                        ],
                                        Text('Deskripsi:\n${mass.description}',
                                            style: const TextStyle(
                                                fontFamily: 'Work Sans',
                                                color: darkGreyText)),
                                        if (mass.firstReading != null &&
                                            mass.firstReading!.isNotEmpty) ...[
                                          const SizedBox(height: 8),
                                          Text(
                                              'Bacaan Pertama:\n${mass.firstReading}',
                                              style: const TextStyle(
                                                  fontFamily: 'Work Sans',
                                                  color: darkGreyText)),
                                        ],
                                        if (mass.psalm != null &&
                                            mass.psalm!.isNotEmpty) ...[
                                          const SizedBox(height: 8),
                                          Text(
                                              'Mazmur Tanggapan:\n${mass.psalm}',
                                              style: const TextStyle(
                                                  fontFamily: 'Work Sans',
                                                  color: darkGreyText)),
                                        ],
                                        if (mass.secondReading != null &&
                                            mass.secondReading!.isNotEmpty) ...[
                                          const SizedBox(height: 8),
                                          Text(
                                              'Bacaan Kedua:\n${mass.secondReading}',
                                              style: const TextStyle(
                                                  fontFamily: 'Work Sans',
                                                  color: darkGreyText)),
                                        ],
                                        if (mass.gospel != null &&
                                            mass.gospel!.isNotEmpty) ...[
                                          const SizedBox(height: 8),
                                          Text('Injil:\n${mass.gospel}',
                                              style: const TextStyle(
                                                  fontFamily: 'Work Sans',
                                                  color: darkGreyText)),
                                        ],
                                        // Removed homilyTheme as it's not in MassModel from previous context
                                        // if (mass.homilyTheme != null &&
                                        //     mass.homilyTheme!.isNotEmpty) ...[
                                        //   const SizedBox(height: 8),
                                        //   Text('Tema Homili:\n${mass.homilyTheme}',
                                        //       style: const TextStyle(
                                        //           fontFamily: 'Work Sans',
                                        //           color: darkGreyText)),
                                        // ],
                                      ],
                                    ),
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                      child: const Text('Tutup',
                                          style: TextStyle(
                                              fontFamily: 'Work Sans',
                                              color: orangeAccent)),
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
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigasi ke halaman tambah misa baru
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddEditMassPage(),
            ),
          );
        },
        backgroundColor: orangeAccent,
        foregroundColor: primaryTextColor,
        child: const Icon(Icons.add),
      ),
    );
  }
}
