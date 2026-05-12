import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/attribute_model.dart';

class AttributeService {
  final _db = FirebaseFirestore.instance;
  final String collection = "attributes";
  Future<void> create(AttributeModel model) async {
    await _db.collection(collection).add(model.toMap());
  }

  Future<void> update(AttributeModel model) async {
    await _db.collection(collection).doc(model.id).update(model.toMap());
  }

  Future<void> delete(String id) async {
    await _db.collection(collection).doc(id).delete();
  }

  Stream<List<AttributeModel>> getAll() {
    return _db
        .collection(collection)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => AttributeModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }
}
