class UserEntity {
  String name;
  String email;
  String avatar;
  List<String> groupsId;

  UserEntity({
    required this.name,
    required this.email,
    required this.avatar,
    required this.groupsId,
  });

  UserEntity.fromMap(Map<String, dynamic> map)
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
