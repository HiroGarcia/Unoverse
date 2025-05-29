import 'package:flutter/material.dart';
import 'package:unoverse/controllers/matche_controller.dart';
import '../../../domain/entity/player_entity.dart';

Future<void> addNewMatche({
  required BuildContext context,
  required List<Player> players,
  required String groupId,
  required Map<String, int> config,
}) async {
  Player? firstPlace;
  Player? secondPlace;
  Player? thirdPlace;
  MatcheController matcheController = MatcheController();

  Future<Player?> selectPlayerDialog(
    BuildContext context,
    List<Player> availablePlayers,
    Player? currentSelection,
    String title,
  ) async {
    int selectedIndex =
        currentSelection != null
            ? availablePlayers.indexWhere(
              (p) => p.playerId == currentSelection.playerId,
            )
            : 0;

    return await showDialog<Player>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: SizedBox(
            width: 300,
            height: 350,
            child: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: availablePlayers.length,
                        itemBuilder: (context, index) {
                          final player = availablePlayers[index];
                          return ListTile(
                            title: Text(player.name),
                            selected: selectedIndex == index,
                            onTap: () {
                              Navigator.of(context).pop(player);
                            },
                          );
                        },
                      ),
                    ),
                    if (availablePlayers.isEmpty) const Text('Nenhum jogador disponível'),
                  ],
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          List<Player> availableForFirst = players;
          List<Player> availableForSecond =
              players
                  .where(
                    (p) => firstPlace == null || p.playerId != firstPlace!.playerId,
                  )
                  .toList();
          List<Player> availableForThird =
              players
                  .where(
                    (p) => (firstPlace == null || p.playerId != firstPlace!.playerId) && (secondPlace == null || p.playerId != secondPlace!.playerId),
                  )
                  .toList();

          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Adicionar Partida'),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: 'Fechar',
                ),
              ],
            ),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              height: 300,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: const Text('1º Lugar'),
                    subtitle: Text(firstPlace?.name ?? 'Selecionar jogador'),
                    trailing: const Icon(Icons.arrow_drop_down),
                    onTap: () async {
                      final selected = await selectPlayerDialog(
                        context,
                        availableForFirst,
                        firstPlace,
                        'Selecione o 1º Lugar',
                      );
                      if (selected != null) {
                        setState(() {
                          firstPlace = selected;
                          if (secondPlace?.playerId == selected.playerId) {
                            secondPlace = null;
                          }
                          if (thirdPlace?.playerId == selected.playerId) {
                            thirdPlace = null;
                          }
                        });
                      }
                    },
                  ),
                  ListTile(
                    title: const Text('2º Lugar'),
                    subtitle: Text(secondPlace?.name ?? 'Selecionar jogador'),
                    trailing: const Icon(Icons.arrow_drop_down),
                    onTap:
                        firstPlace == null
                            ? null
                            : () async {
                              final selected = await selectPlayerDialog(
                                context,
                                availableForSecond,
                                secondPlace,
                                'Selecione o 2º Lugar',
                              );
                              if (selected != null) {
                                setState(() {
                                  secondPlace = selected;
                                  if (thirdPlace?.playerId == selected.playerId) {
                                    thirdPlace = null;
                                  }
                                });
                              }
                            },
                  ),
                  ListTile(
                    title: const Text('3º Lugar'),
                    subtitle: Text(thirdPlace?.name ?? 'Selecionar jogador'),
                    trailing: const Icon(Icons.arrow_drop_down),
                    onTap:
                        (firstPlace == null || secondPlace == null)
                            ? null
                            : () async {
                              final selected = await selectPlayerDialog(
                                context,
                                availableForThird,
                                thirdPlace,
                                'Selecione o 3º Lugar',
                              );
                              if (selected != null) {
                                setState(() {
                                  thirdPlace = selected;
                                });
                              }
                            },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed:
                    (firstPlace != null && secondPlace != null && thirdPlace != null)
                        ? () {
                          matcheController.addMatche(
                            groupId: groupId,
                            config: {
                              firstPlace!.playerId: config['primeiro']!,
                              secondPlace!.playerId: config['segundo']!,
                              thirdPlace!.playerId: config['terceiro']!,
                            },
                          );
                          Navigator.pop(context);
                        }
                        : null,
                child: const Text('Salvar'),
              ),
            ],
          );
        },
      );
    },
  );
}
