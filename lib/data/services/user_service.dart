import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/entity/user_entity.dart';

class UserService {
  String uid = FirebaseAuth.instance.currentUser!.uid;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<UserEntity> readUser() async {
    DocumentSnapshot<Map<String, dynamic>> snapshot =
        await firestore.collection("users").doc(uid).get();

    return UserEntity.fromMap(snapshot.data()!);
  }
}
