import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entity/player_entity.dart';

class PlayerService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Stream<List<Player>> streamPlayers(String groupId) {
    return firestore
        .collection("groups")
        .doc(groupId)
        .collection("players")
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Player.fromMap(doc.data())).toList(),
        );
  }

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

  Future<void> deletePlayer({
    required String groupId,
    required String userUid,
    required String playerId,
  }) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot =
          await firestore.collection("groups").doc(groupId).get();

      if (!snapshot.exists) {
        throw Exception("Grupo não encontrado.");
      }

      final data = snapshot.data();
      final roleMap = data?['role'] as Map<String, dynamic>?;
      print(userUid);
      print(roleMap);

      if (roleMap == null ||
          (roleMap[userUid] != 'master' && roleMap[userUid] != 'admin')) {
        throw Exception("Apenas o usuário master pode excluir o jogador.");
      }
      firestore
          .collection("groups")
          .doc(groupId)
          .collection("players")
          .doc(playerId)
          .delete();
      print(
        "Plater $playerId excluído com sucesso e removido da lista de players.",
      );
    } on FirebaseException catch (e) {
      print("Erro ao excluir jogador: ${e.code}");
      rethrow;
    } catch (e) {
      print("Erro inesperado ao excluir jogador: $e");
      rethrow;
    }
  }
}
