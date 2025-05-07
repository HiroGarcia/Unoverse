import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:unoverse/domain/entity/enum_type.dart';

import '../../../data/services/player_service.dart';
import '../../../domain/entity/group_entity.dart';
import '../../../domain/entity/player_entity.dart';
import '../../widgets/show_form_modal.dart';

class GroupPage extends StatefulWidget {
  final Group group;
  const GroupPage({required this.group, super.key});

  @override
  State<GroupPage> createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupPage> {
  List<Player> listPlayer = [];

  PlayerService playerService = PlayerService();

  @override
  void initState() {
    refresh();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.group.name)),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showFormModal(
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

  refresh() async {
    try {
      listPlayer = await playerService.readPlayer(
        groupId: widget.group.groupId,
      );
      setState(() {});
    } on FirebaseException catch (e) {
      print('Erro: ${e.code}');
    } catch (e) {
      print('Erro: $e');
    }
  }
}
