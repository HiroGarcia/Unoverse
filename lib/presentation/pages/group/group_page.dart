import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unoverse/data/services/player_provider.dart';
import 'package:unoverse/domain/entity/enum_type.dart'; // Importe se showFormModal precisar

import '../../../domain/entity/group_entity.dart';
import '../../widgets/show_form_dialog.dart'; // Importe se showFormModal precisar

class GroupPage extends StatefulWidget {
  final Group group;
  const GroupPage({required this.group, super.key});

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
    return Scaffold(
      appBar: AppBar(title: Text(widget.group.name)),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showFormDialog(
            context: context,
            type: EnumType.player,
            groupId: widget.group.groupId,
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
                  itemCount: listPlayer.length,
                  itemBuilder: (context, index) {
                    return Card(
                      color: Theme.of(context).colorScheme.secondary,
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
