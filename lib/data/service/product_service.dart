import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';

class ProductService {
  final _db = FirebaseFirestore.instance;
  final String collection = "products";

  /// CREATE
  Future<void> create(ProductModel model) async {
    final docRef = _db.collection(collection).doc(); // tự generate id
    final newModel = ProductModel(
      id: docRef.id,
      title: model.title,
      lowerTitle: model.lowerTitle,
      description: model.description,
      sku: model.sku,
      price: model.price,
      salePrice: model.salePrice,
      thumbnail: model.thumbnail,
      images: model.images,
      productType: model.productType,
      stock: model.stock,
      isOutOfStock: model.isOutOfStock,
      soldQuantity: model.soldQuantity,
      brandId: model.brandId,
      categoryIds: model.categoryIds,
      tags: model.tags,
      attributes: model.attributes,
      variations: model.variations,
      isRecommended: model.isRecommended,
      isFeatured: model.isFeatured,
      isActive: model.isActive,
      isDraft: model.isDraft,
      isDeleted: model.isDeleted,
      onSale: model.onSale,
      saleStartDate: model.saleStartDate,
      saleEndDate: model.saleEndDate,
      views: model.views,
      rating: model.rating,
      ratingCount: model.ratingCount,
      reviewsCount: model.reviewsCount,
      fiveStarCount: model.fiveStarCount,
      fourStarCount: model.fourStarCount,
      threeStarCount: model.threeStarCount,
      twoStarCount: model.twoStarCount,
      oneStarCount: model.oneStarCount,
      likes: model.likes,
      createdBy: model.createdBy,
      updatedBy: model.updatedBy,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    );
    await docRef.set(newModel.toMap());
  }

  /// UPDATE
  Future<void> update(ProductModel model) async {
    await _db.collection(collection).doc(model.id).update(model.toMap());
  }

  /// GET ALL
  Stream<List<ProductModel>> getAll() {
    return _db
        .collection(collection)
        .orderBy("updatedAt", descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return ProductModel.fromMap(doc.id, doc.data());
          }).toList();
        });
  }

  /// GET ACTIVE PRODUCTS
  Stream<List<ProductModel>> getActiveProducts() {
    return _db
        .collection(collection)
        .where("isActive", isEqualTo: true)
        .where("isDeleted", isEqualTo: false)
        .orderBy("updatedAt", descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => ProductModel.fromMap(doc.id, doc.data()))
              .toList();
        });
  }

  /// POPULAR PRODUCTS
  Stream<List<ProductModel>> getPopularProducts() {
    return _db
        .collection(collection)
        .where("isActive", isEqualTo: true)
        .orderBy("soldQuantity", descending: true)
        .limit(10)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => ProductModel.fromMap(doc.id, doc.data()))
              .toList();
        });
  }

  /// FEATURED PRODUCTS
  Stream<List<ProductModel>> getFeaturedProducts() {
    return _db
        .collection(collection)
        .where("isFeatured", isEqualTo: true)
        .where("isActive", isEqualTo: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => ProductModel.fromMap(doc.id, doc.data()))
              .toList();
        });
  }

  /// DELETE (soft delete)
  Future<void> softDelete(String id) async {
    await _db.collection(collection).doc(id).update({
      "isDeleted": true,
      "updatedAt": FieldValue.serverTimestamp(),
    });
  }

  /// HARD DELETE
  Future<void> delete(String id) async {
    await _db.collection(collection).doc(id).delete();
  }
}
