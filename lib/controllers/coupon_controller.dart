import 'package:flutter/material.dart';
import '../data/models/coupon_model.dart';
import '../data/services/coupon_service.dart';

class CouponController extends ChangeNotifier {
  final CouponService _service = CouponService();
  List<CouponModel> coupons = [];
  List<CouponModel> filtered = [];
  bool isLoading = false;
  int currentPage = 1;
  int rowsPerPage = 5;
  Future<void> fetchCoupons() async {
    isLoading = true;
    notifyListeners();
    coupons = await _service.getCoupons();
    filtered = coupons;
    isLoading = false;
    notifyListeners();
  }

  void search(String keyword) {
    currentPage = 1;
    if (keyword.isEmpty) {
      filtered = coupons;
    } else {
      filtered = coupons
          .where((c) => c.code.toLowerCase().contains(keyword.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }

  List<CouponModel> get paginatedData {
    final start = (currentPage - 1) * rowsPerPage;
    final end = start + rowsPerPage;
    return filtered.sublist(
      start,
      end > filtered.length ? filtered.length : end,
    );
  }

  int get totalPages => (filtered.length / rowsPerPage).ceil();
  void changePage(int page) {
    currentPage = page;
    notifyListeners();
  }

  Future<void> add(CouponModel coupon) async {
    await _service.addCoupon(coupon);
    await fetchCoupons();
  }

  Future<void> update(CouponModel coupon) async {
    await _service.updateCoupon(coupon);
    await fetchCoupons();
  }

  Future<void> delete(String id) async {
    await _service.deleteCoupon(id);
    await fetchCoupons();
  }
}
