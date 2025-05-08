import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:unoverse/presentation/widgets/group_card.dart';
import 'package:unoverse/presentation/widgets/show_form_modal.dart';

import '../../../data/services/group_provider.dart';
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

  UserEntity user = UserEntity(groupsId: []);

  @override
  void initState() {
    super.initState();
    initData();
  }

  void initData() async {
    user = await userService.readUser().then((user) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Provider.of<GroupProvider>(
          context,
          listen: false,
        ).loadGroups(user.groupsId);
      });
      return user;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Group> groups = context.watch<GroupProvider>().groups;
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
              print('Name Group: ${groups[0].name}');
              refresh();
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
                  itemCount: groups.length,
                  itemBuilder: (context, index) {
                    final group = groups[index];

                    return GroupCard(group: group);
                  },
                ),
              ),
    );
  }

  refresh() async {
    final UserEntity updatedUser = await userService.readUser();

    Provider.of<GroupProvider>(
      context,
      listen: false,
    ).loadGroups(updatedUser.groupsId);
  }
}
