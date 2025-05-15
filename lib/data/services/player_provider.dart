import 'dart:async';

import 'package:flutter/material.dart';
import 'package:unoverse/data/services/player_service.dart';

import '../../domain/entity/player_entity.dart';

class PlayerProvider with ChangeNotifier {
  final PlayerService _playerService = PlayerService();

  List<Player> _players = [];
  List<Player> get players => _players;

  StreamSubscription<List<Player>>? _playersSubscription;

  String? _currentGroupId;

  void listenToPlayers(String groupId) {
    if (_currentGroupId == groupId && _playersSubscription != null) {
      print("PlayerProvider: Já escutando jogadores para groupId: $groupId");
      return;
    }
    print(
      "PlayerProvider: Iniciando escuta de jogadores para groupId: $groupId",
    );

    _playersSubscription?.cancel();
    _playersSubscription = null;

    _currentGroupId = groupId;

    _players = [];

    _playersSubscription = _playerService
        .streamPlayers(groupId)
        .listen(
          (newPlayers) {
            print(
              "PlayerProvider: Stream de jogadores atualizado. ${newPlayers.length} jogadores recebidos para groupId: $groupId",
            );
            _players = newPlayers;
            notifyListeners();
          },
          onError: (error, stackTrace) {
            print(
              "PlayerProvider: Erro no listener do stream de jogadores para groupId $groupId: $error",
            );
            print(stackTrace);
            _players = [];
            notifyListeners();
          },
        );
  }

  void stopListening() {
    print(
      "PlayerProvider: Parando escuta de jogadores (cancelando assinatura).",
    );
    _playersSubscription?.cancel();
    _playersSubscription = null;
    _currentGroupId = null;
    _players = [];
    notifyListeners();
  }

  void resetForSignOut() {
    print("PlayerProvider: Resetando estado no logout.");
    stopListening();
  }

  Future<void> addPlayer(Player player, String groupId) async {
    await _playerService.addPlayer(player: player, groupId: groupId);
  }

  @override
  void dispose() {
    print("PlayerProvider: Dispose chamado. Parando escuta.");
    stopListening();
    super.dispose();
  }
}
