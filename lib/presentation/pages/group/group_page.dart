import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../controllers/card_flip_controller.dart';
import '../../../data/providers/player_provider.dart';
import '../../../domain/entity/group_entity.dart';
import '../../../domain/enums/enum_type.dart';
import '../../widgets/add_new_matche.dart';
import '../../widgets/my_button.dart';
import '../../widgets/show_form_dialog.dart';
import 'my_history_list.dart';
import 'my_player_list.dart';

class GroupPage extends StatefulWidget {
  final String uid;
  final Group group;

  const GroupPage({
    required this.group,
    required this.uid,
    super.key,
  });

  @override
  State<GroupPage> createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {
  late PlayerProvider _playerProvider;
  bool _isListeningStarted = false;
  bool _expandHistorico = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _playerProvider = Provider.of<PlayerProvider>(context, listen: false);
    if (!_isListeningStarted) {
      print("GroupPageState: didChangeDependencies - Iniciando escuta de jogadores para groupId: ${widget.group.groupId}");
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
            onPressed: () {},
            icon: Icon(
              Icons.person_add,
              // color: Theme.of(context).colorScheme.primary,
              color: Colors.red[900],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: Icon(
          Icons.chat,
          color: Colors.red[900],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: EdgeInsets.only(bottom: 25),
                padding: EdgeInsets.all(20),
                height: MediaQuery.of(context).size.height * 0.32,
                child: Column(
                  children: [
                    Text(
                      "Jogadores",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10),
                    Expanded(
                      child: MyPlayerList(
                        group: widget.group,
                        sortedPlayers: sortedPlayers,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: MyButton(
                      text: "Adicionar Pontuação",
                      onTap: () {
                        addNewMatche(
                          context: context,
                          players: sortedPlayers,
                          groupId: widget.group.groupId,
                          config: widget.group.config,
                        );
                      },
                    ),
                  ),
                  SizedBox(width: 15),
                  Expanded(
                    child: MyButton(
                      text: "Adicionar Jogador",
                      onTap: () {
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
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),
              // Histórico
              StatefulBuilder(
                builder: (
                  context,
                  setStateHistorico,
                ) {
                  return Container(
                    decoration: BoxDecoration(
                      color:
                          Theme.of(
                            context,
                          ).colorScheme.secondary,
                      borderRadius: BorderRadius.circular(
                        12,
                      ),
                    ),
                    height: _expandHistorico ? null : MediaQuery.of(context).size.height * 0.32,
                    padding: const EdgeInsets.only(
                      top: 10,
                      right: 10,
                      left: 10,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(),
                            ),
                            Expanded(
                              child: Text(
                                "Histórico",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.inversePrimary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: IconButton(
                                  icon: Icon(
                                    _expandHistorico ? Icons.expand_less : Icons.expand_more,
                                    color: Theme.of(context).colorScheme.inversePrimary,
                                  ),
                                  onPressed:
                                      (listPlayer.isEmpty)
                                          ? null
                                          : () {
                                            setState(() {
                                              _expandHistorico = !_expandHistorico;
                                            });
                                          },
                                ),
                              ),
                            ),
                          ],
                        ),
                        _expandHistorico
                            ? MyHistoryList(
                              group: widget.group,
                              sortedPlayers: sortedPlayers,
                            )
                            : Expanded(
                              child: SingleChildScrollView(
                                child: MyHistoryList(
                                  group: widget.group,
                                  sortedPlayers: sortedPlayers,
                                ),
                              ),
                            ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
