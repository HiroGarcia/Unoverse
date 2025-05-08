import 'package:cloud_firestore/cloud_firestore.dart';

class Player {
  final String playerId;
  final String name;
  String? userEmail;
  String? userUid;
  final int totalScore;
  final int totalMatches;
  final int totalMatchesPlayed;
  final Map<String, int>? pointsHistory;
  Player({
    required this.playerId,
    required this.name,
    this.userEmail,
    this.userUid,
    required this.totalScore,
    required this.totalMatches,
    required this.totalMatchesPlayed,
    this.pointsHistory,
  });

  Player.fromMap(Map<String, dynamic> map)
    : playerId = map['playerId'],
      name = map['name'],
      userEmail = map['userEmail'] ?? 'Vazio',
      userUid = map['userUid'] ?? 'Vazio',
      totalScore = map['totalScore'],
      totalMatches = map['totalMatches'],
      totalMatchesPlayed = map['totalMatchesPlayed'],
      pointsHistory = Map<String, int>.from(map['pointsHistory'] ?? {});

  factory Player.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data();
    if (data == null || data is! Map<String, dynamic>) {
      return Player(
        playerId: '',
        name: '',
        totalScore: 0,
        totalMatches: 0,
        totalMatchesPlayed: 0,
      );
    }
    return Player.fromMap(data);
  }

  Map<String, dynamic> toMap() {
    return {
      'playerId': playerId,
      'name': name,
      'userEmail': userEmail,
      'userUid': userUid,
      'totalScore': totalScore,
      'totalMatches': totalMatches,
      'totalMatchesPlayed': totalMatchesPlayed,
      'pointsHistory': pointsHistory,
    };
  }
}
