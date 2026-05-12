class BrandCategoryModel {
  final String brandId;
  final String categoryId;
  BrandCategoryModel({required this.brandId, required this.categoryId});
  Map<String, dynamic> toMap() {
    return {'brandId': brandId, 'categoryId': categoryId};
  }
}
