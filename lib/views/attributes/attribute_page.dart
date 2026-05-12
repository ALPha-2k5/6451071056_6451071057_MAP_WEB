import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/attribute_controller.dart';
import '../../data/services/attribute_service.dart';
import 'attribute_add_edit_page.dart';

class AttributesPage extends StatelessWidget {
  const AttributesPage({super.key});
  @override
  Widget build(BuildContext context) {
    final service = AttributeService();
    return ChangeNotifierProvider(
      create: (_) => AttributeController(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF3F4F9), // Nền xám xanh nhẹ hiệnđại
        body: Consumer<AttributeController>(
          builder: (context, controller, _) {
            return StreamBuilder(
              stream: service.getAll(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  controller.setData(snapshot.data!);
                }
                return Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- HEADER ---
                      const Text(
                        "Product Attributes",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1C24),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.03),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: TextField(
                                onChanged: controller.search,
                                decoration: InputDecoration(
                                  hintText: "Search by name or value...",
                                  prefixIcon: const Icon(
                                    Icons.search_rounded,
                                    color: Colors.indigo,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 15,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton.icon(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const AttributeFormPage(),
                              ),
                            ),
                            icon: const Icon(
                              Icons.add_rounded,
                              color: Colors.white,
                            ),
                            label: const Text("NEW ATTRIBUTE"),
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
                      const SizedBox(height: 24),
                      // --- TABLE CONTAINER ---
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: SingleChildScrollView(
                              child: DataTable(
                                headingRowColor: MaterialStateProperty.all(
                                  Colors.indigo.withOpacity(0.05),
                                ),
                                dataRowHeight: 75,
                                horizontalMargin: 24,
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
                                      "ATTRIBUTE",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.indigo,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      "VALUES",
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
                                      "ACTIONS",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.indigo,
                                      ),
                                    ),
                                  ),
                                ],
                                rows: List.generate(controller.paginatedData.length, (
                                  index,
                                ) {
                                  final item = controller.paginatedData[index];
                                  return DataRow(
                                    onSelectChanged:
                                        (_) {}, // Tạo hiệu ứng hover nhẹ
                                    cells: [
                                      DataCell(
                                        Text(
                                          "#${index + 1 + (controller.currentPage * controller.rowsPerPage)}",
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          item.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: Row(
                                            children: item.attributeValues
                                                .map(
                                                  (v) => Container(
                                                    margin:
                                                        const EdgeInsets.only(
                                                          right: 6,
                                                        ),
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 10,
                                                          vertical: 4,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: Colors.blueGrey
                                                          .withOpacity(0.1),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                      border: Border.all(
                                                        color: Colors.blueGrey
                                                            .withOpacity(0.2),
                                                      ),
                                                    ),
                                                    child: Text(
                                                      v,
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.blueGrey,
                                                      ),
                                                    ),
                                                  ),
                                                )
                                                .toList(),
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        _buildStatusBadge(item.isActive),
                                      ),
                                      DataCell(
                                        Text(
                                          item.updatedAt?.toString().substring(
                                                0,
                                                10,
                                              ) ??
                                              "-",
                                        ),
                                      ),
                                      DataCell(
                                        Row(
                                          children: [
                                            _buildActionIcon(
                                              Icons.edit_note_rounded,
                                              Colors.blue,
                                              () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (_) =>
                                                        AttributeFormPage(
                                                          attribute: item,
                                                        ),
                                                  ),
                                                );
                                              },
                                            ),
                                            const SizedBox(width: 8),
                                            _buildActionIcon(
                                              Icons.delete_sweep_rounded,
                                              Colors.redAccent,
                                              () {
                                                _showDeleteDialog(
                                                  context,
                                                  service,
                                                  item.id,
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                                }),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // --- PAGINATION ---
                      _buildPagination(controller),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  // Giao diện Badge Trạng thái
  Widget _buildStatusBadge(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFE3F9E5) : const Color(0xFFFEEBEB),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: isActive ? Colors.green : Colors.red,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            isActive ? "Active" : "Disabled",
            style: TextStyle(
              color: isActive ? Colors.green[800] : Colors.red[800],
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // Nút hành động (Edit/Delete) với hiệu ứng Hover
  Widget _buildActionIcon(IconData icon, Color color, VoidCallback onPressed) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        hoverColor: color.withOpacity(0.1),
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, color: color, size: 22),
        ),
      ),
    );
  }

  // Thanh phân trang thiết kế lại
  Widget _buildPagination(AttributeController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(controller.totalPages, (index) {
        bool isCurrent = controller.currentPage == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          child: InkWell(
            onTap: () => controller.currentPage = index,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isCurrent ? Colors.indigoAccent : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isCurrent ? Colors.indigoAccent : Colors.grey[300]!,
                ),
                boxShadow: isCurrent
                    ? [
                        BoxShadow(
                          color: Colors.indigoAccent.withOpacity(0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [],
              ),
              child: Text(
                "${index + 1}",
                style: TextStyle(
                  color: isCurrent ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    AttributeService service,
    String id,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 10),
            Text("Confirm Delete"),
          ],
        ),
        content: const Text(
          "This attribute will be permanently removed. Continue?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("CANCEL"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () async {
              await service.delete(id);
              Navigator.pop(context);
            },
            child: const Text("DELETE", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
