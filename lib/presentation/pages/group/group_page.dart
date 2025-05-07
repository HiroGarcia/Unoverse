import 'package:flutter/material.dart';
import 'package:unoverse/domain/entity/enum_type.dart';

import '../../../data/services/player_service.dart';
import '../../../domain/entity/group_entity.dart';
import '../../../domain/entity/player_entity.dart';
import '../../widgets/show_form_modal.dart';

class GroupPage extends StatefulWidget {
  final Group group;
  const GroupPage({required this.group, super.key});

  @override
  State<GroupPage> createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupPage> {
  List<Player> listPlayer = [];

  PlayerService playerService = PlayerService();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.group.name)),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showFormModal(
            context: context,
            type: EnumType.player,
            groupId: widget.group.groupId,
          );
        },
        child: Icon(Icons.add),
      ),
      body: Container(),
    );
  }
}
