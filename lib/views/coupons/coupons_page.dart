import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/coupon_controller.dart';
import '../../data/models/coupon_model.dart';

class CouponsPage extends StatelessWidget {
  const CouponsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF8F9FD),
      body: _CouponsView(),
    );
  }
}

class _CouponsView extends StatelessWidget {
  const _CouponsView();
  @override
  Widget build(BuildContext context) {
    final controller = context.watch<CouponController>();
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// --- TOP BAR ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Coupon Management",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2B3674),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _showDialog(context),
                icon: const Icon(Icons.add_rounded),
                label: const Text("ADD COUPON"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4318FF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 18,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          /// --- SEARCH FIELD ---
          Container(
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
              onChanged: controller.search,
              decoration: const InputDecoration(
                hintText: "Search coupon code...",
                prefixIcon: Icon(Icons.search, color: Color(0xFF4318FF)),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 15),
              ),
            ),
          ),
          const SizedBox(height: 24),

          /// --- DATA TABLE AREA ---
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
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            headingRowHeight: 56,
                            dataRowMaxHeight: 64,
                            columnSpacing: 24,
                            headingRowColor: MaterialStateProperty.all(
                              const Color(0xFFF4F7FE),
                            ),
                            columns: const [
                              DataColumn(label: _TableLabel("SEQ")),
                              DataColumn(label: _TableLabel("COUPON")),
                              DataColumn(label: _TableLabel("DISCOUNT VALUE")),
                              DataColumn(label: _TableLabel("TYPE")),
                              DataColumn(label: _TableLabel("DESCRIPTION")),
                              DataColumn(label: _TableLabel("IS ACTIVE")),
                              DataColumn(label: _TableLabel("START DATE")),
                              DataColumn(label: _TableLabel("END DATE")),
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
                                  // SEQ
                                  DataCell(
                                    Text(
                                      "$seq",
                                      style: const TextStyle(
                                        color: Color(0xFFA3AED0),
                                      ),
                                    ),
                                  ),
                                  // COUPON
                                  DataCell(
                                    Text(
                                      c.code,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF2B3674),
                                      ),
                                    ),
                                  ),
                                  // DISCOUNT VALUE
                                  DataCell(
                                    Text(
                                      c.discountType == DiscountType.percentage
                                          ? "${c.discountValue}%"
                                          : "${c.discountValue.toStringAsFixed(0)} đ",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  // TYPE
                                  DataCell(
                                    Text(
                                      c.discountType == DiscountType.percentage
                                          ? "Percentage"
                                          : "Flat",
                                    ),
                                  ),
                                  // DESCRIPTION
                                  DataCell(
                                    SizedBox(
                                      width: 180,
                                      child: Text(
                                        c.description,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Colors.blueGrey,
                                        ),
                                      ),
                                    ),
                                  ),
                                  // IS ACTIVE
                                  DataCell(_StatusBadge(isActive: c.isActive)),
                                  // START DATE
                                  DataCell(
                                    Text(
                                      c.startDate != null
                                          ? "${c.startDate!.day}/${c.startDate!.month}/${c.startDate!.year}"
                                          : "-",
                                    ),
                                  ),
                                  // END DATE
                                  DataCell(
                                    Text(
                                      c.endDate != null
                                          ? "${c.endDate!.day}/${c.endDate!.month}/${c.endDate!.year}"
                                          : "-",
                                    ),
                                  ),
                                  // ACTION
                                  DataCell(
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        _CircularActionButton(
                                          icon: Icons.edit_rounded,
                                          color: Colors.blue,
                                          onPressed: () =>
                                              _showDialog(context, coupon: c),
                                        ),
                                        const SizedBox(width: 8),
                                        _CircularActionButton(
                                          icon: Icons.delete_outline_rounded,
                                          color: Colors.red,
                                          onPressed: () =>
                                              controller.delete(c.id),
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
          ),
        ],
      ),
    );
  }

  void _showDialog(BuildContext context, {CouponModel? coupon}) {
    final controller = context.read<CouponController>();
    final codeController = TextEditingController(text: coupon?.code ?? "");
    final descController = TextEditingController(
      text: coupon?.description ?? "",
    );
    final valueController = TextEditingController(
      text: coupon?.discountValue.toString() ?? "",
    );
    DiscountType type = coupon?.discountType ?? DiscountType.percentage;
    bool isActive = coupon?.isActive ?? true;
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(coupon == null ? "New Coupon" : "Edit Coupon"),
            content: SizedBox(
              width: 400,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildField(controller: codeController, label: "Code"),
                    const SizedBox(height: 12),
                    _buildField(
                      controller: descController,
                      label: "Description",
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<DiscountType>(
                      value: type,
                      decoration: const InputDecoration(
                        labelText: "Discount Type",
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: DiscountType.percentage,
                          child: Text("Percentage"),
                        ),
                        DropdownMenuItem(
                          value: DiscountType.flat,
                          child: Text("Flat"),
                        ),
                      ],
                      onChanged: (v) => setState(() => type = v!),
                    ),
                    const SizedBox(height: 12),
                    _buildField(
                      controller: valueController,
                      label: "Discount Value",
                      isNumber: true,
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      title: const Text(
                        "Is Active",
                        style: TextStyle(fontSize: 14),
                      ),
                      value: isActive,
                      activeColor: const Color(0xFF4318FF),
                      onChanged: (v) => setState(() => isActive = v),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "Cancel",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4318FF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () async {
                  final newCoupon = CouponModel(
                    id: coupon?.id ?? "",
                    code: codeController.text,
                    description: descController.text,
                    discountType: type,
                    discountValue: double.tryParse(valueController.text) ?? 0,
                    startDate: DateTime.now(),
                    endDate: DateTime.now().add(const Duration(days: 7)),
                    usageLimit: 100,
                    usageCount: coupon?.usageCount ?? 0,
                    isActive: isActive,
                    createdAt: coupon?.createdAt ?? DateTime.now(),
                    updateAt: DateTime.now(),
                  );
                  if (coupon == null)
                    await controller.add(newCoupon);
                  else
                    await controller.update(newCoupon);
                  Navigator.pop(context);
                },
                child: const Text(
                  "SAVE",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    bool isNumber = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
      ),
    );
  }
}

/// --- PHẦN TRANG TRÍ RIÊNG ---
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

class _StatusBadge extends StatelessWidget {
  final bool isActive;
  const _StatusBadge({required this.isActive});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isActive
            ? Colors.green.withOpacity(0.1)
            : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        isActive ? "Active" : "Inactive",
        style: TextStyle(
          color: isActive ? Colors.green : Colors.red,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
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
      color: color.withOpacity(0.1),
      shape: const CircleBorder(),
      child: IconButton(
        icon: Icon(icon, color: color, size: 20),
        onPressed: onPressed,
        constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
        padding: EdgeInsets.zero,
      ),
    );
  }
}
