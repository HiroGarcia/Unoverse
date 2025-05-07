import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:unoverse/presentation/pages/group/group_page.dart';
import 'package:unoverse/presentation/widgets/show_form_modal.dart';

import '../../../data/services/group_service.dart';
import '../../../data/services/user_service.dart';
import '../../../domain/entity/enum_type.dart';
import '../../../domain/entity/group_entity.dart';
import '../../../domain/entity/user_entity.dart';

class HomePage extends StatefulWidget {
  final User user;
  const HomePage({super.key, required this.user});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  UserService userService = UserService();
  GroupService groupService = GroupService();
  List<Group> listGroup = [];
  FirebaseAuth status = FirebaseAuth.instance;

  UserEntity user = UserEntity(groupsId: []);

  @override
  void initState() {
    refresh();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Unoverse Groups'),
        actions: [
          IconButton(
            onPressed: () {
              print('--------------');
              print('Nome: ${widget.user.displayName}');
              print('Email: ${widget.user.email}');
              print('Avatar: ${widget.user.photoURL}');
              print('Grupos: ${user.groupsId}');
              print('Name Group: ${listGroup[0].name}');
            },
            icon: Icon(Icons.mode_edit_sharp),
            color: Colors.black,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showFormModal(
            context: context,
            uid: widget.user.uid,
            type: EnumType.group,
          );
        },
        child: Icon(Icons.add),
      ),
      drawer: Drawer(),
      body:
          (user.groupsId.isEmpty)
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
                  itemCount: listGroup.length,
                  itemBuilder: (context, index) {
                    final group = listGroup[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GroupPage(group: group),
                          ),
                        );
                      },
                      child: Card(
                        color: Colors.amber,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                group.name,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text('ID: ${group.groupId}'),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
    );
  }

  refresh() async {
    user = await userService.readUser();

    try {
      if (user.groupsId.isNotEmpty) {
        List<Group> lisGroup = await groupService.readGroup(
          groupId: user.groupsId,
        );
        listGroup = lisGroup;
      } else {
        listGroup = [];
      }
    } on FirebaseException catch (e) {
      print('Erro fire ao carregar grupos: $e');
    } catch (e) {
      print('Erro ao carregar grupos: $e');
    }
    setState(() {});
  }
}
