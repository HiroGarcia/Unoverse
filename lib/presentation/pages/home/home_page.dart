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
        drawer: Drawer(),
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
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
        drawer: Drawer(),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            print("FAB Pressionado (durante loading)");
          },
          child: Icon(Icons.add),
        ),
        body: Center(child: CircularProgressIndicator()),
      );
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
                  onValid: () async {
                    print('--------------');
                    print('Nome: ${userAuth.displayName}');
                    print('Email: ${user.email}');
                    print('Avatar: ${userAuth.photoURL}');
                    print('Grupos: ${user.groupsId}');
                    print('Name Group: ${groups[0].name}');
                    print(groups.length);
                    try {
                      Provider.of<GroupProvider>(
                        context,
                        listen: false,
                      ).resetForSignOut();
                      Provider.of<UserProvider>(
                        context,
                        listen: false,
                      ).resetForSignOut();
                      await sair.signOut();
                      print("Sair.signOut() concluído.");
                    } catch (e) {
                      print("Erro durante o processo de logout: $e");
                    }
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
                    itemCount: groups.length + 1,
                    itemBuilder: (context, index) {
                      if (index < groups.length) {
                        final group = groups[index];
                        return GroupCard(group: group, uid: userAuth.uid);
                      } else {
                        return Card(
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
