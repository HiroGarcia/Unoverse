import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unoverse/presentation/pages/home/add_new_group.dart';

import 'package:unoverse/presentation/widgets/my_card.dart';
import 'package:unoverse/presentation/widgets/my_drawer.dart';
import 'package:unoverse/presentation/widgets/show_form_dialog.dart';

import '../../../data/providers/group_provider.dart';
import '../../../data/providers/user_provider.dart';

import '../../../domain/enums/enum_type.dart';
import '../../../controllers/card_flip_controller.dart';

class HomePage extends StatelessWidget {
  final User userAuth;
  const HomePage({super.key, required this.userAuth});

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final user = userProvider.user;

    final groupProvider = context.watch<GroupProvider>();
    final groups = groupProvider.groups;
    final isLoadingGroups = groupProvider.isLoading;

    if (user == null) {
      print(
        "HomePage: Usuário do Provider é null, mostrando CircularProgressIndicator.",
      );
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (user.groupsId.isEmpty) {
      print("HomePage: user.groupsId está vazia. Mostrando mensagem inicial.");
      return Scaffold(
        appBar: AppBar(title: Text('Unoverse Groups')),
        drawer: MyDrawer(),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            handleInteractionOrReset(
              context: context,
              onValid:
                  () => showFormDialog(
                    context: context,
                    uid: userAuth.uid,
                    type: EnumType.group,
                  ),
            );
          },
          child: Icon(Icons.add),
        ),
        body: const Center(
          child: Text(
            "Nenhuma lista ainda.\nVamos criar a primeira?",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18),
          ),
        ),
      );
    }
    if (isLoadingGroups && groups.isEmpty) {
      print(
        "HomePage: groupIds não está vazia, mas grupos estão carregando e _groups está vazia. Mostrando indicador.",
      );
      return Scaffold(
        appBar: AppBar(title: Text('Unoverse Groups')),
        drawer: MyDrawer(),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            handleInteractionOrReset(
              context: context,
              onValid:
                  () => showFormDialog(
                    context: context,
                    uid: userAuth.uid,
                    type: EnumType.group,
                  ),
            );
          },
          child: Icon(Icons.add),
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }
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
                    addNewGroup(context: context);
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
                  () => showFormDialog(
                    context: context,
                    uid: userAuth.uid,
                    type: EnumType.group,
                  ),
            );
          },
          child: Icon(Icons.add),
        ),
        drawer: MyDrawer(),
        body:
            groups.isEmpty && !isLoadingGroups
                ? const Center(
                  child: Text(
                    "Você está em grupos, mas nenhum pôde ser carregado.\nVerifique as permissões.",
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
                    itemCount: groups.length,
                    itemBuilder: (context, index) {
                      return MyCard(
                        group: groups[index],
                        uid: userAuth.uid,
                        enumType: EnumType.group,
                      );
                    },
                  ),
                ),
      ),
    );
  }
}
