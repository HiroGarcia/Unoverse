import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entity/player_entity.dart';

class PlayerService {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

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
