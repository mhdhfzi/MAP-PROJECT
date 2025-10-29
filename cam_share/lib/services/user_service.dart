import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collection = "users";

  Future<void> createUser(UserModel user) async =>
      await _firestore.collection(collection).doc(user.uid).set(user.toJson());

  Future<UserModel?> getUser(String uid) async {
    final doc = await _firestore.collection(collection).doc(uid).get();
    if (doc.exists) return UserModel.fromJson(doc.data()!);
    return null;
  }

  Future<void> updateUser(UserModel user) async =>
      await _firestore.collection(collection).doc(user.uid).update(user.toJson());
}
