import 'package:unoverse/data/services/group_service.dart';
import 'package:unoverse/domain/entity/group_entity.dart';
import 'package:uuid/uuid.dart';

class ModalController {
  GroupService groupService = GroupService();

  addGroup({
    required String name,
    required String uid,
    required List<String> members,
    required Map<String, String> role,
    required Map<String, int> config,
  }) {
    groupService.addGroup(
      group: Group(
        groupId: Uuid().v1(),
        name: name,
        createBy: uid,
        members: members,
        role: role,
        createIn: DateTime.now().toString(),
        config: config,
      ),
    );
  }
}
