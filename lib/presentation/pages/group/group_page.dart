import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unoverse/data/providers/player_provider.dart';
import 'package:unoverse/domain/enums/enum_type.dart';
import 'package:unoverse/controllers/card_flip_controller.dart';
import 'package:unoverse/presentation/widgets/my_button.dart';
import 'package:unoverse/presentation/widgets/my_card.dart';

import '../../../data/services/matche_service.dart';
import '../../../domain/entity/group_entity.dart';
import '../../../domain/entity/matche_entity.dart';
import '../../../domain/entity/player_entity.dart';
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
              // : Container(
              //   padding: EdgeInsets.only(top: 10, left: 10, right: 10),
              //   child: GridView.builder(
              //     gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              //       maxCrossAxisExtent: 200,
              //       mainAxisSpacing: 3,
              //       crossAxisSpacing: 3,
              //       childAspectRatio: 1.0,
              //     ),
              //     itemCount: sortedPlayers.length,
              //     itemBuilder: (context, index) {
              //       return MyCard(
              //         group: widget.group,
              //         uid: widget.uid,
              //         player: sortedPlayers[index],
              //         enumType: EnumType.player,
              //       );
              //     },
              //   ),
              // ),
              : Padding(
                padding: const EdgeInsets.all(25.0),
                child: Column(
                  children: [
                    Container(
                      margin: EdgeInsets.only(bottom: 25),
                      padding: EdgeInsets.all(25),
                      height: 300,
                      color: Theme.of(context).colorScheme.secondary,
                      child: Column(
                        children: [
                          Text(
                            "Jogadores",
                          ),
                          SizedBox(
                            height: 200,
                            child: ListView.builder(
                              itemCount: sortedPlayers.length,
                              itemBuilder: (context, index) {
                                return Container(
                                  margin: EdgeInsets.only(bottom: 5),
                                  height: 30,
                                  color: Theme.of(context).colorScheme.tertiary,
                                  child: Text(sortedPlayers[index].name),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: MyButton(text: "Adicionar Pontuação")),
                        SizedBox(width: 15),
                        Expanded(child: MyButton(text: "Adicionar Jogador")),
                      ],
                    ),
                    const SizedBox(height: 25),
                    Container(
                      height: 300,
                      padding: EdgeInsets.only(top: 10, right: 10, left: 10),
                      color: Theme.of(context).colorScheme.secondary,

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Histórico",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Expanded(
                            child: StreamBuilder<List<MatcheEntity>>(
                              stream: MatcheService().streamMatches(
                                widget.group.groupId,
                              ),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }
                                if (!snapshot.hasData ||
                                    snapshot.data!.isEmpty) {
                                  return const Center(
                                    child: Text("Nenhuma partida registrada."),
                                  );
                                }
                                final matches = snapshot.data!;
                                return GridView.builder(
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        childAspectRatio: 1.1,
                                        crossAxisSpacing: 10,
                                        mainAxisSpacing: 10,
                                      ),
                                  itemCount: matches.length,
                                  itemBuilder: (context, index) {
                                    final matche = matches[index];
                                    // Ordena os jogadores por pontuação (decrescente)
                                    final sortedWinners =
                                        matche.poitns.entries.toList()..sort(
                                          (a, b) => b.value.compareTo(a.value),
                                        );
                                    return Card(
                                      elevation: 2,
                                      child: Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Partida ${matche.dateTime.day.toString().padLeft(2, '0')}/"
                                              "${matche.dateTime.month.toString().padLeft(2, '0')}/"
                                              "${matche.dateTime.year} "
                                              "${matche.dateTime.hour.toString().padLeft(2, '0')}:"
                                              "${matche.dateTime.minute.toString().padLeft(2, '0')}",
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              "Ganhadores:",
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            ...List.generate(
                                              sortedWinners.length,
                                              (i) {
                                                // Busca o nome do jogador pelo id
                                                final playerName =
                                                    sortedPlayers
                                                        .firstWhere(
                                                          (p) =>
                                                              p.playerId ==
                                                              sortedWinners[i]
                                                                  .key,
                                                          orElse:
                                                              () => Player(
                                                                playerId: '',
                                                                name:
                                                                    'Desconhecido',
                                                                totalScore: 0,
                                                                totalMatches: 0,
                                                                totalMatchesPlayed:
                                                                    0,
                                                              ),
                                                        )
                                                        .name;
                                                return Text(
                                                  "${i + 1}ª $playerName",
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                  ),
                                                );
                                              },
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              "Registrado por: ${matche.registerByUid}",
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontStyle: FontStyle.italic,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}
