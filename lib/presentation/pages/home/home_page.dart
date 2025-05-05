import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:unoverse/domain/entity/group_entity.dart';
import 'package:unoverse/domain/entity/user_entity.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  UserService userService = UserService();
  GroupService groupService = GroupService();
  List<Group> listGroup = [];

  UserEntity? user;
  late Future<UserEntity> futureUser;

  @override
  void initState() {
    futureUser = userService.readUser();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserEntity>(
      future: futureUser,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return const Scaffold(
            body: Center(child: Text('Erro ao carregar usuário')),
          );
        }
        final userData = snapshot.data!;
        user ??= userData;

        if (listGroup.isEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            refresh();
          });
        }
        return Scaffold(
          appBar: AppBar(
            title: Text('Unoverse Groups'),
            actions: [
              IconButton(
                onPressed: () async {
                  print('--------------');
                  print('Nome: ${user!.name}');
                  print('Email: ${user!.email}');
                  print('Avatar: ${user!.avatar}');
                  print('Grupos: ${user!.groupsId}');
                  print('Name Group: ${listGroup[0].name}');
                },
                icon: Icon(Icons.mode_edit_sharp),
                color: Colors.black,
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              refresh();
            },
            child: Icon(Icons.add),
          ),
          drawer: Drawer(),
          body: Container(
            color: Colors.blue[50],
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200,
              ),
              itemCount: listGroup.length,
              itemBuilder: (context, index) {
                final group = listGroup[index];
                return Card(
                  color: Colors.amber,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          group.name,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text('ID: ${group.groupId}'),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  refresh() async {
    try {
      List<Group> lisGroup = await groupService.readGroup(
        groupId: user!.groupsId[0],
      );
      listGroup = lisGroup;
    } on FirebaseException catch (e) {
      print('Erro fire ao carregar grupos: $e');
    } catch (e) {
      print('Erro ao carregar grupos: $e');
    }
    setState(() {});
  }
}
