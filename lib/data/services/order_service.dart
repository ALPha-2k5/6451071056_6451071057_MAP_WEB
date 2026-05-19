import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order_model.dart';

class OrderService {
  final _db = FirebaseFirestore.instance;
  Future<List<OrderModel>> getAllOrders() async {
    final snapshot = await _db
        .collection('orders')
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map((e) => OrderModel.fromFirestore(e)).toList();
  }

  Future<void> deleteOrder(String docId) async {
    await _db.collection('orders').doc(docId).delete();
  }

  Future<Map<String, dynamic>?> getUserById(String userId) async {
    final doc = await _db.collection('users').doc(userId).get();
    return doc.data();
  }

  Future<void> updateOrderStatus(String docId, String newStatus) async {
    await _db.collection('orders').doc(docId).update({
      'orderStatus': newStatus.toLowerCase(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateTransaction({
    required String docId,
    required String paymentStatus,
    required DateTime? shippingDate,
    required double amountCaptured,
  }) async {
    await _db.collection('orders').doc(docId).update({
      'paymentStatus': paymentStatus.toLowerCase(),
      'shippingDate': shippingDate,
      'amountCaptured': amountCaptured,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> handleOrderRevertStock(OrderModel order) async {
    final batch = _db.batch();
    for (var item in order.products) {
      final String productId = item['productId'];
      final int quantity = item['quantity'];
      final productRef = _db.collection('products').doc(productId);
      final productSnap = await productRef.get();
      if (!productSnap.exists) continue;
      final data = productSnap.data()!;
      final int currentSold = data['soldQuantity'] ?? 0;
      final int stock = data['stock'] ?? 0;

      /// ====== REVERT SOLD ======
      int newSold = currentSold - quantity;
      if (newSold < 0) newSold = 0;

      /// ====== FIX LOGIC OUT OF STOCK ======
      bool newOutOfStock;
      if (newSold < stock) {
        newOutOfStock = false;
      } else {
        newOutOfStock = true;
      }
      batch.update(productRef, {
        'soldQuantity': newSold,
        'isOutOfStock': newOutOfStock,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
  }
}
