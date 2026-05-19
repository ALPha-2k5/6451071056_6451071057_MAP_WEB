import 'package:cloud_firestore/cloud_firestore.dart';
class OrderModel {
final String docId;
final String id;
final String userId;
final List<dynamic> products;
final double subTotal;
final double taxAmount;
final double taxRate;
final double shippingAmount;
final double totalDiscountAmount;
final double couponDiscountAmount;
final double totalAmount;
final String paymentStatus;
final String orderStatus;
final String paymentMethod;
final String paymentMethodType;
final int itemCount;
final DateTime orderDate;
final DateTime createdAt;
final DateTime updatedAt;
final DateTime? shippingDate;
final Map<String, dynamic> shippingAddress;
// 👇 Admin list helper fields
String customerName;
OrderModel({
required this.docId,
required this.id,
required this.userId,
required this.products,
required this.subTotal,
required this.taxAmount,
required this.taxRate,
required this.shippingAmount,
required this.totalDiscountAmount,
required this.couponDiscountAmount,
required this.totalAmount,
required this.paymentStatus,
required this.orderStatus,
required this.paymentMethod,
required this.paymentMethodType,
required this.itemCount,
required this.orderDate,
required this.createdAt,
required this.updatedAt,
required this.shippingAddress,
this.shippingDate,
this.customerName = '',
});
static DateTime _parseDate(dynamic date) {
if (date == null) return DateTime.now();
if (date is Timestamp) return date.toDate();
if (date is DateTime) return date;
if (date is String) return DateTime.tryParse(date) ?? DateTime.now();
return DateTime.now();
}
static DateTime? _parseNullableDate(dynamic date) {
if (date == null) return null;
if (date is Timestamp) return date.toDate();
if (date is DateTime) return date;
if (date is String) return DateTime.tryParse(date);
return null;
}
factory OrderModel.fromFirestore(DocumentSnapshot doc) {
final data = doc.data() as Map<String, dynamic>;
return OrderModel(
docId: doc.id,
id: data['id'] ?? '',
userId: data['userId'] ?? '',
products: data['products'] ?? [],
subTotal: (data['subTotal'] ?? 0).toDouble(),
taxAmount: (data['taxAmount'] ?? 0).toDouble(),
taxRate: (data['taxRate'] ?? 0).toDouble(),
shippingAmount: (data['shippingAmount'] ?? 0).toDouble(),
totalDiscountAmount: (data['totalDiscountAmount'] ?? 0).toDouble(),
couponDiscountAmount: (data['couponDiscountAmount'] ?? 0).toDouble(),
totalAmount: (data['totalAmount'] ?? 0).toDouble(),
paymentStatus: data['paymentStatus'] ?? '',
orderStatus: data['orderStatus'] ?? '',
paymentMethod: data['paymentMethod'] ?? '',
paymentMethodType: data['paymentMethodType'] ?? '',
itemCount: data['itemCount'] ?? 0,
orderDate: _parseDate(data['orderDate']),
createdAt: _parseDate(data['createdAt']),
updatedAt: _parseDate(data['updatedAt']),
shippingDate: _parseNullableDate(data['shippingDate']),
shippingAddress: data['shippingAddress'] ?? {},
);
}
}