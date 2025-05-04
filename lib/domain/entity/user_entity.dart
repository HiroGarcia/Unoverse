import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class User {
  String name;
  String email;
  String avatar;
  List<String> groupsId;

  User({
    required this.name,
    required this.email,
    required this.avatar,
    required this.groupsId,
  });

  User.fromMap(Map<String, dynamic> map)
    : name = map['name'],
      email = map['email'],
      avatar = map['avatar'] ?? '1',
      groupsId = List<String>.from(map['groupsId'] ?? []);

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'avatar': avatar,
      'groupsId': groupsId,
    };
  }
}

class UserService {
  String uid = FirebaseAuth.instance.currentUser!.uid;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<User> readUser() async {
    DocumentSnapshot<Map<String, dynamic>> snapshot =
        await firestore.collection("users").doc(uid).get();

    return User.fromMap(snapshot.data()!);
  }
}
