import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entity/player_entity.dart';

class PlayerService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Stream<List<Player>> streamPlayers(String groupId) {
    return firestore
        .collection("groups")
        .doc(groupId)
        .collection("players")
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Player.fromMap(doc.data())).toList(),
        );
  }

  Future<void> addPlayer({
    required Player player,
    required String groupId,
  }) async {
    await firestore
        .collection("groups")
        .doc(groupId)
        .collection("players")
        .doc(player.playerId)
        .set(player.toMap());
  }
}
