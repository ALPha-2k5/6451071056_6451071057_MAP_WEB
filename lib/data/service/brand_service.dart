import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/brand_model.dart';
import '../models/category_model.dart';
import '../models/brand_category_model.dart';

class BrandService {
  final _firestore = FirebaseFirestore.instance;
  Future<List<BrandModel>> getBrands() async {
    final snapshot = await _firestore.collection('brands').get();
    return snapshot.docs.map((doc) => BrandModel.fromFirestore(doc)).toList();
  }

  Future<String> addBrand(BrandModel brand) async {
    final doc = await _firestore.collection('brands').add(brand.toMap());
    return doc.id;
  }

  Future<void> updateBrand(BrandModel brand) async {
    await _firestore.collection('brands').doc(brand.id).update(brand.toMap());
  }

  Future<void> deleteBrand(String id) async {
    await _firestore.collection('brands').doc(id).delete();
    // Xóa relation
    final relationSnapshot = await _firestore
        .collection('brand_categories')
        .where('brandId', isEqualTo: id)
        .get();
    for (var doc in relationSnapshot.docs) {
      await doc.reference.delete();
    }
  }

  Future<void> saveBrandCategories(
    String brandId,
    List<String> categoryIds,
  ) async {
    final batch = _firestore.batch();
    // xóa cũ
    final snapshot = await _firestore
        .collection('brand_categories')
        .where('brandId', isEqualTo: brandId)
        .get();
    for (var doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    // thêm mới
    for (var categoryId in categoryIds) {
      final ref = _firestore.collection('brand_categories').doc();
      batch.set(ref, {'brandId': brandId, 'categoryId': categoryId});
    }
    await batch.commit();
  }

  Future<List<String>> getCategoriesOfBrand(String brandId) async {
    final snapshot = await _firestore
        .collection('brand_categories')
        .where('brandId', isEqualTo: brandId)
        .get();
    return snapshot.docs.map((doc) => doc['categoryId'] as String).toList();
  }

  Future<List<BrandModel>> getAllBrands() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('brands')
        .get();
    return snapshot.docs.map((doc) => BrandModel.fromFirestore(doc)).toList();
  }

  Future<List<String>> getCategoryNamesByBrand(String brandId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('brand_categories')
        .where('brandId', isEqualTo: brandId)
        .get();
    List<String> categoryIds = snapshot.docs
        .map((e) => e['categoryId'] as String)
        .toList();
    if (categoryIds.isEmpty) return [];
    final categorySnapshot = await FirebaseFirestore.instance
        .collection('categories')
        .where(FieldPath.documentId, whereIn: categoryIds)
        .get();
    return categorySnapshot.docs.map((e) => e['name'] as String).toList();
  }

  Future<List<BrandCategoryModel>> getAllBrandCategoryRelations() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('brand_categories')
        .get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return BrandCategoryModel(
        brandId: data['brandId'],
        categoryId: data['categoryId'],
      );
    }).toList();
  }

  Future<List<CategoryModel>> getAllCategories() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('categories')
        .get();
    return snapshot.docs
        .map((doc) => CategoryModel.fromFirestore(doc))
        .toList();
  }

  final String collection = "brands";
  Stream<Map<String, String>> getBrandMap() {
    return _firestore.collection(collection).snapshots().map((snapshot) {
      final map = <String, String>{};
      for (var doc in snapshot.docs) {
        map[doc.id] = doc["name"] ?? "";
      }
      return map;
    });
  }
}
