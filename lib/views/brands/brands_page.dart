import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/brand_controller.dart';
import '../../data/models/brand_model.dart';

class BrandsPage extends StatelessWidget {
  const BrandsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BrandController()..loadBrands(),
      child: const Scaffold(
        backgroundColor: Color(0xFFF8F9FD), // Nền xám nhạt hiện đại
        body: _BrandsView(),
      ),
    );
  }
}

class _BrandsView extends StatelessWidget {
  const _BrandsView();
  @override
  Widget build(BuildContext context) {
    final controller = context.watch<BrandController>();
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- HEADER SECTION ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Brand Management",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  Text(
                    "Manage your product partners and labels",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => _showDialog(context),
                icon: const Icon(
                  Icons.add_business_rounded,
                  color: Colors.white,
                ),
                label: const Text("ADD NEW BRAND"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigoAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 20,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          // --- SEARCH BAR ---
          Container(
            width: 400,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              decoration: const InputDecoration(
                hintText: "Search brands...",
                prefixIcon: Icon(Icons.search_rounded, color: Colors.indigo),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 15),
              ),
              onChanged: controller.search,
            ),
          ),
          const SizedBox(height: 24),
          // --- TABLE SECTION ---
          controller.isLoading
              ? const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                )
              : Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.withOpacity(0.2)),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: SingleChildScrollView(
                        child: DataTable(
                          headingRowColor: MaterialStateProperty.all(
                            Colors.indigo.withOpacity(0.05),
                          ),
                          dataRowHeight: 70,
                          horizontalMargin: 20,
                          columns: const [
                            DataColumn(
                              label: Text(
                                "SEQ",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.indigo,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                "BRAND",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.indigo,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                "CATEGORIES",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.indigo,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                "FEATURED",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.indigo,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                "STATUS",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.indigo,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                "UPDATED",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.indigo,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                "ACTION",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.indigo,
                                ),
                              ),
                            ),
                          ],
                          rows: controller.paginatedData.asMap().entries.map((
                            entry,
                          ) {
                            final index = entry.key;
                            final b = entry.value;
                            return DataRow(
                              cells: [
                                DataCell(
                                  Text(
                                    "${(controller.currentPage - 1) * controller.rowsPerPage + index + 1}",
                                  ),
                                ),
                                DataCell(
                                  Row(
                                    children: [
                                      Container(
                                        width: 45,
                                        height: 45,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          color: Colors.grey[100],
                                          image: b.imageURL.isNotEmpty
                                              ? DecorationImage(
                                                  image: NetworkImage(
                                                    b.imageURL,
                                                  ),
                                                  fit: BoxFit.cover,
                                                )
                                              : null,
                                        ),
                                        child: b.imageURL.isEmpty
                                            ? const Icon(Icons.business)
                                            : null,
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        b.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                DataCell(
                                  SizedBox(
                                    width: 180,
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        children:
                                            (controller.brandCategoriesMap[b
                                                        .id] ??
                                                    [])
                                                .map(
                                                  (cat) => Container(
                                                    margin:
                                                        const EdgeInsets.only(
                                                          right: 4,
                                                        ),
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 8,
                                                          vertical: 4,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: Colors.blue
                                                          .withOpacity(0.1),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            6,
                                                          ),
                                                    ),
                                                    child: Text(
                                                      cat,
                                                      style: const TextStyle(
                                                        fontSize: 11,
                                                        color: Colors.blue,
                                                      ),
                                                    ),
                                                  ),
                                                )
                                                .toList(),
                                      ),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Icon(
                                    b.isFeatured
                                        ? Icons.stars_rounded
                                        : Icons.star_outline_rounded,
                                    color: b.isFeatured
                                        ? Colors.amber
                                        : Colors.grey[400],
                                  ),
                                ),
                                DataCell(_buildStatusBadge(b.isActive)),
                                DataCell(
                                  Text(
                                    b.updatedAt != null
                                        ? "${b.updatedAt!.day}/${b.updatedAt!.month}/${b.updatedAt!.year}"
                                        : "-",
                                  ),
                                ),
                                DataCell(
                                  Row(
                                    children: [
                                      _buildIconButton(
                                        Icons.edit_outlined,
                                        Colors.blue,
                                        () => _showDialog(context, brand: b),
                                      ),
                                      const SizedBox(width: 8),
                                      _buildIconButton(
                                        Icons.delete_outline_rounded,
                                        Colors.red,
                                        () => _confirmDelete(context, b.id),
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
          const SizedBox(height: 20),
          // --- PAGINATION ---
          _buildPagination(controller),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isActive
            ? Colors.green.withOpacity(0.1)
            : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isActive ? "Active" : "Inactive",
        style: TextStyle(
          color: isActive ? Colors.green : Colors.red,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildIconButton(IconData icon, Color color, VoidCallback onTap) {
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

  Widget _buildPagination(BrandController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(controller.totalPages, (index) {
        final page = index + 1;
        bool isCurrent = controller.currentPage == page;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: InkWell(
            onTap: () => controller.changePage(page),
            child: Container(
              width: 35,
              height: 35,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isCurrent ? Colors.indigo : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isCurrent ? Colors.indigo : Colors.grey[300]!,
                ),
              ),
              child: Text(
                "$page",
                style: TextStyle(
                  color: isCurrent ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  void _confirmDelete(BuildContext context, String id) {
    final controller = context.read<BrandController>();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Delete Brand?"),
        content: const Text("This action cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("CANCEL"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await controller.delete(id);
              Navigator.pop(context);
            },
            child: const Text("DELETE", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showDialog(BuildContext context, {BrandModel? brand}) async {
    final controller = context.read<BrandController>();
    await controller.fetchAllCategories();
    if (brand != null) {
      await controller.loadBrandCategories(brand.id);
    } else {
      controller.selectedCategoryIds = [];
    }
    final nameController = TextEditingController(text: brand?.name ?? "");
    final imageController = TextEditingController(text: brand?.imageURL ?? "");
    bool isActive = brand?.isActive ?? true;
    bool isFeatured = brand?.isFeatured ?? false;
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(brand == null ? "✨ New Brand" : "📝 Edit Brand"),
            content: SizedBox(
              width: 550,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: "Brand Name",
                        prefixIcon: const Icon(Icons.label_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: imageController,
                      decoration: InputDecoration(
                        labelText: "Logo URL",
                        prefixIcon: const Icon(Icons.image_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 16),
                    if (imageController.text.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          imageController.text,
                          height: 100,
                          width: 100,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                                Icons.broken_image,
                                size: 50,
                                color: Colors.grey,
                              ),
                        ),
                      ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: SwitchListTile(
                            title: const Text("Active"),
                            value: isActive,
                            onChanged: (v) => setState(() => isActive = v),
                          ),
                        ),
                        Expanded(
                          child: SwitchListTile(
                            title: const Text("Featured"),
                            value: isFeatured,
                            onChanged: (v) => setState(() => isFeatured = v),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 32),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Categories Management",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: ListView(
                        padding: const EdgeInsets.all(8),
                        children: controller.allCategories.map((cat) {
                          final isSelected = controller.selectedCategoryIds
                              .contains(cat.id);
                          return CheckboxListTile(
                            value: isSelected,
                            title: Text(cat.name),
                            controlAffinity: ListTileControlAffinity.leading,
                            onChanged: (checked) {
                              setState(() {
                                if (checked == true) {
                                  controller.selectedCategoryIds.add(cat.id);
                                } else {
                                  controller.selectedCategoryIds.remove(cat.id);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("CANCEL"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () async {
                  final newBrand = BrandModel(
                    id: brand?.id ?? "",
                    name: nameController.text,
                    imageURL: imageController.text,
                    isFeatured: isFeatured,
                    isActive: isActive,
                    productsCount: brand?.productsCount ?? 0,
                    viewCount: brand?.viewCount ?? 0,
                    createdAt: brand?.createdAt ?? DateTime.now(),
                    updatedAt: DateTime.now(),
                  );
                  if (brand == null)
                    await controller.add(newBrand);
                  else
                    await controller.update(newBrand);
                  if (brand != null) await controller.saveRelations(brand.id);
                  Navigator.pop(context);
                },
                child: const Text(
                  "SAVE BRAND",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
