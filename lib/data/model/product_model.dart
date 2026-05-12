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

  // From Firestore
  factory ProductModel.fromMap(String id, Map<String, dynamic> map) {
    return ProductModel(
      id: id,
      title: map['title'] ?? '',
      lowerTitle: map['lowerTitle'],
      description: map['description'] ?? '',
      sku: map['sku'],
      price: (map['price'] ?? 0).toDouble(),
      salePrice: map['salePrice']?.toDouble(),
      thumbnail: map['thumbnail'] ?? '',
      images: List<String>.from(map['images'] ?? []),
      productType: ProductType.values.firstWhere(
        (e) => e.name == map['productType'],
        orElse: () => ProductType.simple,
      ),
      stock: map['stock'] ?? 0,
      isOutOfStock: map['isOutOfStock'],
      soldQuantity: map['soldQuantity'] ?? 0,
      brandId: map['brandId'],
      categoryIds: List<String>.from(map['categoryIds'] ?? []),
      tags: List<String>.from(map['tags'] ?? []),
      attributes: List<Map<String, dynamic>>.from(map['attributes'] ?? []),
      variations: List<Map<String, dynamic>>.from(map['variations'] ?? []),
      isRecommended: map['isRecommended'] ?? false,
      isFeatured: map['isFeatured'] ?? false,
      isActive: map['isActive'] ?? true,
      isDraft: map['isDraft'] ?? false,
      isDeleted: map['isDeleted'] ?? false,
      onSale: map['onSale'],
      saleStartDate: map['saleStartDate']?.toDate(),
      saleEndDate: map['saleEndDate']?.toDate(),
      views: map['views'] ?? 0,
      rating: (map['rating'] ?? 0).toDouble(),
      ratingCount: map['ratingCount'] ?? 0,
      reviewsCount: map['reviewsCount'] ?? 0,
      fiveStarCount: map['fiveStarCount'] ?? 0,
      fourStarCount: map['fourStarCount'] ?? 0,
      threeStarCount: map['threeStarCount'] ?? 0,
      twoStarCount: map['twoStarCount'] ?? 0,
      oneStarCount: map['oneStarCount'] ?? 0,
      likes: map['likes'] ?? 0,
      createdBy: map['createdBy'],
      updatedBy: map['updatedBy'],
      createdAt: map['createdAt']?.toDate(),
      updatedAt: map['updatedAt']?.toDate(),
    );
  }
}
