import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unoverse/data/services/player_provider.dart';
import 'package:unoverse/domain/entity/enum_type.dart';

import '../../../domain/entity/group_entity.dart';
import '../../widgets/show_form_modal.dart';

class GroupPage extends StatelessWidget {
  final Group group;
  const GroupPage({required this.group, super.key});

  @override
  Widget build(BuildContext context) {
    context.read<PlayerProvider>().listenToPlayers(group.groupId);
    final listPlayer = context.watch<PlayerProvider>().players;
    return Scaffold(
      appBar: AppBar(title: Text(group.name)),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showFormModal(
            context: context,
            type: EnumType.player,
            groupId: group.groupId,
          );
        },
        child: Icon(Icons.add),
      ),
      body:
          (listPlayer.isEmpty)
              ? const Center(
                child: Text(
                  "Nenhuma lista ainda.\nVamos criar a primeira?",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18),
                ),
              )
              : Container(
                color: Colors.blue[50],
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 200,
                  ),
                  itemCount: listPlayer.length,
                  itemBuilder: (context, index) {
                    return Card(
                      color: Colors.amber,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              listPlayer[index].name,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Pontuação total: ${listPlayer[index].totalScore}',
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
    );
  }
}
