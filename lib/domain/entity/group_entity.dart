import 'package:cloud_firestore/cloud_firestore.dart';

class Group {
  String groupId;
  String name;
  String createBy;
  List<String>? members;
  Map<String, String> role;
  DateTime createIn;
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
      createIn = (map['createIn'] as Timestamp).toDate(),
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

// Class feita para controle de erro do multiStream
class GroupFetchResult {
  final String groupId; // O ID do grupo que tentamos buscar
  final Group? group; // O objeto Group se a busca foi bem-sucedida
  final Object? error; // O erro se a busca falhou

  GroupFetchResult({required this.groupId, this.group, this.error});

  // Propriedades convenientes para verificar o estado
  bool get isSuccess => group != null && error == null;
  bool get isFailure => error != null;
  bool get isNotFound => group == null && error == null;
}
