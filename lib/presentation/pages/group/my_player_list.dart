import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../../domain/entity/group_entity.dart';
import '../../../domain/entity/player_entity.dart';
import '../../../data/services/player_service.dart';
import '../../../domain/enums/enum_type.dart';
import '../../widgets/my_alert_dialog.dart';
import '../../widgets/show_form_dialog.dart';

class MyPlayerList extends StatefulWidget {
  final List<Player> sortedPlayers;

  final Group group;

  const MyPlayerList({super.key, required this.sortedPlayers, required this.group});

  @override
  State<MyPlayerList> createState() => _MyPlayerListState();
}

class _MyPlayerListState extends State<MyPlayerList> {
  @override
  Widget build(BuildContext context) {
    if (widget.sortedPlayers.isEmpty) {
      return const Center(
        child: Text(
          "Nenhum jogador ainda.\nVamos criar o primeiro?",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 15),
        ),
      );
    }
    return SlidableAutoCloseBehavior(
      child: ListView.builder(
        itemCount: widget.sortedPlayers.length,
        itemBuilder: (context, index) {
          final Player player = widget.sortedPlayers[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 5.0),
            child: Slidable(
              key: ValueKey<Player>(player),
              startActionPane: ActionPane(
                extentRatio: 0.13,
                motion: DrawerMotion(),
                children: [
                  SlidableAction(
                    onPressed: (context) {
                      showFormDialog(
                        context: context,
                        type: EnumType.player,
                        group: widget.group,
                        player: player,
                      );
                    },
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    icon: Icons.edit,
                  ),
                ],
              ),
              endActionPane: ActionPane(
                extentRatio: 0.13,
                motion: const DrawerMotion(),
                children: [
                  SlidableAction(
                    onPressed: (context) {
                      showConfirmDeleteDialog(
                        context: context,
                        onConfirm: () async {
                          try {
                            await PlayerService().deletePlayer(
                              groupId: widget.group.groupId,
                              playerId: player.playerId,
                            );
                            if (!mounted) return;
                          } catch (e) {
                            if (!mounted) return;
                          }
                        },
                      );
                    },
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.red,
                    borderRadius: BorderRadius.circular(6),
                    icon: Icons.delete,
                  ),
                ],
              ),
              child: Container(
                padding: EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.tertiary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(widget.sortedPlayers[index].name),
                    Text("Score: ${widget.sortedPlayers[index].totalScore}"),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
