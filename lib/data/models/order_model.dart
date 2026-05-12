import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
	final String docId;
	final String id;
	final String userId;
	final List<dynamic> products;
	final double totalAmount;
	final int itemCount;
	final DateTime orderDate;
	final DateTime updatedAt;
	String orderStatus;
	String paymentStatus;

	OrderModel({
		required this.docId,
		required this.id,
		required this.userId,
		required this.products,
		required this.totalAmount,
		required this.itemCount,
		required this.orderDate,
		required this.updatedAt,
		required this.orderStatus,
		required this.paymentStatus,
	});

	factory OrderModel.fromFirestore(DocumentSnapshot doc) {
		final data = doc.data() as Map<String, dynamic>? ?? <String, dynamic>{};

		return OrderModel(
			docId: doc.id,
			id: (data['id'] ?? doc.id).toString(),
			userId: (data['userId'] ?? '').toString(),
			products: (data['products'] as List<dynamic>?) ?? <dynamic>[],
			totalAmount: _toDouble(data['totalAmount']),
			itemCount: _toInt(data['itemCount']),
			orderDate: _toDateTime(data['orderDate']),
			updatedAt: _toDateTime(data['updatedAt']),
			orderStatus: (data['orderStatus'] ?? 'pending').toString(),
			paymentStatus: (data['paymentStatus'] ?? 'pending').toString(),
		);
	}

	static double _toDouble(dynamic value) {
		if (value is num) {
			return value.toDouble();
		}
		return double.tryParse(value?.toString() ?? '') ?? 0;
	}

	static int _toInt(dynamic value) {
		if (value is int) {
			return value;
		}
		if (value is num) {
			return value.toInt();
		}
		return int.tryParse(value?.toString() ?? '') ?? 0;
	}

	static DateTime _toDateTime(dynamic value) {
		if (value is Timestamp) {
			return value.toDate();
		}
		if (value is DateTime) {
			return value;
		}
		return DateTime.tryParse(value?.toString() ?? '') ?? DateTime(2000);
	}
}
