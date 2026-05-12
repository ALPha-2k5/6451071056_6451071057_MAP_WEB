import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/model/order_model.dart';
import '../data/service/order_service.dart';

class OrderController {
  final OrderService _service = OrderService();
  List<OrderModel> orders = [];
  List<OrderModel> filteredOrders = [];

  /// Lấy danh sách đơn hàng và map tên khách hàng từ bảng users
  Future<void> fetchOrders() async {
    orders = await _service.getAllOrders();
    for (var order in orders) {
      final user = await _service.getUserById(order.userId);
      if (user != null) {
        final firstName = user['firstName'] ?? '';
        final lastName = user['lastName'] ?? '';
        order.customerName = "$firstName $lastName".trim();
      } else {
        order.customerName = "Unknown Customer";
      }
    }
    filteredOrders = orders;
  }

  /// Tìm kiếm đơn hàng theo mã hoặc tên khách
  void searchOrder(String keyword) {
    if (keyword.isEmpty) {
      filteredOrders = orders;
    } else {
      final searchLower = keyword.toLowerCase();
      filteredOrders = orders.where((o) {
        return o.id.toLowerCase().contains(searchLower) ||
            o.customerName.toLowerCase().contains(searchLower);
      }).toList();
    }
  }

  /// Xóa đơn hàng
  Future<void> deleteOrder(String docId) async {
    await _service.deleteOrder(docId);
    orders.removeWhere((e) => e.docId == docId);
    filteredOrders = List.from(orders);
  }

  /// Cập nhật trạng thái đơn hàng và gửi thông báo
  Future<void> updateOrderStatus(OrderModel order, String newStatus) async {
    final oldStatus = order.orderStatus.toLowerCase();
    final lowerNewStatus = newStatus.toLowerCase();
    const revertStatuses = ["canceled", "returned", "refunded"];

    // Hoàn kho nếu đơn hàng bị hủy/trả/hoàn tiền
    if (revertStatuses.contains(lowerNewStatus) &&
        !revertStatuses.contains(oldStatus)) {
      await _service.handleOrderRevertStock(order);
    }

    // 1. Cập nhật trạng thái trong database
    await _service.updateOrderStatus(order.docId, newStatus);

    // 2. Tạo thông báo cho khách hàng
    await FirebaseFirestore.instance.collection('notifications').add({
      'userId': order.userId,
      'orderId': order.id,
      'orderStatus': newStatus,
      'message': 'Đơn hàng ${order.id} của bạn đã chuyển sang trạng thái $newStatus',
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Cập nhật local state bằng cách tải lại danh sách đơn
    // (order.orderStatus là final trong model nên không thể gán trực tiếp)
    await fetchOrders();
  }

  /// Cập nhật thông tin giao dịch/thanh toán
  Future<void> updateTransaction({
    required OrderModel order,
    required double amountReceived,
    required DateTime? shippingDate,
    required String paymentStatus,
  }) async {
    String finalStatus = paymentStatus;

    // Tự động chuyển thành 'paid' nếu nhận đủ hoặc dư tiền
    if (amountReceived >= order.totalAmount) {
      finalStatus = "paid";
    }

    await _service.updateTransaction(
      docId: order.docId,
      paymentStatus: finalStatus,
      shippingDate: shippingDate,
      amountCaptured: amountReceived,
    );
  }
}