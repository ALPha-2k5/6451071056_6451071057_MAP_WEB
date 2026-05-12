import 'package:flutter/material.dart';
import '../../data/models/order_model.dart';
import '../../controllers/order_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class OrderDetailPage extends StatefulWidget {
  final OrderModel order;
  const OrderDetailPage({super.key, required this.order});

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  final OrderController controller = OrderController();
  String selectedStatus = "";
  Map<String, dynamic>? customerData;

  final List<String> statuses = [
    "Created",
    "Pending",
    "Processing",
    "Shipped",
    "Delivered",
    "Cancelled",
    "Returned",
    "Refunded",
  ];

  @override
  void initState() {
    super.initState();
    selectedStatus = widget.order.orderStatus.capitalize();
    fetchCustomer();
  }

  Future<void> fetchCustomer() async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.order.userId)
        .get();
    if (mounted) {
      setState(() {
        customerData = doc.data();
      });
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'delivered': return Colors.green;
      case 'pending': return Colors.orange;
      case 'processing': return Colors.blue;
      case 'shipped': return Colors.indigo;
      case 'canceled': return Colors.red;
      default: return Colors.blueGrey;
    }
  }

  void _showTransactionDialog(OrderModel order) {
    final amountController = TextEditingController();
    DateTime? selectedDate;
    String statusInDialog = order.paymentStatus;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Cập nhật giao dịch"),
          content: StatefulBuilder(
            builder: (context, setStateDialog) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: statusInDialog,
                    items: ["pending", "paid", "failed"]
                        .map((e) => DropdownMenuItem(
                              value: e,
                              child: Text(e.toUpperCase()),
                            ))
                        .toList(),
                    onChanged: (value) => statusInDialog = value!,
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2023),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setStateDialog(() => selectedDate = picked);
                      }
                    },
                    child: Text(
                      selectedDate == null
                          ? "Chọn ngày giao hàng"
                          : DateFormat('dd/MM/yyyy').format(selectedDate!),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Số tiền đã nhận",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              child: const Text("Huỷ"),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: const Text("Cập nhật"),
              onPressed: () async {
                double amountReceived = double.tryParse(amountController.text) ?? 0;
                await controller.updateTransaction(
                  order: order,
                  amountReceived: amountReceived,
                  shippingDate: selectedDate,
                  paymentStatus: statusInDialog,
                );
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Cập nhật thành công")),
                  );
                  setState(() {});
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          "Chi tiết đơn hàng #${order.id.characters.take(8)}",
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: const BackButton(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// LEFT COLUMN (Main Content)
              Expanded(
                flex: 8,
                child: Column(
                  children: [
                    _buildTopStatusBanner(order),
                    const SizedBox(height: 24),
                    _buildAnimatedFrame(
                      index: 1,
                      title: "Thông tin chung",
                      icon: Icons.info_outline,
                      child: Column(
                        children: [
                          _infoRow("Ngày đặt", DateFormat('dd/MM/yyyy HH:mm').format(order.orderDate)),
                          _infoRow("Số lượng mục", "${order.itemCount} sản phẩm"),
                          _infoRow("Tổng thanh toán", "\$${order.totalAmount.toStringAsFixed(0)}", isPrice: true),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildAnimatedFrame(
                      index: 2,
                      title: "Sản phẩm đã mua",
                      icon: Icons.shopping_bag_outlined,
                      child: Column(
                        children: [
                          _buildProductTable(order),
                          const Divider(height: 32),
                          _summaryRow("Tạm tính", "\$${order.subTotal.toStringAsFixed(0)}"),
                          _summaryRow("Giảm giá Coupon", "-\$${order.couponDiscountAmount}", color: Colors.red),
                          _summaryRow("Phí vận chuyển", "\$${order.shippingAmount}"),
                          _summaryRow("Thuế", "\$${order.taxAmount.toStringAsFixed(0)}"),
                          const Divider(height: 32, thickness: 1),
                          _summaryRow("Tổng cộng", "\$${order.totalAmount.toStringAsFixed(0)}", bold: true),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildAnimatedFrame(
                      index: 3,
                      title: "Giao dịch: (${order.paymentMethod})",
                      icon: Icons.account_balance_wallet_outlined,
                      child: Column(
                        children: [
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton.icon(
                              onPressed: () => _showTransactionDialog(order),
                              icon: const Icon(Icons.edit, size: 16),
                              label: const Text("Cập nhật giao dịch"),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _infoRow(
                            "Trạng thái",
                            order.paymentStatus.toUpperCase(),
                            color: order.paymentStatus == "paid" ? Colors.green : Colors.orange,
                          ),
                          _infoRow("Ngày vận chuyển", order.shippingDate?.toString() ?? "Chưa có thông tin"),
                          _infoRow("Số tiền khớp", order.paymentStatus == "pending" ? "\$0" : "\$${order.totalAmount.toStringAsFixed(0)}"),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),

              /// RIGHT COLUMN (Sidebar)
              Expanded(
                flex: 4,
                child: Column(
                  children: [
                    _buildAnimatedFrame(
                      index: 4,
                      title: "Cập nhật đơn hàng",
                      icon: Icons.edit_note_rounded,
                      child: Column(
                        children: [
                          DropdownButtonFormField<String>(
                            value: selectedStatus,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.grey[100],
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            ),
                            items: statuses.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                            onChanged: (value) => setState(() => selectedStatus = value!),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            height: 45,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                              onPressed: () async {
                                await controller.updateOrderStatus(order, selectedStatus);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Cập nhật trạng thái thành công"), behavior: SnackBarBehavior.floating));
                                }
                              },
                              child: const Text("Cập nhật trạng thái", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildAnimatedFrame(
                      index: 5,
                      title: "Khách hàng",
                      icon: Icons.person_outline_rounded,
                      child: customerData == null
                          ? const Center(child: CircularProgressIndicator())
                          : Row(
                              children: [
                                CircleAvatar(
                                  radius: 25,
                                  backgroundColor: Colors.blue.withOpacity(0.1),
                                  child: Text(customerData!['firstName'][0], style: const TextStyle(fontWeight: FontWeight.bold)),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("${customerData!['firstName']} ${customerData!['lastName']}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                      Text(customerData!['email'], style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                    ),
                    const SizedBox(height: 24),
                    _buildAnimatedFrame(
                      index: 6,
                      title: "Địa chỉ giao hàng",
                      icon: Icons.local_shipping_outlined,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.location_on, color: Colors.redAccent, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "${order.shippingAddress['number']} ${order.shippingAddress['street']}, ${order.shippingAddress['ward']}, ${order.shippingAddress['city']}",
                              style: const TextStyle(height: 1.5, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildAnimatedFrame(
                      index: 7,
                      title: "Lịch sử hoạt động",
                      icon: Icons.history,
                      child: Column(
                        children: [
                          _buildActivityItem(
                            title: "Đơn hàng được khởi tạo",
                            subtitle: "Khách hàng đã đặt đơn thành công",
                            time: DateFormat('dd/MM/yyyy HH:mm').format(order.orderDate),
                            isLast: false,
                            iconColor: Colors.blue,
                          ),
                          _buildActivityItem(
                            title: "Trạng thái: ${order.orderStatus.toUpperCase()}",
                            subtitle: "Cập nhật lần cuối bởi hệ thống",
                            time: DateFormat('dd/MM/yyyy HH:mm').format(order.updatedAt),
                            isLast: true,
                            iconColor: _getStatusColor(order.orderStatus),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Helper Widgets giữ nguyên logic gốc nhưng được format đẹp hơn ---
  Widget _buildActivityItem({required String title, required String subtitle, required String time, required bool isLast, required Color iconColor}) {
    return IntrinsicHeight(
      child: Row(
        children: [
          Column(
            children: [
              Container(
                width: 12, height: 12,
                decoration: BoxDecoration(color: iconColor, shape: BoxShape.circle, border: Border.all(color: iconColor.withOpacity(0.2), width: 3)),
              ),
              if (!isLast) Expanded(child: VerticalDivider(thickness: 2, color: Colors.grey[300])),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                const SizedBox(height: 4),
                Text(time, style: TextStyle(color: Colors.blueGrey[300], fontSize: 11, fontWeight: FontWeight.w500)),
                if (!isLast) const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopStatusBanner(OrderModel order) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.blue.shade800, Colors.blue.shade500]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.shopping_bag, color: Colors.white, size: 40),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("ĐƠN HÀNG: #${order.id.characters.take(8).toString().toUpperCase()}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
              Text("Trạng thái thanh toán: ${order.paymentStatus.toUpperCase()}", style: const TextStyle(color: Colors.white70)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedFrame({required int index, required String title, required IconData icon, required Widget child}) {
    return TweenAnimationBuilder(
      duration: Duration(milliseconds: 400 + (index * 100)),
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, double value, child) => Opacity(opacity: value, child: Transform.translate(offset: Offset(0, 20 * (1 - value)), child: child)),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade200)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [Icon(icon, size: 18, color: Colors.blueAccent), const SizedBox(width: 8), Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15))]),
            const Divider(height: 24),
            child,
          ]),
        ),
      ),
    );
  }

  Widget _buildProductTable(OrderModel order) {
    return DataTable(
      headingRowColor: WidgetStateProperty.all(Colors.grey[50]),
      columnSpacing: 15,
      columns: const [
        DataColumn(label: Text("SẢN PHẨM", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
        DataColumn(label: Text("ĐƠN GIÁ", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
        DataColumn(label: Text("SL", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
        DataColumn(label: Text("TỔNG", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
      ],
      rows: order.products.map<DataRow>((item) {
        return DataRow(cells: [
          DataCell(Row(children: [
            ClipRRect(borderRadius: BorderRadius.circular(6), child: Image.network(item['image'], width: 35, height: 35, fit: BoxFit.cover)),
            const SizedBox(width: 10),
            Expanded(child: Text(item['title'], overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12))),
          ])),
          DataCell(Text("\$${item['price']}")),
          DataCell(Text("x${item['quantity']}")),
          DataCell(Text("\$${(item['price'] * item['quantity'])}", style: const TextStyle(fontWeight: FontWeight.bold))),
        ]);
      }).toList(),
    );
  }

  Widget _infoRow(String title, String value, {Color? color, bool isPrice = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(width: 120, child: Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 13))),
          Expanded(child: Text(value, style: TextStyle(fontWeight: isPrice ? FontWeight.bold : FontWeight.w500, color: color ?? Colors.black87, fontSize: isPrice ? 15 : 13))),
        ],
      ),
    );
  }

  Widget _summaryRow(String title, String value, {bool bold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontWeight: bold ? FontWeight.bold : null, fontSize: bold ? 15 : 13, color: bold ? Colors.black : Colors.grey[700])),
          Text(value, style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.w600, fontSize: bold ? 17 : 13, color: color ?? (bold ? Colors.blue.shade800 : Colors.black87))),
        ],
      ),
    );
  }
}

extension CapExtension on String {
  String capitalize() => isNotEmpty ? "${this[0].toUpperCase()}${substring(1)}" : "";
}
