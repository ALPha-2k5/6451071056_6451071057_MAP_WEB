import 'package:flutter/material.dart';

import '../data/model/customer_model.dart';
import '../data/service/customer_service.dart';

class CustomerController extends ChangeNotifier {
  CustomerController({CustomerService? service})
    : _service = service ?? CustomerService();

  final CustomerService _service;

  final List<CustomerModel> _allCustomers = [];
  List<CustomerModel> filteredData = [];
  Map<String, int> orderCountMap = {};

  bool isLoading = false;
  int currentPage = 1;
  int rowsPerPage = 10;

  int get totalPages {
    if (filteredData.isEmpty) {
      return 1;
    }
    return (filteredData.length / rowsPerPage).ceil();
  }

  List<CustomerModel> get paginatedData {
    if (filteredData.isEmpty) {
      return [];
    }

    final start = (currentPage - 1) * rowsPerPage;
    if (start >= filteredData.length) {
      return [];
    }

    final end = (start + rowsPerPage).clamp(0, filteredData.length);
    return filteredData.sublist(start, end);
  }

  Future<void> fetchCustomers() async {
    isLoading = true;
    notifyListeners();

    try {
      final customers = await _service.getCustomers();
      _allCustomers
        ..clear()
        ..addAll(customers);
      filteredData = List<CustomerModel>.from(_allCustomers);
      currentPage = 1;
      await _loadOrderCounts();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadOrderCounts() async {
    final futures = _allCustomers.map((customer) async {
      final count = await _service.getOrdersCount(customer.id);
      return MapEntry(customer.id, count);
    });

    final entries = await Future.wait(futures);
    orderCountMap = {for (final entry in entries) entry.key: entry.value};
  }

  void search(String keyword) {
    final q = keyword.trim().toLowerCase();

    if (q.isEmpty) {
      filteredData = List<CustomerModel>.from(_allCustomers);
    } else {
      filteredData = _allCustomers.where((c) {
        final fullName = '${c.firstName} ${c.lastName}'.toLowerCase();
        return fullName.contains(q) ||
            c.email.toLowerCase().contains(q) ||
            c.phone.toLowerCase().contains(q);
      }).toList();
    }

    currentPage = 1;
    notifyListeners();
  }

  void changePage(int page) {
    if (page < 1 || page > totalPages || page == currentPage) {
      return;
    }
    currentPage = page;
    notifyListeners();
  }

  Future<void> delete(String id) async {
    await _service.deleteCustomer(id);
    _allCustomers.removeWhere((c) => c.id == id);
    filteredData.removeWhere((c) => c.id == id);
    orderCountMap.remove(id);

    if (currentPage > totalPages) {
      currentPage = totalPages;
    }

    notifyListeners();
  }
}