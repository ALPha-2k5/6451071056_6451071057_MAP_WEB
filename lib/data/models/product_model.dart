import 'package:cloud_firestore/cloud_firestore.dart';

enum ProductType { simple, variable }

class ProductModel {
  final String id;
  final String title;
  final String lowerTitle;
  final String description;
  final String? sku;
  final double price;
  final double? salePrice;
  final String thumbnail;
  final List<String>? images;
  final ProductType productType;
  final int stock;
  final bool? isOutOfStock;
  final int soldQuantity;
  final String? brandId;
  final List<String>? categoryIds;
  final List<String>? tags;
  final List<Map<String, dynamic>>? attributes;
  final List<Map<String, dynamic>>? variations;
  final bool isRecommended;
  final bool isFeatured;
  final bool isActive;
  final bool isDraft;
  final bool isDeleted;
  final bool? onSale;
  final DateTime? saleStartDate;
  final DateTime? saleEndDate;
  final int views;
  final double rating;
  final int ratingCount;
  final int reviewsCount;
  final int fiveStarCount;
  final int fourStarCount;
  final int threeStarCount;
  final int twoStarCount;
  final int oneStarCount;
  final int likes;
  final String? createdBy;
  final String? updatedBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  ProductModel({
    required this.id,
    required this.title,
    String? lowerTitle,
    this.description = '',
    this.sku,
    required this.price,
    this.salePrice,
    required this.thumbnail,
    this.images,
    this.productType = ProductType.simple,
    this.stock = 0,
    this.isOutOfStock,
    this.soldQuantity = 0,
    this.brandId,
    this.tags,
    this.categoryIds,
    this.attributes,
    this.variations,
    this.isRecommended = false,
    this.isFeatured = false,
    this.isActive = true,
    this.isDraft = false,
    this.isDeleted = false,
    this.onSale,
    this.saleStartDate,
    this.saleEndDate,
    this.views = 0,
    this.rating = 0.0,
    this.ratingCount = 0,
    this.reviewsCount = 0,
    this.fiveStarCount = 0,
    this.fourStarCount = 0,
    this.threeStarCount = 0,
    this.twoStarCount = 0,
    this.oneStarCount = 0,
    this.likes = 0,
    this.createdBy,
    this.createdAt,
    this.updatedBy,
    this.updatedAt,
  }) : lowerTitle = lowerTitle ?? title.toLowerCase();
  // Convert to Firestore
  Map<String, dynamic> toMap() {
    return {
      "title": title,
      "lowerTitle": lowerTitle,
      "description": description,
      "sku": sku,
      "price": price,
      "salePrice": salePrice,
      "thumbnail": thumbnail,
      "images": images,
      "productType": productType.name,
      "stock": stock,
      "isOutOfStock": isOutOfStock,
      "soldQuantity": soldQuantity,
      "brandId": brandId,
      "categoryIds": categoryIds,
      "tags": tags,
      "attributes": attributes,
      "variations": variations,
      "isRecommended": isRecommended,
      "isFeatured": isFeatured,
      "isActive": isActive,
      "isDraft": isDraft,
      "isDeleted": isDeleted,
      "onSale": onSale,
      "saleStartDate": saleStartDate,
      "saleEndDate": saleEndDate,
      "views": views,
      "rating": rating,
      "ratingCount": ratingCount,
      "reviewsCount": reviewsCount,
      "fiveStarCount": fiveStarCount,
      "fourStarCount": fourStarCount,
      "threeStarCount": threeStarCount,
      "twoStarCount": twoStarCount,
      "oneStarCount": oneStarCount,
      "likes": likes,
      "createdBy": createdBy,
      "updatedBy": updatedBy,
      "createdAt": createdAt ?? FieldValue.serverTimestamp(),
      "updatedAt": FieldValue.serverTimestamp(),
    };
  }

  static DateTime? _parseDate(dynamic date) {
    if (date == null) return null;
    if (date is Timestamp) return date.toDate();
    if (date is DateTime) return date;
    if (date is String) return DateTime.tryParse(date);
    return null;
  }

  static bool _parseBool(dynamic value, {bool fallback = false}) {
    if (value == null) return fallback;
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      if (normalized == 'true' || normalized == '1') return true;
      if (normalized == 'false' || normalized == '0') return false;
    }
    return fallback;
  }

  static int _parseInt(dynamic value, {int fallback = 0}) {
    if (value == null) return fallback;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? fallback;
    return fallback;
  }

  static double _parseDouble(dynamic value, {double fallback = 0}) {
    if (value == null) return fallback;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? fallback;
    return fallback;
  }

  static List<String> _parseStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value
          .map((item) => item?.toString() ?? '')
          .where((item) => item.isNotEmpty)
          .toList();
    }
    if (value is String && value.trim().isNotEmpty) {
      return [value.trim()];
    }
    return [];
  }

  static List<Map<String, dynamic>> _parseMapList(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }
    return [];
  }

  // From Firestore
  factory ProductModel.fromMap(String id, Map<String, dynamic> map) {
    return ProductModel(
      id: id,
      title: map['title'] ?? '',
      lowerTitle: map['lowerTitle'],
      description: map['description'] ?? '',
      sku: map['sku'],
      price: _parseDouble(map['price']),
      salePrice: map['salePrice'] == null
          ? null
          : _parseDouble(map['salePrice']),
      thumbnail: map['thumbnail'] ?? '',
      images: _parseStringList(map['images']),
      productType: ProductType.values.firstWhere(
        (e) => e.name == map['productType'],
        orElse: () => ProductType.simple,
      ),
      stock: _parseInt(map['stock']),
      isOutOfStock: map['isOutOfStock'] == null
          ? null
          : _parseBool(map['isOutOfStock']),
      soldQuantity: _parseInt(map['soldQuantity']),
      brandId: map['brandId'],
      categoryIds: _parseStringList(map['categoryIds']),
      tags: _parseStringList(map['tags']),
      attributes: _parseMapList(map['attributes']),
      variations: _parseMapList(map['variations']),
      isRecommended: _parseBool(map['isRecommended']),
      isFeatured: _parseBool(map['isFeatured']),
      isActive: _parseBool(map['isActive'], fallback: true),
      isDraft: _parseBool(map['isDraft']),
      isDeleted: _parseBool(map['isDeleted']),
      onSale: map['onSale'] == null ? null : _parseBool(map['onSale']),
      saleStartDate: _parseDate(map['saleStartDate']),
      saleEndDate: _parseDate(map['saleEndDate']),
      views: _parseInt(map['views']),
      rating: _parseDouble(map['rating']),
      ratingCount: _parseInt(map['ratingCount']),
      reviewsCount: _parseInt(map['reviewsCount']),
      fiveStarCount: _parseInt(map['fiveStarCount']),
      fourStarCount: _parseInt(map['fourStarCount']),
      threeStarCount: _parseInt(map['threeStarCount']),
      twoStarCount: _parseInt(map['twoStarCount']),
      oneStarCount: _parseInt(map['oneStarCount']),
      likes: _parseInt(map['likes']),
      createdBy: map['createdBy'],
      updatedBy: map['updatedBy'],
      createdAt: _parseDate(map['createdAt']),
      updatedAt: _parseDate(map['updatedAt']),
    );
  }
}
