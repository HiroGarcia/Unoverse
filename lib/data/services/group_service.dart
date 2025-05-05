import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entity/group_entity.dart';

class GroupService {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<List<Group>> readGroup({required List<String> groupId}) async {
    List<Group> temp = [];

    QuerySnapshot<Map<String, dynamic>> snapshot =
        await firestore
            .collection("groups")
            .where('groupId', whereIn: groupId)
            .get();

    for (var doc in snapshot.docs) {
      temp.add(Group.fromMap(doc.data()));
    }
    return temp;
  }

  Future<void> addGroup({required Group group}) async {
    try {
      await firestore
          .collection("groups")
          .doc(group.groupId)
          .set(group.toMap());

      await firestore.collection("users").doc(group.createBy).update({
        'groupsId': FieldValue.arrayUnion([group.groupId]),
      });
    } on FirebaseException catch (e) {
      print("Erro ao adicionar grupo e atualizar usuário: $e");
    }
  }
}
