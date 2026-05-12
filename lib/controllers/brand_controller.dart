import 'package:flutter/material.dart';
import '../data/models/brand_model.dart';
import '../data/services/brand_service.dart';
import '../data/services/category_service.dart';
import '../data/models/category_model.dart';

class BrandController extends ChangeNotifier {
  final BrandService _service = BrandService();
  List<BrandModel> brands = [];
  List<BrandModel> filtered = [];
  bool isLoading = false;
  int currentPage = 1;
  int rowsPerPage = 5;
  Future<void> fetchBrands() async {
    isLoading = true;
    notifyListeners();
    brands = await _service.getBrands();
    filtered = brands;
    isLoading = false;
    notifyListeners();
  }

  void search(String keyword) {
    currentPage = 1;
    if (keyword.isEmpty) {
      filtered = brands;
    } else {
      filtered = brands
          .where((b) => b.name.toLowerCase().contains(keyword.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }

  List<BrandModel> get paginatedData {
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

  Future<void> add(BrandModel brand) async {
    final id = await _service.addBrand(brand);
    await _service.saveBrandCategories(id, selectedCategoryIds);
    await loadBrands();
  }

  Future<void> update(BrandModel brand) async {
    await _service.updateBrand(brand);
    await fetchBrands();
  }

  Future<void> delete(String id) async {
    await _service.deleteBrand(id);
    await fetchBrands();
  }

  List<String> selectedCategoryIds = [];
  Future<void> loadBrandCategories(String brandId) async {
    selectedCategoryIds = await _service.getCategoriesOfBrand(brandId);
    notifyListeners();
  }

  Future<void> saveRelations(String brandId) async {
    await _service.saveBrandCategories(brandId, selectedCategoryIds);
  }

  final CategoryService _categoryService = CategoryService();
  List<CategoryModel> allCategories = [];
  Future<void> fetchAllCategories() async {
    allCategories = await _categoryService.getCategories();
    notifyListeners();
  }

  Map<String, List<String>> brandCategoriesMap = {};
  Future<void> loadBrands() async {
    isLoading = true;
    notifyListeners();
    brands = await _service.getAllBrands();
    final relations = await _service.getAllBrandCategoryRelations();
    final categories = await _service.getAllCategories();
    final categoryMap = {for (var c in categories) c.id: c.name};
    brandCategoriesMap.clear();
    for (var relation in relations) {
      brandCategoriesMap.putIfAbsent(relation.brandId, () => []);
      final categoryName = categoryMap[relation.categoryId];
      if (categoryName != null) {
        brandCategoriesMap[relation.brandId]!.add(categoryName);
      }
    }
    filtered = brands;
    currentPage = 1;
    isLoading = false;
    notifyListeners();
  }
}
