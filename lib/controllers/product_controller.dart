import 'package:flutter/material.dart';
import '../data/models/product_model.dart';
import '../data/models/brand_model.dart';
import '../data/models/category_model.dart';
import '../data/models/attribute_model.dart';
import '../data/services/product_service.dart';
import '../data/services/brand_service.dart';
import '../data/services/category_service.dart';
import '../data/services/attribute_service.dart';
import 'dart:async';

class ProductController extends ChangeNotifier {
  final ProductService productService = ProductService();
  final BrandService brandService = BrandService();
  final CategoryService categoryService = CategoryService();
  final AttributeService attributeService = AttributeService();
  StreamSubscription? _subscription;
  List<BrandModel> brands = [];
  List<CategoryModel> categories = [];
  List<AttributeModel> attributes = [];
  Future<void> loadInitialData() async {
    brands = await brandService.getAllBrands();
    categories = await categoryService.getCategories();
    attributes = await attributeService.getAll().first;
    notifyListeners();
  }

  Future<void> save(ProductModel model, {bool isUpdate = false}) async {
    if (isUpdate) {
      await productService.update(model);
    } else {
      await productService.create(model);
    }
  }

  List<ProductModel> allProducts = [];
  List<ProductModel> filteredProducts = [];
  int currentPage = 0;
  int rowsPerPage = 10;
  void setData(List<ProductModel> data) {
    if (allProducts.length == data.length) return;
    allProducts = data.where((e) => e.isDeleted == false).toList();
    filteredProducts = allProducts;
    notifyListeners();
  }

  ProductController() {
    _listenProducts();
  }
  void _listenProducts() {
    _subscription = productService.getAll().listen((data) {
      allProducts = data.where((e) => !e.isDeleted).toList();
      filteredProducts = allProducts;
      notifyListeners();
    });
  }

  void search(String keyword) {
    if (keyword.isEmpty) {
      filteredProducts = allProducts;
    } else {
      filteredProducts = allProducts
          .where((e) => e.title.toLowerCase().contains(keyword.toLowerCase()))
          .toList();
    }
    currentPage = 0;
    notifyListeners();
  }

  List<ProductModel> get paginatedData {
    final start = currentPage * rowsPerPage;
    final end = start + rowsPerPage;
    return filteredProducts.sublist(
      start,
      end > filteredProducts.length ? filteredProducts.length : end,
    );
  }

  int get totalPages => filteredProducts.isEmpty
      ? 1
      : (filteredProducts.length / rowsPerPage).ceil();
  void nextPage() {
    if (currentPage < totalPages - 1) {
      currentPage++;
      notifyListeners();
    }
  }

  void previousPage() {
    if (currentPage > 0) {
      currentPage--;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
