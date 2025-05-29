import 'package:cloud_firestore/cloud_firestore.dart';

class InviteEntity {
  final String inviteId;
  final String groupId;
  final String role;
  final DateTime expiresAt;
  final bool used;
  final String createBy;

  InviteEntity({
    required this.inviteId,
    required this.groupId,
    required this.role,
    required this.expiresAt,
    required this.used,
    required this.createBy,
  });

  InviteEntity.fromMap(Map<String, dynamic> map)
    : inviteId = map['inviteId'],
      groupId = map['groupId'],
      role = map['role'],
      expiresAt = (map['expiresAt'] as Timestamp).toDate(),
      used = map['used'],
      createBy = map['createBy'];

  Map<String, dynamic> toMap() {
    return {
      'inviteId': inviteId,
      'groupId': groupId,
      'role': role,
      'expiresAt': expiresAt,
      'used': used,
      'createBy': createBy,
    };
  }
}
