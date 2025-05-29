import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entity/invite_entity.dart';

class InviteService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Stream<List<InviteEntity>> streamInvites(String groupId) {
  //   return firestore
  //       .collection("groupInvites")
  //       .where('groupId', isEqualTo: groupId)
  //       .snapshots()
  //       .map(
  //         (snapshot) => snapshot.docs.map((doc) => InviteEntity.fromMap(doc.data())).toList(),
  //       );
  // }

  Future<void> createInvite({
    required InviteEntity invite,
  }) async {
    print("InviteService - createInvite Chamado");

    final batch = firestore.batch();

    final matcheRef = firestore.collection("groupInvites").doc(invite.inviteId);

    batch.set(matcheRef, invite.toMap());

    await batch.commit();
  }
}
