import 'package:flutter/material.dart';

class Sidebar extends StatefulWidget {
  final Function(String) onNavigate;
  final String currentRoute;
  const Sidebar({
    super.key,
    required this.onNavigate,
    this.currentRoute = '/dashboard',
  });
  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2D), // Slate Navy chuyên nghiệp
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          /// LOGO SECTION
          Container(
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blueAccent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.bolt, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                const Flexible(
                  child: Text(
                    "SHOE ADMIN",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Divider(color: Colors.white10, thickness: 1),
          ),
          const SizedBox(height: 10),

          /// MENU ITEMS
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _buildSectionTitle("MAIN MENU"),
                _item(
                  Icons.dashboard_outlined,
                  "Bảng điều khiển",
                  "/dashboard",
                ),
                _item(Icons.category, "Danh mục sản phẩm", "/categories"),
                _item(
                  Icons.info_outline,
                  "Danh mục thuộc tính sản phẩm",
                  "/attributes",
                ),
                _item(
                  Icons.branding_watermark_outlined,
                  "Danh mục thương hiệu",
                  "/brands",
                ),
                _item(Icons.card_giftcard, "Danh mục mã giảm giá", "/coupons"),
                _item(Icons.inventory_2_outlined, "Sản phẩm", "/products"),
                _buildSectionTitle("SALES"),
                _item(Icons.shopping_cart_outlined, "Đơn hàng", "/orders"),
                _item(Icons.people_outline, "Khách hàng", "/customers"),
                _item(Icons.star_rate_outlined, "Đánh giá", "/reviews"),
                _buildSectionTitle("SYSTEM"),
                _item(Icons.settings_outlined, "Cài đặt cá nhân", "/settings"),
              ],
            ),
          ),

          /// FOOTER
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              "v1.0.2",
              style: TextStyle(color: Colors.white24, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  /// Widget tiêu đề nhóm menu
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 20, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white38,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  /// Widget Item Menu với hiệu ứng Hover và Active
  Widget _item(IconData icon, String title, String route) {
    final bool isActive = widget.currentRoute == route;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: InkWell(
        onTap: () => widget.onNavigate(route),
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isActive
                ? Colors.blueAccent.withOpacity(0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: isActive
                ? const Border(
                    left: BorderSide(color: Colors.blueAccent, width: 4),
                  )
                : null,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isActive ? Colors.blueAccent : Colors.white60,
                size: 22,
              ),
              const SizedBox(width: 15),
              // FIX LỖI OVERFLOW Ở ĐÂY: Dùng Expanded để Text không đẩyRow ra ngoài
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: isActive ? Colors.white : Colors.white60,
                    fontSize: 15,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis, // Hiện dấu ... nếu quá dài
                ),
              ),
              if (isActive) ...[
                const SizedBox(width: 10),
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Colors.blueAccent,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
