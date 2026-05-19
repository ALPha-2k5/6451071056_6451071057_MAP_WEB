import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryModel {
  String id;
  String name;
  String imageURL;
  bool isActive;
  bool isFeatured;
  int priority;
  DateTime? createdAt;
  DateTime? updatedAt;
  int numberOfProducts;
  int viewCount;
  String createdBy;
  String updatedBy;
  CategoryModel({
    required this.id,
    required this.name,
    required this.imageURL,
    required this.isActive,
    required this.isFeatured,
    required this.priority,
    this.createdAt,
    this.updatedAt,
    required this.numberOfProducts,
    required this.viewCount,
    required this.createdBy,
    required this.updatedBy,
  });
  static DateTime? _parseDate(dynamic date) {
    if (date == null) return null;
    if (date is Timestamp) return date.toDate();
    if (date is DateTime) return date;
    if (date is String) return DateTime.tryParse(date);
    return null;
  }

  factory CategoryModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CategoryModel(
      id: doc.id,
      name: data['name'] ?? '',
      imageURL: data['imageURL'] ?? '',
      isActive: data['isActive'] ?? true,
      isFeatured: data['isFeatured'] ?? false,
      priority: data['priority'] ?? 0,
      createdAt: _parseDate(data['createdAt']),
      updatedAt: _parseDate(data['updatedAt']),
      numberOfProducts: data['numberOfProducts'] ?? 0,
      viewCount: data['viewCount'] ?? 0,
      createdBy: data['createdBy'] ?? '',
      updatedBy: data['updatedBy'] ?? '',
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'imageURL': imageURL,
      'isActive': isActive,
      'isFeatured': isFeatured,
      'priority': priority,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'numberOfProducts': numberOfProducts,
      'viewCount': viewCount,
      'createdBy': createdBy,
      'updatedBy': updatedBy,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
