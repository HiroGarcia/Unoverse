import 'package:flutter/material.dart';
import 'package:flutter_flip_card/flutter_flip_card.dart';
import 'package:provider/provider.dart';
import 'package:unoverse/presentation/controllers/card_flip_controller.dart';

import '../../domain/entity/group_entity.dart';
import '../pages/group/group_page.dart';

class GroupCard extends StatefulWidget {
  final Group group;
  const GroupCard({super.key, required this.group});

  @override
  State<GroupCard> createState() => _GroupCardState();
}

class _GroupCardState extends State<GroupCard> {
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
                  onValid: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GroupPage(group: widget.group),
                      ),
                    );
                  },
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
            Text(
              widget.group.name,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
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
      child: Center(
        child: ElevatedButton.icon(
          onPressed: () {},
          icon: Icon(Icons.edit),
          label: Text('Editar'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
          ),
        ),
      ),
    );
  }
}
