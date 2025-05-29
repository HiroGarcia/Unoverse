import 'package:cloud_firestore/cloud_firestore.dart';

class UserEntity {
  String? name;
  String? email;
  String? avatar;
  List<String> groupsId;
  Map<String, String>? invites;

  UserEntity({
    this.name = '',
    this.email = '',
    this.avatar = '',
    required this.groupsId,
    this.invites,
  });

  UserEntity.fromMap(Map<String, dynamic> map)
    : name = map['name'],
      email = map['email'],
      avatar = map['avatar'] ?? '1',
      groupsId = List<String>.from(
        map['groupsId'] ?? [],
      );

  factory UserEntity.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data();
    if (data == null || data is! Map<String, dynamic>) {
      return UserEntity(groupsId: []);
    }
    return UserEntity.fromMap(data);
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'avatar': avatar,
      'groupsId': groupsId,
    };
  }
}
