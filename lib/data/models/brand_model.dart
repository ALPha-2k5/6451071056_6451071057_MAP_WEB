import 'package:cloud_firestore/cloud_firestore.dart';

class BrandModel {
  String id;
  String name;
  String imageURL;
  bool isFeatured;
  bool isActive;
  int productsCount;
  int viewCount;
  DateTime? createdAt;
  DateTime? updatedAt;
  BrandModel({
    required this.id,
    required this.name,
    required this.imageURL,
    required this.isFeatured,
    required this.isActive,
    required this.productsCount,
    required this.viewCount,
    this.createdAt,
    this.updatedAt,
  });
  static DateTime? _parseDate(dynamic date) {
    if (date == null) return null;
    if (date is Timestamp) return date.toDate();
    if (date is DateTime) return date;
    if (date is String) return DateTime.tryParse(date);
    return null;
  }

  factory BrandModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BrandModel(
      id: doc.id,
      name: data['name'] ?? '',
      imageURL: data['imageURL'] ?? '',
      isFeatured: data['isFeatured'] ?? false,
      isActive: data['isActive'] ?? true,
      productsCount: data['productsCount'] ?? 0,
      viewCount: data['viewCount'] ?? 0,
      createdAt: _parseDate(data['createdAt']),
      updatedAt: _parseDate(data['updatedAt']),
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'imageURL': imageURL,
      'isFeatured': isFeatured,
      'isActive': isActive,
      'productsCount': productsCount,
      'viewCount': viewCount,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BrandModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}