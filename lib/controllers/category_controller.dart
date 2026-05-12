import 'package:flutter/material.dart';
import '../data/models/category_model.dart';
import '../data/services/category_service.dart';

class CategoryController extends ChangeNotifier {
  final CategoryService _service = CategoryService();
  List<CategoryModel> categories = [];
  List<CategoryModel> filtered = [];
  bool isLoading = false;
  Future<void> fetchCategories() async {
    isLoading = true;
    notifyListeners();
    categories = await _service.getCategories();
    filtered = categories;
    isLoading = false;
    notifyListeners();
  }

  void search(String keyword) {
    if (keyword.isEmpty) {
      filtered = categories;
    } else {
      filtered = categories
          .where((c) => c.name.toLowerCase().contains(keyword.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }

  Future<void> add(CategoryModel category) async {
    await _service.addCategory(category);
    await fetchCategories();
  }

  Future<void> update(CategoryModel category) async {
    await _service.updateCategory(category);
    await fetchCategories();
  }

  Future<void> delete(String id) async {
    await _service.deleteCategory(id);
    await fetchCategories();
  }

  int currentPage = 1;
  int rowsPerPage = 5;
  List<CategoryModel> get paginatedData {
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
}
