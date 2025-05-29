import 'package:firebase_auth/firebase_auth.dart';

import '../data/services/group_service.dart';
import '../data/services/invite_service.dart';
import '../domain/entity/invite_entity.dart';
import '../domain/enums/enum_role.dart';

class InviteController {
  final InviteService _inviteService = InviteService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GroupService _groupService = GroupService();

  void createdInvite({
    required String groupId,
    required Role role,
    required String inviteId,
  }) {
    print("createdInvite Chamado - Invite_controller");

    InviteEntity invite = InviteEntity(
      inviteId: inviteId,
      groupId: groupId,
      role: role.name,
      expiresAt: DateTime.now().add(Duration(hours: 10)),
      used: false,
      createBy: _auth.currentUser!.uid,
    );

    try {
      _inviteService.createInvite(invite: invite);
    } on FirebaseException catch (e) {
      print(e.code);
    } catch (e) {
      print(e);
    }
  }

  void readInvite({required String inviteId}) {
    print("readInvite Chamado - Invite_controller");

    try {
      _groupService.validateInviteAndAddMember(
        inviteId: inviteId,
        userId: _auth.currentUser!.uid,
      );
    } on FirebaseException catch (e) {
      print(e.code);
    } catch (e) {
      print(e);
    }
  }
}
