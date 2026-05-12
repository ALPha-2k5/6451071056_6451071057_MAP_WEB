import 'package:cloud_firestore/cloud_firestore.dart';

class AddressModel {
  final String id;
  final String city;
  final String ward;
  final String street;
  final String number;
  final bool isDefault;
  final DateTime? createdAt;
  final double? latitude;
  final double? longitude;
  AddressModel({
    required this.id,
    required this.city,
    required this.ward,
    required this.street,
    required this.number,
    required this.isDefault,
    this.createdAt,
    this.latitude,
    this.longitude,
  });
  factory AddressModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AddressModel(
      id: doc.id,
      city: data['city'] ?? '',
      ward: data['ward'] ?? '',
      street: data['street'] ?? '',
      number: data['number'] ?? '',
      isDefault: data['isDefault'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      latitude: (data['latitude'] as num?)?.toDouble(),
      longitude: (data['longitude'] as num?)?.toDouble(),
    );
  }
  String get fullAddress => '$number $street, $ward, $city';
}
