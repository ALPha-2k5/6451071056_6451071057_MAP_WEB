import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../controllers/order_controller.dart';
import '../../data/models/order_model.dart';
import 'order_detail_page.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({super.key});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  final OrderController controller = OrderController();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    setState(() => isLoading = true);
    await controller.fetchOrders();
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  /// LOGIC MÀU SẮC CHO ORDER STATUS
  Color _getOrderStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return Colors.orange;
      case 'processing': return Colors.lightBlue;
      case 'shipped': return Colors.blueAccent;
      case 'delivered': return Colors.green;
      case 'canceled': return Colors.red;
      case 'returned': return Colors.purple;
      case 'refunded': return Colors.blueGrey;
      default: return Colors.grey;
    }
  }

  /// LOGIC MÀU SẮC CHO PAYMENT STATUS
  Color _getPaymentStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid': return Colors.green;
      case 'pending': return Colors.redAccent;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// HEADER
                  const Text(
                    "Order Management",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1C1E),
                    ),
                  ),
                  const SizedBox(height: 24),

                  /// SEARCH & REFRESH
                  Row(
                    children: [
                      _buildSearchBar(),
                      const SizedBox(width: 16),
                      _buildRefreshButton(),
                    ],
                  ),
                  const SizedBox(height: 24),

                  /// DATA TABLE
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              headingRowColor: WidgetStateProperty.all(
                                Colors.grey.withOpacity(0.05),
                              ),
                              dataRowMaxHeight: 75,
                              headingRowHeight: 60,
                              columnSpacing: 35,
                              columns: const [
                                DataColumn(label: _HeaderLabel("Seq")),
                                DataColumn(label: _HeaderLabel("Order ID")),
                                DataColumn(label: _HeaderLabel("Customer")),
                                DataColumn(label: _HeaderLabel("Item")),
                                DataColumn(label: _HeaderLabel("Order Status")),
                                DataColumn(label: _HeaderLabel("Payment")),
                                DataColumn(label: _HeaderLabel("Amount")),
                                DataColumn(label: _HeaderLabel("Date")),
                                DataColumn(label: _HeaderLabel("Action")),
                              ],
                              rows: controller.filteredOrders
                                  .asMap()
                                  .entries
                                  .map((entry) => _buildDataRow(entry.value, entry.key))
                                  .toList(),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  DataRow _buildDataRow(OrderModel order, int index) {
    return DataRow(
      cells: [
        DataCell(Text("${index + 1}")),
        DataCell(
          Text(
            "#${order.id}",
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
          ),
        ),
        DataCell(
          Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: Colors.blue.withOpacity(0.1),
                child: Text(
                  order.customerName.isNotEmpty ? order.customerName[0] : "?",
                  style: const TextStyle(fontSize: 10),
                ),
              ),
              const SizedBox(width: 8),
              Text(order.customerName),
            ],
          ),
        ),
        DataCell(Text("${order.itemCount} sp")),
        DataCell(_buildBadge(order.orderStatus, _getOrderStatusColor(order.orderStatus))),
        DataCell(
          _buildBadge(
            order.paymentStatus,
            _getPaymentStatusColor(order.paymentStatus),
            isOutline: true,
          ),
        ),
        DataCell(
          Text(
            "\$${order.totalAmount.toStringAsFixed(0)}",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        DataCell(Text(DateFormat('dd/MM/yyyy').format(order.orderDate))),
        DataCell(
          Row(
            children: [
              _buildActionIcon(Icons.remove_red_eye, Colors.blue, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => OrderDetailPage(order: order)),
                );
              }),
              const SizedBox(width: 8),
              _buildActionIcon(Icons.delete_sweep, Colors.red, () => _confirmDelete(order)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBadge(String text, Color color, {bool isOutline = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isOutline ? Colors.transparent : color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
        border: isOutline ? Border.all(color: color.withOpacity(0.5)) : null,
      ),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      width: 320,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: TextField(
        onChanged: (v) => setState(() => controller.searchOrder(v)),
        decoration: const InputDecoration(
          icon: Icon(Icons.search, color: Colors.grey),
          hintText: "Tìm mã đơn, tên khách...",
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildRefreshButton() {
    return ElevatedButton.icon(
      onPressed: loadData,
      icon: const Icon(Icons.refresh, size: 18),
      label: const Text("Làm mới"),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.blue,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
        side: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
    );
  }

  Widget _buildActionIcon(IconData icon, Color color, VoidCallback onTap) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(icon, color: color, size: 20),
      constraints: const BoxConstraints(),
      padding: const EdgeInsets.all(8),
      splashRadius: 24,
    );
  }

  void _confirmDelete(OrderModel order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Xác nhận xóa"),
        content: Text("Bạn có chắc chắn muốn xóa đơn hàng #${order.id}?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Hủy"),
          ),
          TextButton(
            onPressed: () async {
              await controller.deleteOrder(order.docId);
              if (mounted) {
                Navigator.pop(context);
                loadData();
              }
            },
            child: const Text("Xóa", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _HeaderLabel extends StatelessWidget {
  final String label;
  const _HeaderLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
    );
  }
}