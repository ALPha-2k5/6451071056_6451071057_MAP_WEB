import 'package:cloud_firestore/cloud_firestore.dart';

enum DiscountType { percentage, flat }

class CouponModel {
  String id;
  String code;
  String description;
  DiscountType discountType;
  double discountValue;
  DateTime? startDate;
  DateTime? endDate;
  int usageLimit;
  int usageCount;
  bool isActive;
  DateTime? createdAt;
  DateTime? updateAt;
  CouponModel({
    required this.id,
    required this.code,
    required this.description,
    required this.discountType,
    required this.discountValue,
    this.startDate,
    this.endDate,
    required this.usageLimit,
    required this.usageCount,
    required this.isActive,
    this.createdAt,
    this.updateAt,
  });
  static DateTime? _parseDate(dynamic date) {
    if (date == null) return null;
    if (date is Timestamp) return date.toDate();
    if (date is DateTime) return date;
    if (date is String) return DateTime.tryParse(date);
    return null;
  }

  factory CouponModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CouponModel(
      id: doc.id,
      code: data['code'] ?? '',
      description: data['description'] ?? '',
      discountType: data['discountType'] == 'flat'
          ? DiscountType.flat
          : DiscountType.percentage,
      discountValue: (data['discountValue'] ?? 0).toDouble(),
      startDate: _parseDate(data['startDate']),
      endDate: _parseDate(data['endDate']),
      usageLimit: data['usageLimit'] ?? 0,
      usageCount: data['usageCount'] ?? 0,
      isActive: data['isActive'] ?? true,
      createdAt: _parseDate(data['createdAt']),
      updateAt: _parseDate(data['updateAt']),
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'description': description,
      'discountType': discountType == DiscountType.flat ? 'flat' : 'percentage',
      'discountValue': discountValue,
      'startDate': startDate,
      'endDate': endDate,
      'usageLimit': usageLimit,
      'usageCount': usageCount,
      'isActive': isActive,
      'createdAt': createdAt,
      'updateAt': updateAt,
    };
  }
}
