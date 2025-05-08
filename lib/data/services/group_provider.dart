import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../domain/entity/group_entity.dart';
import '../services/group_service.dart';

class GroupProvider with ChangeNotifier {
  final GroupService groupService;

  List<Group> _groups = [];
  List<Group> get groups => _groups;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  GroupProvider({required this.groupService});

  Future<void> loadGroups(List<String> groupIds) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (groupIds.isNotEmpty) {
        _groups = await groupService.readGroup(groupId: groupIds);
      } else {
        _groups = [];
      }
    } catch (e) {
      print("Erro ao carregar grupos: $e");
    }

    _isLoading = false;
    notifyListeners();
  }
}
