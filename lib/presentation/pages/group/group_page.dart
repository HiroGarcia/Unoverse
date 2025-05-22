import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unoverse/data/services/player_provider.dart';
import 'package:unoverse/domain/entity/enum_type.dart';
import 'package:unoverse/presentation/controllers/card_flip_controller.dart';
import 'package:unoverse/presentation/widgets/my_card.dart';

import '../../../domain/entity/group_entity.dart';
import '../../widgets/add_new_matche.dart';
import '../../widgets/show_form_dialog.dart';

class GroupPage extends StatefulWidget {
  final String uid;
  final Group group;
  const GroupPage({required this.group, required this.uid, super.key});

  @override
  State<GroupPage> createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {
  late PlayerProvider _playerProvider;
  bool _isListeningStarted = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _playerProvider = Provider.of<PlayerProvider>(context, listen: false);
    if (!_isListeningStarted) {
      print(
        "GroupPageState: didChangeDependencies - Iniciando escuta de jogadores para groupId: ${widget.group.groupId}",
      );
      _playerProvider.listenToPlayers(widget.group.groupId);
      _isListeningStarted = true;
    }
  }

  @override
  void dispose() {
    print("GroupPageState: dispose - Parando escuta de jogadores.");
    _playerProvider.stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final listPlayer = context.watch<PlayerProvider>().players;
    final sortedPlayers = [...listPlayer]..sort((a, b) {
      return b.totalScore.compareTo(a.totalScore);
    });

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            handleInteractionOrReset(
              context: context,
              onValid: () {
                Navigator.pop(context);
              },
            );
          },
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        title: Text(widget.group.name),
        actions: [
          IconButton(
            onPressed: () {
              handleInteractionOrReset(
                context: context,
                onValid: () {
                  showFormDialog(
                    context: context,
                    type: EnumType.player,
                    group: widget.group,
                  );
                },
              );
            },
            icon: Icon(
              Icons.person_add,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          handleInteractionOrReset(
            context: context,
            onValid: () {
              addNewMatche(
                context: context,
                players: sortedPlayers,
                groupId: widget.group.groupId,
                config: widget.group.config,
              );
            },
          );
        },
        child: Icon(Icons.add),
      ),
      body:
          (listPlayer.isEmpty)
              ? const Center(
                child: Text(
                  "Nenhum jogador ainda.\nVamos criar o primeiro?",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18),
                ),
              )
              : Container(
                padding: EdgeInsets.only(top: 10, left: 10, right: 10),
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 200,
                    mainAxisSpacing: 3,
                    crossAxisSpacing: 3,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: sortedPlayers.length,
                  itemBuilder: (context, index) {
                    return MyCard(
                      group: widget.group,
                      uid: widget.uid,
                      player: sortedPlayers[index],
                      enumType: EnumType.player,
                    );
                  },
                ),
              ),
    );
  }
}
