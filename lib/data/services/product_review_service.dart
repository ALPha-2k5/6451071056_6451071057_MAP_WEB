import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_review_model.dart';

class ReviewService {
  final _db = FirebaseFirestore.instance;
  final String collection = "reviews";

  /// APPROVE REVIEW
  Future<void> approveAndUpdateProduct(ReviewModel review) async {
    final reviewRef = _db.collection("reviews").doc(review.id);
    final productRef = _db.collection("products").doc(review.productId);
    await _db.runTransaction((transaction) async {
      final reviewSnap = await transaction.get(reviewRef);
      final productSnap = await transaction.get(productRef);
      if (!reviewSnap.exists || !productSnap.exists) {
        throw Exception("Review or Product not found");
      }
      final reviewData = reviewSnap.data() as Map<String, dynamic>;

      /// Nếu đã approve rồi thì không làm nữa
      if (reviewData['isApproved'] == true) return;
      final productData = productSnap.data() as Map<String, dynamic>;
      double currentRating = (productData['rating'] ?? 0).toDouble();
      int ratingCount = productData['ratingCount'] ?? 0;
      int reviewsCount = productData['reviewsCount'] ?? 0;
      int fiveStar = productData['fiveStarCount'] ?? 0;
      int fourStar = productData['fourStarCount'] ?? 0;
      int threeStar = productData['threeStarCount'] ?? 0;
      int twoStar = productData['twoStarCount'] ?? 0;
      int oneStar = productData['oneStarCount'] ?? 0;
      double newRatingValue = review.rating;

      /// Update số sao tương ứng
      switch (newRatingValue.round()) {
        case 5:
          fiveStar++;
          break;
        case 4:
          fourStar++;
          break;
        case 3:
          threeStar++;
          break;
        case 2:
          twoStar++;
          break;
        case 1:
          oneStar++;
          break;
      }

      /// Tính lại rating trung bình
      double newAverage =
          ((currentRating * ratingCount) + newRatingValue) / (ratingCount + 1);

      /// 1. Update review
      transaction.update(reviewRef, {
        "isApproved": true,
        "updatedAt": FieldValue.serverTimestamp(),
      });

      /// 2. Update product
      transaction.update(productRef, {
        "rating": double.parse(newAverage.toStringAsFixed(1)),
        "ratingCount": ratingCount + 1,
        "reviewsCount": reviewsCount + 1,
        "fiveStarCount": fiveStar,
        "fourStarCount": fourStar,
        "threeStarCount": threeStar,
        "twoStarCount": twoStar,
        "oneStarCount": oneStar,
        "updatedAt": FieldValue.serverTimestamp(),
      });
    });
  }

  /// DELETE REVIEW
  Future<void> delete(String id) async {
    await _db.collection(collection).doc(id).delete();
  }

  Stream<List<ReviewModel>> getAll() {
    return _db
        .collection(collection)
        .orderBy("updatedAt", descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((e) => ReviewModel.fromSnapshot(e)).toList(),
        );
  }
}
