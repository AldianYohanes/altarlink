// lib/screens/admin_panel/add_edit_mass_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:altarlink4/models/mass_model.dart';
import 'package:altarlink4/models/user_model.dart';
import 'package:altarlink4/services/mass_service.dart';
import 'package:altarlink4/services/auth/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';
// import 'package:geolocator/geolocator.dart'; // Hapus impor ini

class AddEditMassPage extends StatefulWidget {
  final MassModel? mass;

  const AddEditMassPage({super.key, this.mass});

  @override
  State<AddEditMassPage> createState() => _AddEditMassPageState();
}

class _AddEditMassPageState extends State<AddEditMassPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _celebrantController = TextEditingController();
  final TextEditingController _firstReadingController = TextEditingController();
  final TextEditingController _psalmController = TextEditingController();
  final TextEditingController _secondReadingController =
      TextEditingController();
  final TextEditingController _gospelController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  String? _selectedLiturgyColor;
  final List<String> _liturgyColors = [
    'Putih',
    'Hijau',
    'Merah',
    'Ungu',
    'Merah Jambu',
    'Emas'
  ];

  List<UserModel> _allUsers = [];
  List<String> _selectedMisdinarUids = [];

  // double? _massLocationLat; // Hapus properti ini
  // double? _massLocationLng; // Hapus properti ini

  bool _isLoading = false;
  final MassService _massService = MassService();

  static const Color primaryTextColor = Color(0xFFFFFFFF);
  static const Color orangeAccent = Color(0xFFFFA852);
  static const Color backgroundWhite = Color(0xFFF5F5F5);
  static const Color darkGreyText = Color(0xFF535353);
  static const Color borderColor = Color(0xFFBDBDBD);

  @override
  void initState() {
    super.initState();
    _fetchUsers();

    if (widget.mass != null) {
      _titleController.text = widget.mass!.title;
      _descriptionController.text = widget.mass!.description;
      _celebrantController.text = widget.mass!.celebrant ?? '';
      _firstReadingController.text = widget.mass!.firstReading ?? '';
      _psalmController.text = widget.mass!.psalm ?? '';
      _secondReadingController.text = widget.mass!.secondReading ?? '';
      _gospelController.text = widget.mass!.gospel ?? '';
      _selectedLiturgyColor = widget.mass!.liturgyColor;
      _selectedMisdinarUids = List.from(widget.mass!.misdinarUids ?? []);

      // _massLocationLat = widget.mass!.locationLat; // Hapus baris ini
      // _massLocationLng = widget.mass!.locationLng; // Hapus baris ini

      DateTime massDateTime = widget.mass!.massDateTime.toDate();
      _selectedDate =
          DateTime(massDateTime.year, massDateTime.month, massDateTime.day);
      _selectedTime = TimeOfDay.fromDateTime(massDateTime);
    } else {
      _selectedLiturgyColor = 'Hijau';
      _selectedDate = DateTime.now();
      _selectedTime = TimeOfDay.now();
    }
  }

  void _fetchUsers() {
    Provider.of<AuthService>(context, listen: false).getUsersStream().listen(
        (users) {
      if (mounted) {
        setState(() {
          _allUsers = users;
        });
      }
    }, onError: (error) {
      print('Error fetching users: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat daftar pengguna: $error')),
      );
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 2)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: orangeAccent,
              onPrimary: primaryTextColor,
              surface: primaryTextColor,
              onSurface: darkGreyText,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: orangeAccent,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: orangeAccent,
              onPrimary: primaryTextColor,
              surface: primaryTextColor,
              onSurface: darkGreyText,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: orangeAccent,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _selectMisdinars() async {
    List<String> tempSelectedUids = List.from(_selectedMisdinarUids);

    final selected = await showDialog<List<String>>(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setStateSB) {
            final filteredUsers = _allUsers.where((user) {
              return true;
            }).toList();

            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              title: const Text('Pilih Misdinar yang Bertugas',
                  style: TextStyle(
                      fontFamily: 'Work Sans',
                      fontWeight: FontWeight.bold,
                      color: darkGreyText)),
              content: filteredUsers.isEmpty
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(BootstrapIcons.person_x,
                            size: 50, color: darkGreyText),
                        const SizedBox(height: 10),
                        const Text(
                          'Tidak ada pengguna ditemukan.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontFamily: 'Work Sans', color: darkGreyText),
                        ),
                      ],
                    )
                  : SizedBox(
                      width: double.maxFinite,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: filteredUsers.length,
                        itemBuilder: (context, index) {
                          final user = filteredUsers[index];
                          final isSelected =
                              tempSelectedUids.contains(user.uid);
                          return CheckboxListTile(
                            title: Text(user.fullName ?? user.email,
                                style: const TextStyle(
                                    fontFamily: 'Work Sans',
                                    color: darkGreyText)),
                            subtitle: Text(user.email,
                                style: TextStyle(
                                    fontFamily: 'Work Sans',
                                    color: darkGreyText.withOpacity(0.7))),
                            value: isSelected,
                            onChanged: (bool? newValue) {
                              setStateSB(() {
                                if (newValue == true) {
                                  tempSelectedUids.add(user.uid);
                                } else {
                                  tempSelectedUids.remove(user.uid);
                                }
                              });
                            },
                            activeColor: orangeAccent,
                            checkColor: primaryTextColor,
                          );
                        },
                      ),
                    ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Batal',
                      style: TextStyle(
                          fontFamily: 'Work Sans', color: darkGreyText)),
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                ),
                TextButton(
                  child: const Text('Pilih',
                      style: TextStyle(
                          fontFamily: 'Work Sans', color: orangeAccent)),
                  onPressed: () {
                    Navigator.of(dialogContext).pop(tempSelectedUids);
                  },
                ),
              ],
            );
          },
        );
      },
    );

    if (selected != null) {
      setState(() {
        _selectedMisdinarUids = selected;
      });
    }
  }

  String _getMisdinarName(String uid) {
    final user = _allUsers.firstWhere(
      (u) => u.uid == uid,
      orElse: () => UserModel(
        uid: uid,
        email: 'Pengguna Tidak Dikenal',
        createdAt: Timestamp.now(),
      ),
    );
    return user.fullName ?? user.email;
  }

  // Hapus fungsi _getCurrentLocation() sepenuhnya
  // Future<void> _getCurrentLocation() async { /* ... */ }

  Future<void> _saveMass() async {
    if (_formKey.currentState!.validate() &&
        _selectedDate != null &&
        _selectedTime != null) {
      setState(() {
        _isLoading = true;
      });

      try {
        DateTime combinedDateTime = DateTime(
          _selectedDate!.year,
          _selectedDate!.month,
          _selectedDate!.day,
          _selectedTime!.hour,
          _selectedTime!.minute,
        );

        final Map<String, dynamic> massData = {
          'title': _titleController.text.trim(),
          'description': _descriptionController.text.trim(),
          'massDateTime': Timestamp.fromMicrosecondsSinceEpoch(
              combinedDateTime.microsecondsSinceEpoch),
          'liturgyColor': _selectedLiturgyColor!,
          'celebrant': _celebrantController.text.trim().isEmpty
              ? null
              : _celebrantController.text.trim(),
          'firstReading': _firstReadingController.text.trim().isEmpty
              ? null
              : _firstReadingController.text.trim(),
          'psalm': _psalmController.text.trim().isEmpty
              ? null
              : _psalmController.text.trim(),
          'secondReading': _secondReadingController.text.trim().isEmpty
              ? null
              : _secondReadingController.text.trim(),
          'gospel': _gospelController.text.trim().isEmpty
              ? null
              : _gospelController.text.trim(),
          'misdinarUids':
              _selectedMisdinarUids.isEmpty ? null : _selectedMisdinarUids,
          // 'locationLat': _massLocationLat, // Hapus baris ini
          // 'locationLng': _massLocationLng, // Hapus baris ini
        };

        if (widget.mass == null) {
          await _massService.addMass(
            title: massData['title'] as String,
            description: massData['description'] as String,
            massDateTime: massData['massDateTime'] as Timestamp,
            liturgyColor: massData['liturgyColor'] as String,
            celebrant: massData['celebrant'] as String?,
            firstReading: massData['firstReading'] as String?,
            psalm: massData['psalm'] as String?,
            secondReading: massData['secondReading'] as String?,
            gospel: massData['gospel'] as String?,
            misdinarUids: massData['misdinarUids'] as List<String>?,
            // locationLat: massData['locationLat'] as double?, // Hapus baris ini
            // locationLng: massData['locationLng'] as double?, // Hapus baris ini
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Misa berhasil ditambahkan!',
                    style: TextStyle(fontFamily: 'Work Sans'))),
          );
        } else {
          await _massService.updateMass(widget.mass!.id, massData);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Misa berhasil diperbarui!',
                    style: TextStyle(fontFamily: 'Work Sans'))),
          );
        }
        if (mounted) {
          Navigator.pop(context);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Gagal menyimpan Misa: ${e.toString()}',
                  style: const TextStyle(fontFamily: 'Work Sans'))),
        );
        print('Error saving mass: $e');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Harap lengkapi semua bidang yang wajib.',
                style: TextStyle(fontFamily: 'Work Sans'))),
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _celebrantController.dispose();
    _firstReadingController.dispose();
    _psalmController.dispose();
    _secondReadingController.dispose();
    _gospelController.dispose();
    super.dispose();
  }

  InputDecoration _buildInputDecoration(String labelText, {String? hintText}) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      labelStyle: const TextStyle(fontFamily: 'Work Sans', color: darkGreyText),
      hintStyle: TextStyle(
          fontFamily: 'Work Sans', color: darkGreyText.withOpacity(0.6)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: orangeAccent, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: borderColor),
      ),
      filled: true,
      fillColor: primaryTextColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundWhite,
      appBar: AppBar(
        title: Text(
            widget.mass == null ? 'Tambah Data Misa Baru' : 'Edit Data Misa',
            style: const TextStyle(
                color: primaryTextColor, fontFamily: 'Work Sans')),
        backgroundColor: orangeAccent,
        foregroundColor: primaryTextColor,
        elevation: 1,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: orangeAccent))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: _buildInputDecoration('Judul Misa',
                          hintText: 'e.g., Misa Minggu Biasa'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Judul Misa tidak boleh kosong';
                        }
                        return null;
                      },
                      style: const TextStyle(
                          fontFamily: 'Work Sans', color: darkGreyText),
                      cursorColor: orangeAccent,
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: Card(
                            elevation: 0,
                            color: primaryTextColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: const BorderSide(color: borderColor),
                            ),
                            child: ListTile(
                              title: Text(
                                _selectedDate == null
                                    ? 'Pilih Tanggal Misa'
                                    : DateFormat('dd MMMM', 'id')
                                        .format(_selectedDate!),
                                style: const TextStyle(
                                    fontFamily: 'Work Sans',
                                    fontSize: 16,
                                    color: darkGreyText),
                              ),
                              trailing: Icon(Icons.calendar_today,
                                  color: orangeAccent),
                              onTap: () => _selectDate(context),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Card(
                            elevation: 0,
                            color: primaryTextColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: const BorderSide(color: borderColor),
                            ),
                            child: ListTile(
                              title: Text(
                                _selectedTime == null
                                    ? 'Pilih Waktu Mismr'
                                    : _selectedTime!.format(context),
                                style: const TextStyle(
                                    fontFamily: 'Work Sans',
                                    fontSize: 16,
                                    color: darkGreyText),
                              ),
                              trailing:
                                  Icon(Icons.access_time, color: orangeAccent),
                              onTap: () => _selectTime(context),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _celebrantController,
                            decoration: _buildInputDecoration(
                                'Nama Romo Selebran',
                                hintText: 'e.g., Rm. Lukas S.J.'),
                            style: const TextStyle(
                                fontFamily: 'Work Sans', color: darkGreyText),
                            cursorColor: orangeAccent,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Nama Romo tidak boleh kosong';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedLiturgyColor,
                            decoration: _buildInputDecoration('Warna Liturgi'),
                            items: _liturgyColors.map((String color) {
                              return DropdownMenuItem<String>(
                                value: color,
                                child: Text(
                                  color,
                                  style: const TextStyle(
                                      fontFamily: 'Work Sans',
                                      color: darkGreyText),
                                ),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedLiturgyColor = newValue;
                              });
                            },
                            validator: (value) =>
                                value == null ? 'Pilih warna liturgi' : null,
                            style: const TextStyle(
                                fontFamily: 'Work Sans', color: darkGreyText),
                            icon: Icon(Icons.arrow_drop_down,
                                color: darkGreyText),
                            dropdownColor: primaryTextColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Hapus bagian Lokasi Misa sepenuhnya
                    // Text(
                    //   'Lokasi Misa (untuk Verifikasi Kehadiran)',
                    //   style: TextStyle( /* ... */ ),
                    // ),
                    // const SizedBox(height: 8),
                    // Container( /* ... */ ),
                    // const SizedBox(height: 24),

                    Text(
                      'Misdinar yang Bertugas',
                      style: TextStyle(
                        fontFamily: 'Work Sans',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: darkGreyText,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: primaryTextColor,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: borderColor),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_selectedMisdinarUids.isEmpty)
                            Text(
                              'Belum ada misdinar yang dipilih.',
                              style: TextStyle(
                                  fontFamily: 'Work Sans',
                                  color: darkGreyText.withOpacity(0.7)),
                            )
                          else
                            Wrap(
                              spacing: 8.0,
                              runSpacing: 4.0,
                              children: _selectedMisdinarUids.map((uid) {
                                return Chip(
                                  label: Text(
                                    _getMisdinarName(uid),
                                    style: const TextStyle(
                                        fontFamily: 'Work Sans',
                                        color: primaryTextColor),
                                  ),
                                  backgroundColor: orangeAccent,
                                  deleteIcon: const Icon(Icons.close,
                                      size: 18, color: primaryTextColor),
                                  onDeleted: () {
                                    setState(() {
                                      _selectedMisdinarUids.remove(uid);
                                    });
                                  },
                                );
                              }).toList(),
                            ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: _selectMisdinars,
                              icon: const Icon(BootstrapIcons.person_plus,
                                  color: orangeAccent),
                              label: const Text(
                                'Pilih/Ubah Misdinar',
                                style: TextStyle(
                                    fontFamily: 'Work Sans',
                                    color: orangeAccent),
                              ),
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                side: const BorderSide(color: orangeAccent),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    Text(
                      'Detail Liturgi Sabda',
                      style: TextStyle(
                        fontFamily: 'Work Sans',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: darkGreyText,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: _buildInputDecoration(
                          'Deskripsi Misa/Catatan (Opsional)',
                          hintText:
                              'Misal: Misa dengan intensi khusus untuk para pekerja.'),
                      style: const TextStyle(
                          fontFamily: 'Work Sans', color: darkGreyText),
                      cursorColor: orangeAccent,
                      maxLines: 3,
                      minLines: 1,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _firstReadingController,
                      decoration: _buildInputDecoration(
                          'Bacaan Pertama (Opsional)',
                          hintText: 'Misal: Yes 49:1-6'),
                      style: const TextStyle(
                          fontFamily: 'Work Sans', color: darkGreyText),
                      cursorColor: orangeAccent,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _psalmController,
                      decoration: _buildInputDecoration(
                          'Mazmur Tanggapan (Opsional)',
                          hintText: 'Misal: Mzm 139:1-3, 13-14ab, 14c-15'),
                      style: const TextStyle(
                          fontFamily: 'Work Sans', color: darkGreyText),
                      cursorColor: orangeAccent,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _secondReadingController,
                      decoration: _buildInputDecoration(
                          'Bacaan Kedua (Opsional)',
                          hintText: 'Misal: Kis 13:22-26'),
                      style: const TextStyle(
                          fontFamily: 'Work Sans', color: darkGreyText),
                      cursorColor: orangeAccent,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _gospelController,
                      decoration: _buildInputDecoration(
                          'Bacaan Injil (Opsional)',
                          hintText: 'Misal: Yoh 1:19-28'),
                      style: const TextStyle(
                          fontFamily: 'Work Sans', color: darkGreyText),
                      cursorColor: orangeAccent,
                    ),
                    const SizedBox(height: 30),

                    ElevatedButton(
                      onPressed: _saveMass,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: orangeAccent,
                        foregroundColor: primaryTextColor,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        widget.mass == null
                            ? 'Tambah Data Misa'
                            : 'Simpan Perubahan',
                        style: const TextStyle(
                            fontSize: 18, fontFamily: 'Work Sans'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
