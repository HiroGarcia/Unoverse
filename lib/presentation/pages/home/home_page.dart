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

    // A lógica para mostrar "Nenhuma lista ainda" agora usa a lista de grupos REAL
    // que veio do stream, E verifica se a lista groupIds do usuário está vazia.
    // Também podemos mostrar um indicador de carregamento para os grupos.
    if (user.groupsId.isEmpty) {
      // Se a lista de groupIds do usuário está vazia, não há grupos para carregar/mostrar
      print("HomePage: user.groupsId está vazia. Mostrando mensagem inicial.");
      return Scaffold(
        appBar: AppBar(title: Text('Unoverse Groups')), // Adapte seu AppBar
        drawer: Drawer(), // Adapte seu Drawer
        floatingActionButton: FloatingActionButton(
          // Adapte seu FAB
          onPressed: () {
            // Lógica para criar novo grupo (usando userAuth.uid para o criador)
            // Você pode precisar acessar o GroupService a partir daqui ou de um Consumer/outro método
            print("FAB Pressionado");
            // Exemplo de como chamar showFormModal se ainda usar:
            // showFormModal(context: context, uid: userAuth.uid, type: EnumType.group);
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
    // Se a lista groupIds NÃO está vazia, mas os grupos AINDA estão carregando
    if (isLoadingGroups && groups.isEmpty) {
      print(
        "HomePage: groupIds não está vazia, mas grupos estão carregando e _groups está vazia. Mostrando indicador.",
      );
      return Scaffold(
        appBar: AppBar(title: Text('Unoverse Groups')), // Adapte seu AppBar
        drawer: Drawer(), // Adapte seu Drawer
        floatingActionButton: FloatingActionButton(
          // Adapte seu FAB
          onPressed: () {
            print("FAB Pressionado (durante loading)");
            // showFormModal(...);
          },
          child: Icon(Icons.add),
        ),
        body: Center(
          child: CircularProgressIndicator(),
        ), // Mostra indicador enquanto carrega
      );
    }

    // Se chegamos aqui, o usuário não é null, groupIds não está vazia,
    // e a lista `groups` contém os grupos carregados (pode ser vazia se nenhum grupo
    // foi encontrado ou o usuário não tem permissão para nenhum ID na lista).
    // A lista `groups` é a que veio do stream.

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
            // (user.groupsId.isEmpty)
            //     ? const Center(
            //       child: Text(
            //         "Nenhuma lista ainda.\nVamos criar a primeira?",
            //         textAlign: TextAlign.center,
            //         style: TextStyle(fontSize: 18),
            //       ),
            //     )
            groups.isEmpty &&
                    !isLoadingGroups // Verifica se a lista está vazia APÓS carregar (ou se o usuário não tem permissão para nenhum ID na lista)
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
