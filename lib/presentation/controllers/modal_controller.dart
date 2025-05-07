import 'package:unoverse/data/services/group_service.dart';
import 'package:unoverse/data/services/player_service.dart';
import 'package:unoverse/domain/entity/group_entity.dart';
import 'package:unoverse/domain/entity/player_entity.dart';
import 'package:uuid/uuid.dart';

class ModalController {
  GroupService groupService = GroupService();
  PlayerService playerService = PlayerService();

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
        createIn: DateTime.now(),
        config: config,
      ),
    );
  }

  addPlayer({
    required String name,
    required String userEmail,
    required int scoreInitial,
    required String groupId,
  }) {
    playerService.addPlayer(
      player: Player(
        playerId: Uuid().v1(),
        name: name,
        userEmail: userEmail,
        totalScore: scoreInitial,
        totalMatches: 0,
        totalMatchesPlayed: 0,
      ),
      groupId: groupId,
    );
  }
}
