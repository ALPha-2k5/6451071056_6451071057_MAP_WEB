import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/coupon_model.dart';

class CouponService {
  final _firestore = FirebaseFirestore.instance;
  final String collection = "coupons";
  Future<List<CouponModel>> getCoupons() async {
    final snapshot = await _firestore.collection(collection).get();
    return snapshot.docs.map((doc) => CouponModel.fromFirestore(doc)).toList();
  }

  Future<String> addCoupon(CouponModel coupon) async {
    final doc = await _firestore.collection(collection).add(coupon.toMap());
    return doc.id;
  }

  Future<void> updateCoupon(CouponModel coupon) async {
    await _firestore
        .collection(collection)
        .doc(coupon.id)
        .update(coupon.toMap());
  }

  Future<void> deleteCoupon(String id) async {
    await _firestore.collection(collection).doc(id).delete();
  }
}
