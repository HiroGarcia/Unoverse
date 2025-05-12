import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:unoverse/presentation/widgets/group_card.dart';
import 'package:unoverse/presentation/widgets/show_form_modal.dart';

import '../../../data/services/group_provider.dart';
import '../../../data/services/user_provider.dart';

import '../../../domain/entity/enum_type.dart';
import '../../controllers/card_flip_controller.dart';

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
    FirebaseAuth sair = FirebaseAuth.instance;
    return GestureDetector(
      onTap: () {
        context.read<CardFlipController>().reset();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Unoverse Groups'),

          actions: [
            IconButton(
              onPressed: () {
                handleInteractionOrReset(
                  context: context,
                  onValid: () {
                    print('--------------');
                    print('Nome: ${userAuth.displayName}');
                    print('Email: ${user.email}');
                    print('Avatar: ${userAuth.photoURL}');
                    print('Grupos: ${user.groupsId}');
                    print('Name Group: ${groups[0].name}');
                    print(groups.length);
                    sair.signOut();
                  },
                );
              },
              icon: Icon(Icons.mode_edit_sharp),
              color: Theme.of(context).colorScheme.primary,
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            handleInteractionOrReset(
              context: context,
              onValid:
                  () => showFormModal(
                    context: context,
                    uid: userAuth.uid,
                    type: EnumType.group,
                  ),
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
                  padding: EdgeInsets.only(top: 10, left: 10, right: 10),
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 200,
                      mainAxisSpacing: 3,
                      crossAxisSpacing: 3,
                      childAspectRatio: 0.6437,
                    ),
                    itemCount: groups.length + 1,
                    itemBuilder: (context, index) {
                      if (index < groups.length) {
                        final group = groups[index];
                        return GroupCard(group: group, uid: userAuth.uid);
                      } else {
                        return Card(
                          // color: Colors.blueGrey[50],
                          color: Theme.of(context).colorScheme.secondary,
                          elevation: 2,
                          margin: const EdgeInsets.all(32.0),
                          shape: CircleBorder(),
                          child: InkWell(
                            onTap: null,
                            borderRadius: BorderRadius.circular(14),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add,
                                    size: 60,
                                    color: Colors.black38,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ),
      ),
    );
  }
}
