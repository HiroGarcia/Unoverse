import 'package:flutter/material.dart';
import 'package:flutter_flip_card/flutter_flip_card.dart';
import 'package:provider/provider.dart';
import 'package:unoverse/data/services/group_service.dart';
import 'package:unoverse/data/services/player_service.dart';
import 'package:unoverse/domain/entity/enum_type.dart';
import 'package:unoverse/domain/entity/player_entity.dart';
import 'package:unoverse/presentation/controllers/card_flip_controller.dart';
import 'package:unoverse/presentation/widgets/show_form_dialog.dart';

import '../../domain/entity/group_entity.dart';
import '../pages/group/group_page.dart';
import 'my_alert_dialog.dart';

class MyCard extends StatefulWidget {
  final Group group;
  final Player? player;
  final String uid;
  final EnumType enumType;

  const MyCard({
    super.key,
    required this.group,
    required this.uid,
    this.player,
    required this.enumType,
  });

  @override
  State<MyCard> createState() => _MyCardState();
}

class _MyCardState extends State<MyCard> {
  final flipCardController = FlipCardController();
  @override
  Widget build(BuildContext context) {
    final flipController = Provider.of<CardFlipController>(context);
    final isFlipped = flipController.isFlipped(flipCardController);
    return GestureDetector(
      onTap:
          isFlipped
              ? null
              : () {
                handleInteractionOrReset(
                  context: context,
                  onValid:
                      widget.enumType == EnumType.group
                          ? () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => GroupPage(
                                      group: widget.group,
                                      uid: widget.uid,
                                    ),
                              ),
                            );
                          }
                          : () {},
                );
              },
      onLongPress: () {
        if (!isFlipped) {
          flipCardController.flipcard();
          flipController.flip(flipCardController);
        }
      },
      child: FlipCard(
        frontWidget: _buildFrontCard(context),
        backWidget: _buildBackCard(context),
        controller: flipCardController,
        rotateSide: RotateSide.left,
        axis: FlipAxis.vertical,
        animationDuration: Duration(milliseconds: 300),
      ),
    );
  }

  Widget _buildFrontCard(BuildContext context) {
    return Card(
      elevation: 3,
      color: Theme.of(context).colorScheme.secondary,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            widget.enumType == EnumType.group
                ? Text(
                  widget.group.name,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                )
                : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.player!.name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Pontuação total: ${widget.player!.totalScore}',
                    ),
                  ],
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackCard(BuildContext context) {
    return Card(
      elevation: 3,
      color: Theme.of(context).colorScheme.secondary,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton.icon(
            onPressed: () {
              showFormDialog(
                context: context,
                type: widget.enumType,
                group: widget.group,
                uid: widget.uid,
                player: widget.player,
              );
            },
            icon: Icon(Icons.edit),
            label: Text('Editar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
            ),
          ),
          SizedBox(height: 10),
          ElevatedButton.icon(
            onPressed: () {
              showConfirmDeleteDialog(
                context: context,
                onConfirm: () async {
                  try {
                    Provider.of<CardFlipController>(
                      context,
                      listen: false,
                    ).reset();
                    if (widget.enumType == EnumType.group) {
                      await GroupService().deleteGroup(
                        widget.group.groupId,
                        widget.uid,
                      );
                    } else if (widget.enumType == EnumType.player) {
                      await PlayerService().deletePlayer(
                        groupId: widget.group.groupId,
                        playerId: widget.player!.playerId,
                        userUid: widget.uid,
                      );
                    }
                    print(
                      '-----${widget.enumType} excluído com sucesso!-----',
                    );
                    if (!mounted) return;
                  } catch (e) {
                    if (!mounted) return;
                  }
                },
              );
            },
            icon: Icon(Icons.delete),
            label: Text('Excluir'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 99, 24, 18),
              foregroundColor: Theme.of(context).colorScheme.inversePrimary,
            ),
          ),
        ],
      ),
    );
  }
}
