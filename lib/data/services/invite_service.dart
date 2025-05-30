import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entity/invite_entity.dart';

class InviteService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> createInvite({
    required InviteEntity invite,
    required String groupName,
  }) async {
    print("InviteService - createInvite Chamado");
    final batch = firestore.batch();

    final userDocRef = firestore.collection("users").doc(invite.createBy);
    final matcheRef = firestore.collection("groupInvites").doc(invite.inviteId);

    batch.set(matcheRef, invite.toMap());

    batch.update(userDocRef, {
      'invites': {groupName: invite.inviteId},
    });

    await batch.commit();
  }
}
  // Stream<List<InviteEntity>> streamInvites(String groupId) {
  //   return firestore
  //       .collection("groupInvites")
  //       .where('groupId', isEqualTo: groupId)
  //       .snapshots()
  //       .map(
  //         (snapshot) => snapshot.docs.map((doc) => InviteEntity.fromMap(doc.data())).toList(),
  //       );
  // }
