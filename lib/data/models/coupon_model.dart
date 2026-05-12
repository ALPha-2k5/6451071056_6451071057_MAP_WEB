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
      startDate: (data['startDate'] as Timestamp?)?.toDate(),
      endDate: (data['endDate'] as Timestamp?)?.toDate(),
      usageLimit: data['usageLimit'] ?? 0,
      usageCount: data['usageCount'] ?? 0,
      isActive: data['isActive'] ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updateAt: (data['updateAt'] as Timestamp?)?.toDate(),
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
