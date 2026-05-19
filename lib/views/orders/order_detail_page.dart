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
  late OrderModel _order;

  static const List<Map<String, String>> statuses = [
    {"value": "created", "label": "Đã tạo"},
    {"value": "pending", "label": "Chờ xử lý"},
    {"value": "processing", "label": "Đang xử lý"},
    {"value": "shipped", "label": "Đang giao"},
    {"value": "delivered", "label": "Đã giao"},
    {"value": "canceled", "label": "Đã hủy"},
    {"value": "returned", "label": "Đã trả hàng"},
    {"value": "refunded", "label": "Hoàn tiền"},
  ];

  @override
  void initState() {
    super.initState();
    _order = widget.order;
    selectedStatus = widget.order.orderStatus.isNotEmpty
      ? widget.order.orderStatus.toLowerCase()
      : statuses.first['value']!;
    fetchCustomer();
  }

  Future<void> _reloadOrder() async {
    if (_order.docId.isEmpty) return;
    final doc = await FirebaseFirestore.instance
        .collection('orders')
        .doc(_order.docId)
        .get();
    if (!doc.exists) return;
    if (!mounted) return;
    final updated = OrderModel.fromFirestore(doc);
    setState(() {
      _order = updated;
      if (updated.orderStatus.isNotEmpty) {
        selectedStatus = updated.orderStatus.toLowerCase();
      }
    });
  }

  Future<void> fetchCustomer() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.order.userId)
          .get();
      if (!mounted) return;
      setState(() {
        customerData = doc.data() ?? {};
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        customerData = {};
      });
    }
  }

  String _money(num value) => NumberFormat("#,###").format(value);

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'processing':
        return Colors.blue;
      case 'shipped':
        return Colors.indigo;
      case 'canceled':
        return Colors.red;
      default:
        return Colors.blueGrey;
    }
  }

  void _showTransactionDialog(OrderModel order) {
    final amountController = TextEditingController();
    DateTime? selectedDate;
    String statusInDialog =
        order.paymentStatus.isNotEmpty ? order.paymentStatus : "pending";

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
                        .map(
                          (e) => DropdownMenuItem(
                            value: e,
                            child:
                                Text(_paymentStatusLabel(e).toUpperCase()),
                          ),
                        )
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
                double amountReceived =
                    double.tryParse(amountController.text) ?? 0;
                await controller.updateTransaction(
                  order: order,
                  amountReceived: amountReceived,
                  shippingDate: selectedDate,
                  paymentStatus: statusInDialog,
                );
                await _reloadOrder();
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
    final order = _order;
    final customerDisplayName = _fullNameFromCustomer(
      customerData,
      fallback: order.customerName,
    );
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          "Chi tiết đơn hàng #${order.id.characters.take(8)}",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
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
                          _infoRow(
                            "Ngày đặt",
                            DateFormat(
                              'dd/MM/yyyy HH:mm',
                            ).format(order.orderDate),
                          ),
                          _infoRow(
                            "Số lượng mục",
                            "${order.itemCount} sản phẩm",
                          ),
                          _infoRow(
                            "Tổng thanh toán",
                            "${_money(order.totalAmount)} đ",
                            isPrice: true,
                          ),
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
                          _summaryRow(
                            "Tạm tính",
                            "${_money(order.subTotal)} đ",
                          ),
                          _summaryRow(
                            "Giảm giá Coupon",
                            "-${_money(order.couponDiscountAmount)} đ",
                            color: Colors.red,
                          ),
                          _summaryRow(
                            "Phí vận chuyển",
                            "${_money(order.shippingAmount)} đ",
                          ),
                          _summaryRow(
                            "Thuế",
                            "${_money(order.taxAmount)} đ",
                          ),
                          const Divider(height: 32, thickness: 1),
                          _summaryRow(
                            "Tổng cộng",
                            "${_money(order.totalAmount)} đ",
                            bold: true,
                          ),
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
                            _paymentStatusLabel(order.paymentStatus)
                                .toUpperCase(),
                            color: order.paymentStatus == "paid"
                                ? Colors.green
                                : Colors.orange,
                          ),
                          _infoRow(
                            "Ngày vận chuyển",
                            order.shippingDate?.toString() ??
                                "Chưa có thông tin",
                          ),
                          _infoRow(
                            "Số tiền khớp",
                            order.paymentStatus == "pending"
                                ? "0 đ"
                                : "${_money(order.totalAmount)} đ",
                          ),
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
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            items: statuses
                                .map(
                                  (s) => DropdownMenuItem(
                                    value: s['value'],
                                    child: Text(s['label'] ?? ""),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) =>
                                setState(() => selectedStatus = value!),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            height: 45,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () async {
                                try {
                                  await controller.updateOrderStatus(
                                    order,
                                    selectedStatus,
                                  );
                                  await _reloadOrder();
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          "Cập nhật trạng thái thành công",
                                        ),
                                        backgroundColor: Colors.green,
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          e.toString().replaceAll('Exception: ', ''),
                                        ),
                                        backgroundColor: Colors.red,
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  }
                                }
                              },
                              child: const Text(
                                "Cập nhật trạng thái",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
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
                                  child: Text(
                                    _initialFromName(customerDisplayName),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        customerDisplayName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text(
                                        _stringField(
                                          customerData?['email'],
                                          fallback: "Chưa có email",
                                        ),
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 13,
                                        ),
                                      ),
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
                          const Icon(
                            Icons.location_on,
                            color: Colors.redAccent,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _shippingAddressText(order.shippingAddress),
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
                            time: DateFormat(
                              'dd/MM/yyyy HH:mm',
                            ).format(order.orderDate),
                            isLast: false,
                            iconColor: Colors.blue,
                          ),
                          _buildActivityItem(
                            title:
                                "Trạng thái: ${_orderStatusLabel(order.orderStatus).toUpperCase()}",
                            subtitle: "Cập nhật lần cuối bởi hệ thống",
                            time: DateFormat(
                              'dd/MM/yyyy HH:mm',
                            ).format(order.updatedAt),
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
  Widget _buildActivityItem({
    required String title,
    required String subtitle,
    required String time,
    required bool isLast,
    required Color iconColor,
  }) {
    return IntrinsicHeight(
      child: Row(
        children: [
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: iconColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: iconColor.withOpacity(0.2),
                    width: 3,
                  ),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: VerticalDivider(thickness: 2, color: Colors.grey[300]),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: TextStyle(
                    color: Colors.blueGrey[300],
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
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
        gradient: LinearGradient(
          colors: [Colors.blue.shade800, Colors.blue.shade500],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.shopping_bag, color: Colors.white, size: 40),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "ĐƠN HÀNG: #${order.id.characters.take(8).toString().toUpperCase()}",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              Text(
                "Trạng thái thanh toán: ${_paymentStatusLabel(order.paymentStatus).toUpperCase()}",
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedFrame({
    required int index,
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return TweenAnimationBuilder(
      duration: Duration(milliseconds: 400 + (index * 100)),
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, double value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: child,
        ),
      ),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 18, color: Colors.blueAccent),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              child,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductTable(OrderModel order) {
    return DataTable(
      headingRowColor: WidgetStateProperty.all(Colors.grey[50]),
      columnSpacing: 15,
      columns: const [
        DataColumn(
          label: Text(
            "SẢN PHẨM",
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ),
        DataColumn(
          label: Text(
            "ĐƠN GIÁ",
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ),
        DataColumn(
          label: Text(
            "SL",
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ),
        DataColumn(
          label: Text(
            "TỔNG",
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ),
      ],
      rows: order.products.map<DataRow>((item) {
        final itemMap = item is Map<String, dynamic>
            ? item
            : <String, dynamic>{};
        final imageUrl = _stringField(itemMap['image']);
        final title = _stringField(itemMap['title'], fallback: "Chưa rõ");
        final price = _numField(itemMap['price']);
        final quantity = _numField(itemMap['quantity']);
        return DataRow(
          cells: [
            DataCell(
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: _productImage(imageUrl),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      title,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            DataCell(Text("${_money(price)} đ")),
            DataCell(Text("x${quantity.toInt()}")),
            DataCell(
              Text(
                "${_money(price * quantity)} đ",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _infoRow(
    String title,
    String value, {
    Color? color,
    bool isPrice = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              title,
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: isPrice ? FontWeight.bold : FontWeight.w500,
                color: color ?? Colors.black87,
                fontSize: isPrice ? 15 : 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(
    String title,
    String value, {
    bool bold = false,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : null,
              fontSize: bold ? 15 : 13,
              color: bold ? Colors.black : Colors.grey[700],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.w600,
              fontSize: bold ? 17 : 13,
              color: color ?? (bold ? Colors.blue.shade800 : Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}

String _stringField(dynamic value, {String fallback = ""}) {
  if (value == null) return fallback;
  if (value is String) return value;
  if (value is num || value is bool) return value.toString();
  return fallback;
}

num _numField(dynamic value, {num fallback = 0}) {
  if (value == null) return fallback;
  if (value is num) return value;
  if (value is String) return num.tryParse(value) ?? fallback;
  return fallback;
}

String _initialFromName(String name) {
  final trimmed = name.trim();
  if (trimmed.isEmpty) return "?";
  return trimmed[0].toUpperCase();
}

String _fullNameFromCustomer(
  Map<String, dynamic>? customer, {
  String fallback = "",
}) {
  final firstName = _stringField(customer?['firstName']);
  final lastName = _stringField(customer?['lastName']);
  final fullNameParts = "$firstName $lastName".trim();
  final fullName = _stringField(customer?['fullName']);
  final name = _stringField(customer?['name']);
  final displayName = _stringField(customer?['displayName']);
  final username = _stringField(customer?['username']);

  final candidates = <String>[
    fullNameParts,
    fullName,
    name,
    displayName,
    username,
    fallback,
  ].where((value) => value.trim().isNotEmpty);

  return candidates.isNotEmpty ? candidates.first : "Khách hàng";
}

String _shippingAddressText(Map<String, dynamic> address) {
  final parts = [
    _stringField(address['number']),
    _stringField(address['street']),
    _stringField(address['ward']),
    _stringField(address['city']),
  ].where((part) => part.trim().isNotEmpty).toList();

  if (parts.isEmpty) return "Chưa có thông tin";
  return parts.join(", ");
}

String _orderStatusLabel(String status) {
  final normalized = status.toLowerCase();
  const labels = {
    "created": "Đã tạo",
    "pending": "Chờ xử lý",
    "processing": "Đang xử lý",
    "shipped": "Đang giao",
    "delivered": "Đã giao",
    "canceled": "Đã hủy",
    "cancelled": "Đã hủy",
    "returned": "Đã trả hàng",
    "refunded": "Hoàn tiền",
  };
  return labels[normalized] ?? status;
}

String _paymentStatusLabel(String status) {
  final normalized = status.toLowerCase();
  const labels = {
    "pending": "Chờ thanh toán",
    "paid": "Đã thanh toán",
    "failed": "Thất bại",
  };
  return labels[normalized] ?? status;
}

Widget _productImage(String imageUrl) {
  if (imageUrl.isEmpty) {
    return Container(
      width: 35,
      height: 35,
      color: Colors.grey.shade200,
      child: const Icon(Icons.image_not_supported, size: 18),
    );
  }

  return Image.network(
    imageUrl,
    width: 35,
    height: 35,
    fit: BoxFit.cover,
    errorBuilder: (context, error, stackTrace) {
      return Container(
        width: 35,
        height: 35,
        color: Colors.grey.shade200,
        child: const Icon(Icons.broken_image, size: 18),
      );
    },
  );
}

extension CapExtension on String {
  String capitalize() =>
      isNotEmpty ? "${this[0].toUpperCase()}${substring(1)}" : "";
}
