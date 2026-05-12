import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/product_controller.dart';
import '../../data/services/product_service.dart';
import 'product_form_page.dart';

class ProductListPage extends StatelessWidget {
  const ProductListPage({super.key});
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProductController(),
      child: const Scaffold(
        backgroundColor: Color(0xFFF5F7FA),
        body: _ProductListView(),
      ),
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
            "Product Inventory",
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
                      hintText: "Search products...",
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
                label: const Text("ADD PRODUCT"),
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
                    ? const Center(child: Text("No products found"))
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
                                  DataColumn(label: Text("SEQ")),
                                  DataColumn(label: Text("PRODUCT")),
                                  DataColumn(label: Text("PRICE")),
                                  DataColumn(label: Text("TYPE")),
                                  DataColumn(label: Text("STOCK")),
                                  DataColumn(
                                    label: Text("CÒN HÀNG"),
                                  ), // 👈 THÊM
                                  DataColumn(label: Text("VISIBLE")),
                                  DataColumn(label: Text("STATUS")),
                                  DataColumn(label: Text("ACTION")),
                                ],
                                rows: List.generate(
                                  controller.paginatedData.length,
                                  (index) {
                                    final item =
                                        controller.paginatedData[index];
                                    return DataRow(
                                      cells: [
                                        DataCell(Text("${index + 1}")),
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
                                            "\$${item.price}",
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.green,
                                            ),
                                          ),
                                        ),
                                        DataCell(Text(item.productType.name)),
                                        DataCell(_buildStockBadge(item.stock)),
                                        DataCell(
                                          Icon(
                                            (item.stock - item.soldQuantity) > 0
                                                ? Icons.check_circle
                                                : Icons.cancel,
                                            color:
                                                (item.stock -
                                                        item.soldQuantity) >
                                                    0
                                                ? Colors.green
                                                : Colors.red,
                                            size: 20,
                                          ),
                                        ),
                                        DataCell(
                                          _buildVisibilityBadge(item.isDraft),
                                        ),
                                        DataCell(
                                          Icon(
                                            item.isActive
                                                ? Icons.check_circle
                                                : Icons.cancel,
                                            color: item.isActive
                                                ? Colors.green
                                                : Colors.red,
                                            size: 20,
                                          ),
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
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: controller.previousPage,
                ),
                Text(
                  "Page ${controller.currentPage + 1} of ${controller.totalPages}",
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: controller.nextPage,
                ),
              ],
            ),
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
        "$stock In Stock",
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
        isDraft ? "Draft" : "Published",
        style: TextStyle(
          color: isDraft ? Colors.orange : Colors.blue,
          fontSize: 12,
        ),
      ),
    );
  }
}

Future<void> _showDeleteDialog(BuildContext context, VoidCallback onConfirm) {
  return showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text("Confirm Delete"),
      content: const Text("Are you sure?"),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () {
            onConfirm();
            Navigator.pop(context);
          },
          child: const Text("Delete", style: TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );
}
