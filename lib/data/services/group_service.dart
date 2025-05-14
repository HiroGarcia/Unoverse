import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entity/group_entity.dart';

class GroupService {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<List<Group>> readGroup({required List<String> groupId}) async {
    print(">>> loadGroups chamada <<<");
    List<Group> temp = [];

    for (var group in groupId) {
      DocumentSnapshot<Map<String, dynamic>> snapshot =
          await firestore.collection("groups").doc(group).get();

      if (snapshot.exists) {
        print("Lendo grupo com ID da lista: ${snapshot.id}");
        temp.add(Group.fromMap(snapshot.data()!));
      } else {
        print("Grupo com ID $groupId da lista não encontrado.");
      }
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
