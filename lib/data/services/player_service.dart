import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entity/player_entity.dart';

class PlayerService {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<List<Player>> readPlayer({required String groupId}) async {
    List<Player> temp = [];

    QuerySnapshot<Map<String, dynamic>> snapshot =
        await firestore
            .collection("groups")
            .doc(groupId)
            .collection("players")
            .get();

    for (var doc in snapshot.docs) {
      temp.add(Player.fromMap(doc.data()));
    }
    return temp;
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
