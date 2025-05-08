import 'package:flutter/material.dart';
import 'package:unoverse/data/services/player_service.dart';

import '../../domain/entity/player_entity.dart';

class PlayerProvider with ChangeNotifier {
  final PlayerService _playerService = PlayerService();
  List<Player> _players = [];

  List<Player> get players => _players;

  void listenToPlayers(String groupId) {
    _playerService.streamPlayers(groupId).listen((newPlayers) {
      _players = newPlayers;
      notifyListeners();
    });
  }

  Future<void> addPlayer(Player player, String groupId) async {
    await _playerService.addPlayer(player: player, groupId: groupId);
  }
}
