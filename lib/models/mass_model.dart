// lib/models/mass_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class MassModel {
  final String id;
  final String title;
  final String description;
  final Timestamp massDateTime;
  final String liturgyColor;
  final String? celebrant;
  final String? firstReading;
  final String? psalm;
  final String? secondReading;
  final String? gospel;
  final List<String>? misdinarUids;
  // final double? locationLat; // Hapus baris ini
  // final double? locationLng; // Hapus baris ini

  MassModel({
    required this.id,
    required this.title,
    required this.description,
    required this.massDateTime,
    required this.liturgyColor,
    this.celebrant,
    this.firstReading,
    this.psalm,
    this.secondReading,
    this.gospel,
    this.misdinarUids,
    // this.locationLat, // Hapus baris ini dari konstruktor
    // this.locationLng, // Hapus baris ini dari konstruktor
  });

  factory MassModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return MassModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      massDateTime: data['massDateTime'] ?? Timestamp.now(),
      liturgyColor: data['liturgyColor'] ?? 'Hijau',
      celebrant: data['celebrant'] as String?,
      firstReading: data['firstReading'] as String?,
      psalm: data['psalm'] as String?,
      secondReading: data['secondReading'] as String?,
      gospel: data['gospel'] as String?,
      misdinarUids: (data['misdinarUids'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      // locationLat: data['locationLat'] as double?, // Hapus baris ini
      // locationLng: data['locationLng'] as double?, // Hapus baris ini
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'massDateTime': massDateTime,
      'liturgyColor': liturgyColor,
      'celebrant': celebrant,
      'firstReading': firstReading,
      'psalm': psalm,
      'secondReading': secondReading,
      'gospel': gospel,
      'misdinarUids': misdinarUids,
    };
  }
}
