import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/product_controller.dart';
import '../../data/services/product_service.dart';
import '../../data/models/product_model.dart';
import 'package:intl/intl.dart';
import 'product_form_page.dart';

class ProductListPage extends StatelessWidget {
  const ProductListPage({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF5F7FA),
      body: _ProductListView(),
    );
  }
}

class _ProductListView extends StatelessWidget {
  const _ProductListView();
  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ProductController>();
    final service = ProductService();
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- HEADER ---
          const Text(
            "Kho sản phẩm",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1C1E),
            ),
          ),
          const SizedBox(height: 24),
          // --- TOOLBAR ---
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: "Tìm sản phẩm...",
                      prefixIcon: Icon(Icons.search, color: Colors.blueAccent),
                      border: InputBorder.none,
                    ),
                    onChanged: controller.search,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProductFormPage()),
                ),
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text("THÊM SẢN PHẨM"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 18,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // --- TABLE SECTION (FIXED SCROLL) ---
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                  child: controller.filteredProducts.isEmpty
                    ? const Center(child: Text("Không có sản phẩm"))
                    : Scrollbar(
                        thumbVisibility: true, // Luôn hiện thanh cuộn ngang
                        thickness: 8,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal, // Cuộn ngang
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical, // Cuộn dọc
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(
                                minWidth: 1100,
                              ), // ÉP ĐỘ RỘNG BẢNG ĐỂ HIỆN HẾT CỘT
                              child: DataTable(
                                headingRowColor: WidgetStateProperty.all(
                                  const Color(0xFFF8FAFC),
                                ),
                                columnSpacing:
                                    20, // Thu hẹp khoảng cách giữa các cột
                                columns: const [
                                  DataColumn(label: Text("STT")),
                                  DataColumn(label: Text("SẢN PHẨM")),
                                  DataColumn(label: Text("GIÁ")),
                                  DataColumn(label: Text("LOẠI")),
                                  DataColumn(label: Text("TỒN KHO")),
                                  DataColumn(label: Text("CÒN HÀNG")),
                                  DataColumn(label: Text("HIỂN THỊ")),
                                  DataColumn(label: Text("TRẠNG THÁI")),
                                  DataColumn(label: Text("THAO TÁC")),
                                ],
                                rows: List.generate(
                                  controller.paginatedData.length,
                                  (index) {
                                    final item =
                                        controller.paginatedData[index];
                                    final rowNumber =
                                        controller.rowsPerPage <= 0
                                            ? index + 1
                                            : (controller.currentPage *
                                                    controller.rowsPerPage) +
                                                index +
                                                1;
                                    return DataRow(
                                      cells: [
                                        DataCell(Text("$rowNumber")),
                                        DataCell(
                                          Row(
                                            children: [
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                child: Image.network(
                                                  item.thumbnail,
                                                  width: 40,
                                                  height: 40,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (_, __, ___) =>
                                                      const Icon(
                                                        Icons.image,
                                                        size: 40,
                                                      ),
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              SizedBox(
                                                width: 150,
                                                child: Text(
                                                  item.title,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            "${NumberFormat("#,###").format(item.price)} đ",
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.green,
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Text(_productTypeLabel(
                                            item.productType,
                                          )),
                                        ),
                                        DataCell(_buildStockBadge(item.stock)),
                                        DataCell(
                                          Row(
                                            children: [
                                              Icon(
                                                (item.stock - item.soldQuantity) > 0
                                                    ? Icons.check_circle
                                                    : Icons.cancel,
                                                color: (item.stock - item.soldQuantity) > 0
                                                    ? Colors.green
                                                    : Colors.red,
                                                size: 18,
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                "${item.stock - item.soldQuantity}",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: (item.stock - item.soldQuantity) > 0
                                                      ? Colors.green
                                                      : Colors.red,
                                                ),
                                              ),
                                              if (item.soldQuantity > 0)
                                                Text(
                                                  " (Đã bán ${item.soldQuantity})",
                                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                                ),
                                            ],
                                          ),
                                        ),
                                        DataCell(
                                          _buildVisibilityBadge(item.isDraft),
                                        ),
                                        DataCell(
                                          _buildActiveBadge(item.isActive),
                                        ),
                                        DataCell(
                                          Row(
                                            children: [
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.edit,
                                                  color: Colors.blue,
                                                ),
                                                onPressed: () => Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (_) =>
                                                        ProductFormPage(
                                                          product: item,
                                                        ),
                                                  ),
                                                ),
                                              ),
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.delete,
                                                  color: Colors.red,
                                                ),
                                                onPressed: () =>
                                                    _showDeleteDialog(
                                                      context,
                                                      () => service.delete(
                                                        item.id,
                                                      ),
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // --- PAGINATION ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text("Hiển thị:"),
                  const SizedBox(width: 10),
                  DropdownButton<int>(
                    value: controller.rowsPerPage,
                    items: const [10, 20, 50, 100, 0]
                        .map(
                          (value) => DropdownMenuItem(
                            value: value,
                            child: Text(value == 0 ? "Tất cả" : "$value"),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      controller.setRowsPerPage(value);
                    },
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: controller.rowsPerPage <= 0
                        ? null
                        : controller.previousPage,
                  ),
                  Text(
                    "Trang ${controller.currentPage + 1} / ${controller.totalPages}",
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: controller.rowsPerPage <= 0
                        ? null
                        : controller.nextPage,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStockBadge(int stock) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: stock > 0
            ? Colors.green.withOpacity(0.1)
            : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        "Tồn $stock",
        style: TextStyle(
          color: stock > 0 ? Colors.green : Colors.red,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildVisibilityBadge(bool isDraft) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDraft
            ? Colors.orange.withOpacity(0.1)
            : Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        isDraft ? "Bản nháp" : "Đã đăng",
        style: TextStyle(
          color: isDraft ? Colors.orange : Colors.blue,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildActiveBadge(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isActive
            ? Colors.green.withOpacity(0.1)
            : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        isActive ? "Hoạt động" : "Tạm dừng",
        style: TextStyle(
          color: isActive ? Colors.green : Colors.red,
          fontSize: 12,
        ),
      ),
    );
  }

  String _productTypeLabel(ProductType type) {
    switch (type) {
      case ProductType.simple:
        return "Đơn";
      case ProductType.variable:
        return "Biến thể";
    }
  }
}

Future<void> _showDeleteDialog(BuildContext context, VoidCallback onConfirm) {
  return showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text("Xác nhận xóa"),
      content: const Text("Bạn chắc chắn muốn xóa?"),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Hủy"),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () {
            onConfirm();
            Navigator.pop(context);
          },
          child: const Text("Xóa", style: TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );
}
