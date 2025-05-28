import 'package:flutter/material.dart';
import '../../../data/services/matche_service.dart';
import '../../../domain/entity/matche_entity.dart';
import '../../../domain/entity/player_entity.dart';

class MyHistoryList extends StatelessWidget {
  final String groupId;
  final List<Player> sortedPlayers;

  const MyHistoryList({
    super.key,
    required this.groupId,
    required this.sortedPlayers,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<MatcheEntity>>(
      stream: MatcheService().streamMatches(groupId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("Nenhuma partida registrada."));
        }
        final matches = snapshot.data!;
        return GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.1,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: matches.length,
          itemBuilder: (context, index) {
            final matche = matches[index];
            final sortedWinners =
                matche.poitns.entries.toList()
                  ..sort((a, b) => b.value.compareTo(a.value));
            return Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Partida ${matche.dateTime.day.toString().padLeft(2, '0')}/"
                      "${matche.dateTime.month.toString().padLeft(2, '0')}/"
                      "${matche.dateTime.year} "
                      "${matche.dateTime.hour.toString().padLeft(2, '0')}:"
                      "${matche.dateTime.minute.toString().padLeft(2, '0')}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Ganhadores:",
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    ...List.generate(
                      sortedWinners.length,
                      (i) {
                        final playerName =
                            sortedPlayers
                                .firstWhere(
                                  (p) => p.playerId == sortedWinners[i].key,
                                  orElse:
                                      () => Player(
                                        playerId: '',
                                        name: 'Desconhecido',
                                        totalScore: 0,
                                        totalMatches: 0,
                                        totalMatchesPlayed: 0,
                                      ),
                                )
                                .name;
                        return Text(
                          "${i + 1}ª $playerName",
                          style: const TextStyle(fontSize: 13),
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
    );
  }
}
