import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/category_model.dart';

class CategoryService {
  final _firestore = FirebaseFirestore.instance;
  final _collection = "categories";
  Future<List<CategoryModel>> getCategories() async {
    final snapshot = await _firestore.collection(_collection).get();
    return snapshot.docs
        .map((doc) => CategoryModel.fromFirestore(doc))
        .toList();
  }

  Future<void> addCategory(CategoryModel category) async {
    await _firestore.collection(_collection).add(category.toMap());
  }

  Future<void> updateCategory(CategoryModel category) async {
    await _firestore
        .collection(_collection)
        .doc(category.id)
        .update(category.toMap());
  }

  Future<void> deleteCategory(String id) async {
    await _firestore.collection(_collection).doc(id).delete();
  }
}
