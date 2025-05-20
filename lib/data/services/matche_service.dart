import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entity/matche_entity.dart';

class MatcheService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Stream<List<MatcheEntity>> streamMatches(String groupId) {
    return firestore
        .collection("groups")
        .doc(groupId)
        .collection("matches")
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => MatcheEntity.fromMap(doc.data()))
                  .toList(),
        );
  }

  Future<void> addMatche({
    required MatcheEntity matche,
    required String groupId,
  }) async {
    final batch = firestore.batch();

    final matcheRef = firestore
        .collection("groups")
        .doc(groupId)
        .collection("matches")
        .doc(matche.id);
    batch.set(matcheRef, matche.toMap());

    for (final player in matche.poitns.entries) {
      final playerRef = firestore
          .collection("groups")
          .doc(groupId)
          .collection("players")
          .doc(player.key);

      batch.update(playerRef, {
        "totalScore": FieldValue.increment(player.value),
      });
      batch.update(playerRef, {"totalMatches": FieldValue.increment(1)});
    }

    await batch.commit();
  }
}
