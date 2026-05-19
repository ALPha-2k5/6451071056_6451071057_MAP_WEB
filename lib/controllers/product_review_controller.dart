import 'dart:async';
import 'package:flutter/material.dart';
import '../data/models/product_review_model.dart';
import '../data/models/customer_model.dart';
import '../data/services/product_review_service.dart';
import '../data/services/customer_service.dart';

class ReviewController extends ChangeNotifier {
  final ReviewService reviewService = ReviewService();
  final CustomerService customerService = CustomerService();
  StreamSubscription? _subscription;
  List<ReviewModel> allReviews = [];
  List<ReviewModel> filteredReviews = [];
  Map<String, CustomerModel> customerCache = {};
  ReviewController() {
    _listenReviews();
  }
  void _listenReviews() {
    _subscription = reviewService.getAll().listen((data) {
      allReviews = data;
      filteredReviews = data;
      notifyListeners();
    });
  }

  /// SEARCH
  void search(String keyword) {
    if (keyword.isEmpty) {
      filteredReviews = allReviews;
    } else {
      filteredReviews = allReviews.where((e) {
        return e.title.toLowerCase().contains(keyword.toLowerCase()) ||
            e.productName.toLowerCase().contains(keyword.toLowerCase());
      }).toList();
    }
    notifyListeners();
  }

  /// GET CUSTOMER FULLNAME
  Future<String> getCustomerName(String userId) async {
    if (customerCache.containsKey(userId)) {
      return customerCache[userId]!.fullName;
    }
    final customer = await customerService.getById(userId);
    if (customer != null) {
      customerCache[userId] = customer;
      return customer.fullName;
    }
    return "Unknown";
  }

  Future<void> delete(String id) async {
    await reviewService.delete(id);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  String statusFilter = "all";
  void filterByStatus(String value) {
    statusFilter = value;
    if (value == "all") {
      filteredReviews = allReviews;
    } else if (value == "pending") {
      filteredReviews = allReviews.where((e) => e.isApproved == false).toList();
    } else {
      filteredReviews = allReviews.where((e) => e.isApproved == true).toList();
    }
    notifyListeners();
  }

  Future<void> approve(ReviewModel review) async {
    await reviewService.approveAndUpdateProduct(review);
  }
}
