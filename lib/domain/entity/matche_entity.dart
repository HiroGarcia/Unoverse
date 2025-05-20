import 'package:cloud_firestore/cloud_firestore.dart';

class MatcheEntity {
  String id;
  DateTime dateTime;
  String registerByUid;
  Map<String, int> poitns;

  MatcheEntity({
    required this.id,
    required this.dateTime,
    required this.registerByUid,
    required this.poitns,
  });

  MatcheEntity.fromMap(Map<String, dynamic> map)
    : id = map['id'],
      dateTime = (map['dateTime'] as Timestamp).toDate(),
      registerByUid = map['registerByUid'],
      poitns = Map<String, int>.from(map['poitns']);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'dateTime': dateTime,
      'registerByUid': registerByUid,
      'poitns': poitns,
    };
  }
}
