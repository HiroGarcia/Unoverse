class Group {
  String groupId;
  String name;
  String createBy;
  List<String>? members;
  Map<String, String> role;
  String createIn;
  Map<String, int> config;

  Group({
    required this.groupId,
    required this.name,
    required this.createBy,
    this.members,
    required this.role,
    required this.createIn,
    required this.config,
  });

  Group.fromMap(Map<String, dynamic> map)
    : groupId = map['groupId'],
      name = map['name'],
      createBy = map['createBy'],
      members = List<String>.from(
        map['members'] != null ? List<String>.from(map['members']) : [],
      ),
      role = Map<String, String>.from(map['role']),
      createIn = map['createIn'],
      config = Map<String, int>.from(map['config']);

  Map<String, dynamic> toMap() {
    return {
      'groupId': groupId,
      'name': name,
      'createBy': createBy,
      'members': members,
      'role': role,
      'createIn': createIn,
      'config': config,
    };
  }
}
