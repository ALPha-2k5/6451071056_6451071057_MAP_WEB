import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/customer_model.dart';

class CustomerService {
  final _firestore = FirebaseFirestore.instance;
  Future<List<CustomerModel>> getCustomers() async {
    final snapshot = await _firestore.collection('users').get();
    return snapshot.docs
        .map((doc) => CustomerModel.fromMap(doc.data()))
        .toList();
  }

  Future<int> getOrdersCount(String userId) async {
    final snapshot = await _firestore
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .get();
    return snapshot.docs.length;
  }

  Future<List<Map<String, dynamic>>> getOrdersOfUser(String userId) async {
    final snapshot = await _firestore
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .get();
    return snapshot.docs.map((e) => e.data()).toList();
  }

  Future<void> deleteCustomer(String id) async {
    await _firestore.collection('users').doc(id).delete();
  }

  Future<CustomerModel?> getById(String id) async {
    final doc = await _firestore.collection('users').doc(id).get();
    if (!doc.exists) return null;
    final data = doc.data()!;
    data['id'] = doc.id;
    return CustomerModel.fromMap(data);
  }
}
