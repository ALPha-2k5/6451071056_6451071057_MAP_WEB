import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thuchanhweb/controllers/product_review_controller.dart';

class AllReviewScreen extends StatelessWidget {
  const AllReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (BuildContext context) => ReviewController(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA), // Modern light gray background
        body: Consumer<ReviewController>(
          builder: (
            BuildContext context,
            ReviewController controller,
            Widget? child,
          ) {
            return Padding(
              padding: const EdgeInsets.all(30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// --- HEADER SECTION ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Customer Reviews",
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D3436),
                              letterSpacing: 1,
                            ),
                          ),
                          Text(
                            "Manage and moderate your product feedback",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      // Display total review count
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          "Total: ${controller.filteredReviews.length}",
                          style: const TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  /// --- FILTER & SEARCH BAR ---
                  Container(
                    padding: const EdgeInsets.all(16),
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
                    child: Row(
                      children: [
                        // Search Input
                        Expanded(
                          flex: 3,
                          child: TextField(
                            onChanged: controller.search,
                            decoration: InputDecoration(
                              hintText: "Search by product, user or content...",
                              prefixIcon: const Icon(
                                Icons.search,
                                color: Colors.blue,
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 15,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        // Dropdown Filter
                        Expanded(
                          flex: 1,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: controller.statusFilter,
                                icon: const Icon(
                                  Icons.filter_list,
                                  color: Colors.blue,
                                ),
                                isExpanded: true,
                                items: const [
                                  DropdownMenuItem(
                                    value: "all",
                                    child: Text("All Status"),
                                  ),
                                  DropdownMenuItem(
                                    value: "pending",
                                    child: Text("Pending"),
                                  ),
                                  DropdownMenuItem(
                                    value: "approved",
                                    child: Text("Approved"),
                                  ),
                                ],
                                onChanged: (String? value) {
                                  if (value != null) {
                                    controller.filterByStatus(value);
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),

                  /// --- DATA TABLE CARD ---
                  Expanded(
                    child: Container(
                      width: double.infinity,
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
                      child: controller.filteredReviews.isEmpty
                          ? _buildEmptyState()
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.vertical,
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: DataTable(
                                    headingRowHeight: 60,
                                    dataRowHeight: 75,
                                    columnSpacing: 25,
                                    headingRowColor: WidgetStateProperty.all(
                                      Colors.blue.withOpacity(0.05),
                                    ),
                                    columns: _buildTableColumns(),
                                    rows: List.generate(
                                      controller.filteredReviews.length,
                                      (index) => _buildDataRow(
                                        context,
                                        controller,
                                        index,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// Widget shown when no data is found
  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.feedback_outlined, size: 80, color: Colors.grey.shade300),
        const SizedBox(height: 16),
        Text(
          "No reviews found",
          style: TextStyle(
            fontSize: 18,
            color: Colors.grey.shade500,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  /// Define table columns
  List<DataColumn> _buildTableColumns() {
    const TextStyle headerStyle = TextStyle(
      fontWeight: FontWeight.bold,
      color: Color(0xFF444444),
    );
    return const [
      DataColumn(label: Text("SEQ", style: headerStyle)),
      DataColumn(label: Text("PRODUCT", style: headerStyle)),
      DataColumn(label: Text("REVIEW CONTENT", style: headerStyle)),
      DataColumn(label: Text("RATING", style: headerStyle)),
      DataColumn(label: Text("USER", style: headerStyle)),
      DataColumn(label: Text("STATUS", style: headerStyle)),
      DataColumn(label: Text("DATE", style: headerStyle)),
      DataColumn(label: Text("ACTIONS", style: headerStyle)),
    ];
  }

  /// Create data rows
  DataRow _buildDataRow(
    BuildContext context,
    ReviewController controller,
    int index,
  ) {
    final review = controller.filteredReviews[index];
    return DataRow(
      cells: [
        // Sequence Number
        DataCell(
          Text("#${index + 1}", style: const TextStyle(color: Colors.grey)),
        ),
        // Product (Image + Name)
        DataCell(
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    review.productImage,
                    width: 45,
                    height: 45,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.image, size: 20),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 140,
                child: Text(
                  review.productName,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        // Review Content
        DataCell(
          SizedBox(
            width: 220,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  review.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  review.reviewText,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),
        ),
        // Rating Star
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 16),
                const SizedBox(width: 4),
                Text(
                  review.rating.toString(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
          ),
        ),
        // User
        DataCell(
          FutureBuilder<String>(
            future: controller.getCustomerName(review.userId),
            builder: (context, snapshot) {
              return Text(
                snapshot.data ?? "Loading...",
                style: const TextStyle(
                  color: Colors.blueGrey,
                  fontWeight: FontWeight.w500,
                ),
              );
            },
          ),
        ),
        // Status Badge
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: review.isApproved
                  ? const Color(0xFFE3F9E5)
                  : const Color(0xFFFFF4E5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              review.isApproved ? "Approved" : "Pending",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: review.isApproved
                    ? const Color(0xFF1F8B24)
                    : const Color(0xFFD97706),
              ),
            ),
          ),
        ),
        // Date
        DataCell(
          Text(
            "${review.updatedAt.day.toString().padLeft(2, '0')}/${review.updatedAt.month.toString().padLeft(2, '0')}/${review.updatedAt.year}",
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
        ),
        // Action Buttons
        DataCell(
          Row(
            children: [
              if (!review.isApproved)
                _buildActionButton(
                  icon: Icons.check_circle_outline,
                  color: Colors.green,
                  tooltip: "Approve Review",
                  onTap: () => controller.approve(review),
                ),
              const SizedBox(width: 8),
              _buildActionButton(
                icon: Icons.delete_outline,
                color: Colors.redAccent,
                tooltip: "Delete Review",
                onTap: () =>
                    _showDeleteDialog(context, controller, review.id),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Compact action button
  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
      ),
    );
  }

  /// Confirmation dialog for deletion
  Future<void> _showDeleteDialog(
    BuildContext context,
    ReviewController controller,
    String id,
  ) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 10),
            Text("Confirm Delete"),
          ],
        ),
        content: const Text(
          "This action cannot be undone. Do you want to remove this review permanently?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              "Delete Now",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await controller.delete(id);
    }
  }
}