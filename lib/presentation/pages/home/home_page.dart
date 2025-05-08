import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:unoverse/presentation/widgets/group_card.dart';
import 'package:unoverse/presentation/widgets/show_form_modal.dart';

import '../../../data/services/group_provider.dart';
import '../../../data/services/user_provider.dart';

import '../../../domain/entity/enum_type.dart';

class HomePage extends StatelessWidget {
  final User userAuth;
  const HomePage({super.key, required this.userAuth});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;
    final groups = context.watch<GroupProvider>().groups;
    if (user == null) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (groups.isEmpty && user.groupsId.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Provider.of<GroupProvider>(
          context,
          listen: false,
        ).loadGroups(user.groupsId);
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Unoverse Groups'),
        actions: [
          IconButton(
            onPressed: () {
              print('--------------');
              print('Nome: ${userAuth.displayName}');
              print('Email: ${user.email}');
              print('Avatar: ${userAuth.photoURL}');
              print('Grupos: ${user.groupsId}');
              print('Name Group: ${groups[0].name}');
              print(groups.length);
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
            uid: userAuth.uid,
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
}
