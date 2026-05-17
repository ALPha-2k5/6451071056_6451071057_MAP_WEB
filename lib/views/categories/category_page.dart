import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/category_controller.dart';
import '../../data/models/category_model.dart';

class CategoriesPage extends StatelessWidget {
  const CategoriesPage({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      body: _CategoriesView(),
    );
  }
}

class _CategoriesView extends StatelessWidget {
  const _CategoriesView();
  @override
  Widget build(BuildContext context) {
    final controller = context.watch<CategoryController>();
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Product Categories",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3436),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _showDialog(context),
                icon: const Icon(Icons.add, size: 18),
                label: const Text("ADD CATEGORY"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigoAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Search Bar Section
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
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
              onChanged: controller.search,
              decoration: const InputDecoration(
                hintText: "Search categories by name...",
                prefixIcon: Icon(Icons.search, color: Colors.grey),
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Table Content
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 15,
                  ),
                ],
              ),
              child: controller.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: SingleChildScrollView(
                        child: DataTable(
                          showCheckboxColumn: false,
                          headingRowColor: MaterialStateProperty.all(
                            const Color(0xFFF1F3F5),
                          ),
                          dataRowHeight: 70,
                          horizontalMargin: 20,
                          columns: const [
                            DataColumn(
                              label: Text(
                                "SEQ",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                "CATEGORY",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                "FEATURED",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                "STATUS",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                "UPDATED",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                "ACTIONS",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                          rows: controller.paginatedData.asMap().entries.map((
                            entry,
                          ) {
                            final index = entry.key;
                            final c = entry.value;
                            return DataRow(
                              // Hiệu ứng rê chuột (Hover) mặc định củaFlutter DataTable
                              onSelectChanged: (selected) {},
                              cells: [
                                DataCell(
                                  Text(
                                    "${(controller.currentPage - 1) * controller.rowsPerPage + index + 1}",
                                  ),
                                ),
                                DataCell(
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 20,
                                        backgroundColor: Colors.grey[200],
                                        backgroundImage: c.imageURL.isNotEmpty
                                            ? NetworkImage(c.imageURL)
                                            : null,
                                        child: c.imageURL.isEmpty
                                            ? const Icon(Icons.image, size: 20)
                                            : null,
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        c.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                DataCell(
                                  Icon(
                                    c.isFeatured
                                        ? Icons.star_rounded
                                        : Icons.star_outline_rounded,
                                    color: c.isFeatured
                                        ? Colors.amber
                                        : Colors.grey,
                                  ),
                                ),
                                DataCell(_buildStatusBadge(c.isActive)),
                                DataCell(
                                  Text(
                                    c.updatedAt != null
                                        ? "${c.updatedAt!.day.toString().padLeft(2, '0')}/${c.updatedAt!.month.toString().padLeft(2, '0')}/${c.updatedAt!.year}"
                                        : "-",
                                  ),
                                ),
                                DataCell(
                                  Row(
                                    children: [
                                      _buildActionButton(
                                        Icons.edit_outlined,
                                        Colors.blue,
                                        () => _showDialog(context, category: c),
                                      ),
                                      const SizedBox(width: 8),
                                      _buildActionButton(
                                        Icons.delete_outline,
                                        Colors.redAccent,
                                        () => _confirmDelete(context, c.id),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
            ),
          ),
          // Pagination Section
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(controller.totalPages, (index) {
              final page = index + 1;
              final isSelected = controller.currentPage == page;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isSelected
                        ? Colors.indigoAccent
                        : Colors.white,
                    foregroundColor: isSelected ? Colors.white : Colors.black87,
                    elevation: isSelected ? 4 : 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(
                        color: isSelected
                            ? Colors.transparent
                            : Colors.grey[300]!,
                      ),
                    ),
                  ),
                  onPressed: () => controller.changePage(page),
                  child: Text("$page"),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // Widget Badge Trạng thái
  Widget _buildStatusBadge(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isActive
            ? Colors.green.withOpacity(0.1)
            : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive ? Colors.green : Colors.red,
          width: 0.5,
        ),
      ),
      child: Text(
        isActive ? "Active" : "Inactive",
        style: TextStyle(
          color: isActive ? Colors.green[700] : Colors.red[700],
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Widget Nút Action tròn
  Widget _buildActionButton(IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 20, color: color),
      ),
    );
  }

  // Các hàm Dialog giữ nguyên logic nhưng bọc trong UI mới
  void _confirmDelete(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("Confirm Delete"),
        content: const Text("This action cannot be undone. Are you sure?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await context.read<CategoryController>().delete(id);
              Navigator.pop(context);
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  void _showDialog(BuildContext context, {CategoryModel? category}) {
    final nameController = TextEditingController(text: category?.name ?? "");
    final imageController = TextEditingController(
      text: category?.imageURL ?? "",
    );
    bool isActive = category?.isActive ?? true;
    bool isFeatured = category?.isFeatured ?? false;
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(category == null ? "New Category" : " Edit Category"),
          content: SizedBox(
            width: 450,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: "Category Name",
                      prefixIcon: const Icon(Icons.label_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: imageController,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      labelText: "Image URL",
                      prefixIcon: const Icon(Icons.link),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  if (imageController.text.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        imageController.text,
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.broken_image, size: 50),
                      ),
                    ),
                  const SizedBox(height: 10),
                  SwitchListTile(
                    value: isActive,
                    title: const Text("Active Status"),
                    activeColor: Colors.indigoAccent,
                    onChanged: (v) => setState(() => isActive = v),
                  ),
                  SwitchListTile(
                    value: isFeatured,
                    title: const Text("Featured Category"),
                    activeColor: Colors.orange,
                    onChanged: (v) => setState(() => isFeatured = v),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigoAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () async {
                final newCategory = CategoryModel(
                  id: category?.id ?? "",
                  name: nameController.text,
                  imageURL: imageController.text,
                  isActive: isActive,
                  isFeatured: isFeatured,
                  priority: 0,
                  numberOfProducts: 0,
                  viewCount: 0,
                  createdBy: "admin",
                  updatedBy: "admin",
                  createdAt: category?.createdAt ?? DateTime.now(),
                  updatedAt: DateTime.now(),
                );
                if (category == null) {
                  await context.read<CategoryController>().add(newCategory);
                } else {
                  await context.read<CategoryController>().update(newCategory);
                }
                Navigator.pop(context);
              },
              child: const Text(
                "Save Changes",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
