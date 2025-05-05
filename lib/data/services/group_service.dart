import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entity/group_entity.dart';

class GroupService {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<List<Group>> readGroup({required String groupId}) async {
    List<Group> temp = [];
    print(groupId);
    QuerySnapshot<Map<String, dynamic>> snapshot =
        await firestore
            .collection("groups")
            .where('groupId', isEqualTo: groupId)
            .get();

    for (var doc in snapshot.docs) {
      temp.add(Group.fromMap(doc.data()));
    }
    print(temp[0].config);
    return temp;
  }
}
