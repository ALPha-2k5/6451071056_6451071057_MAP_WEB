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
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
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
}
