import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/customer_controller.dart';
import '../../data/models/customer_model.dart';
import 'customer_detail_page.dart';

class CustomersPage extends StatelessWidget {
  const CustomersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CustomerController()..fetchCustomers(),
      child: const Scaffold(
        backgroundColor: Color(0xFFF8F9FD),
        body: _CustomersView(),
      ),
    );
  }
}

class _CustomersView extends StatelessWidget {
  const _CustomersView();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<CustomerController>();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ===== HEADER =====
          const Text(
            "Customer Management",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2B3674),
            ),
          ),
          const SizedBox(height: 20),

          // ===== SEARCH BAR =====
          Container(
            width: 400,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              decoration: const InputDecoration(
                hintText: "Search by name, email or phone...",
                hintStyle: TextStyle(color: Color(0xFFA3AED0), fontSize: 14),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: Color(0xFF4318FF),
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 15),
              ),
              onChanged: (value) => controller.search(value),
            ),
          ),
          const SizedBox(height: 24),

          // ===== TABLE AREA =====
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: controller.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Column(
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: DataTable(
                                  headingRowHeight: 56,
                                  dataRowMaxHeight: 70,
                                  columnSpacing: 32,
                                  headingRowColor: WidgetStateProperty.all(
                                    const Color(0xFFF4F7FE),
                                  ),
                                  columns: const [
                                    DataColumn(label: _TableLabel("SEQ")),
                                    DataColumn(label: _TableLabel("CUSTOMER")),
                                    DataColumn(label: _TableLabel("EMAIL")),
                                    DataColumn(label: _TableLabel("PHONE")),
                                    DataColumn(label: _TableLabel("ORDERS")),
                                    DataColumn(
                                      label: _TableLabel("REGISTER DATE"),
                                    ),
                                    DataColumn(label: _TableLabel("ACTION")),
                                  ],
                                  rows: controller.paginatedData.asMap().entries.map((
                                    entry,
                                  ) {
                                    final index = entry.key;
                                    final c = entry.value;
                                    final seq =
                                        (controller.currentPage - 1) *
                                            controller.rowsPerPage +
                                        index +
                                        1;
                                    return DataRow(
                                      cells: [
                                        DataCell(
                                          Text(
                                            "$seq",
                                            style: const TextStyle(
                                              color: Color(0xFFA3AED0),
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              CircleAvatar(
                                                radius: 16,
                                                backgroundColor: const Color(
                                                  0xFF4318FF,
                                                ).withOpacity(0.1),
                                                child: Text(
                                                  c.firstName.isNotEmpty
                                                      ? c.firstName[0]
                                                            .toUpperCase()
                                                      : "?",
                                                  style: const TextStyle(
                                                    color: Color(0xFF4318FF),
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Text(
                                                "${c.firstName} ${c.lastName}",
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF2B3674),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            c.email,
                                            style: const TextStyle(
                                              color: Color(0xFF1B2559),
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            c.phone,
                                            style: const TextStyle(
                                              color: Color(0xFF1B2559),
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.orange.withOpacity(
                                                0.1,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              "${controller.orderCountMap[c.id] ?? 0}",
                                              style: const TextStyle(
                                                color: Colors.orange,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            c.createdAt != null
                                                ? "${c.createdAt!.day}/${c.createdAt!.month}/${c.createdAt!.year}"
                                                : "-",
                                            style: const TextStyle(
                                              color: Color(0xFFA3AED0),
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              _CircularActionButton(
                                                icon: Icons.visibility_rounded,
                                                color: const Color(0xFF4318FF),
                                                onPressed: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (_) =>
                                                          CustomerDetailPage(
                                                            customer: c,
                                                          ),
                                                    ),
                                                  );
                                                },
                                              ),
                                              const SizedBox(width: 8),
                                              _CircularActionButton(
                                                icon: Icons
                                                    .delete_outline_rounded,
                                                color: Colors.red,
                                                onPressed: () => _confirmDelete(
                                                  context,
                                                  c.id,
                                                ),
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
                        ],
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 24),

          // ===== PAGINATION =====
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(controller.totalPages, (index) {
              final page = index + 1;
              final isCurrent = controller.currentPage == page;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: InkWell(
                  onTap: () => controller.changePage(page),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 38,
                    height: 38,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isCurrent ? const Color(0xFF4318FF) : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: isCurrent
                          ? [
                              BoxShadow(
                                color: const Color(0xFF4318FF).withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : [],
                      border: Border.all(
                        color: isCurrent
                            ? const Color(0xFF4318FF)
                            : const Color(0xFFE0E5F2),
                      ),
                    ),
                    child: Text(
                      "$page",
                      style: TextStyle(
                        color: isCurrent
                            ? Colors.white
                            : const Color(0xFF2B3674),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, String id) {
    final controller = context.read<CustomerController>();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Delete Customer?"),
        content: const Text(
          "This action cannot be undone. Are you sure you want to remove this customer?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () async {
              await controller.delete(id);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

/// --- SUPPORTING WIDGETS ---
class _TableLabel extends StatelessWidget {
  final String label;
  const _TableLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: Color(0xFFA3AED0),
        fontWeight: FontWeight.bold,
        fontSize: 13,
      ),
    );
  }
}

class _CircularActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const _CircularActionButton({
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withOpacity(0.08),
      shape: const CircleBorder(),
      child: IconButton(
        icon: Icon(icon, color: color, size: 18),
        onPressed: onPressed,
        constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
        padding: EdgeInsets.zero,
        hoverColor: color.withOpacity(0.15),
      ),
    );
  }
}
