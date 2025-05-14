// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import '../../domain/entity/group_entity.dart';
// import '../services/group_service.dart';

// class GroupProvider with ChangeNotifier {
//   final GroupService groupService;

//   List<Group> _groups = [];
//   List<Group> get groups => _groups;

//   bool _isLoading = false;
//   bool get isLoading => _isLoading;

//   GroupProvider({required this.groupService});

//   Future<void> loadGroups(List<String> groupIds) async {
//     _isLoading = true;
//     notifyListeners();

//     try {
//       if (groupIds.isNotEmpty) {
//         _groups = await groupService.readGroup(groupId: groupIds);
//       } else {
//         _groups = [];
//       }
//     } catch (e) {
//       print("Erro ao carregar grupos: $e");
//     }

//     _isLoading = false;
//     notifyListeners();
//   }
// }

import 'dart:async'; // Importe para StreamSubscription
import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart'; // Não precisa de material.dart se for só ChangeNotifier
import '../../domain/entity/group_entity.dart';
import '../services/group_service.dart';

class GroupProvider with ChangeNotifier {
  final GroupService groupService;

  List<Group> _groups = [];
  List<Group> get groups => _groups;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Armazena a assinatura do stream
  StreamSubscription<List<Group>>? _groupsSubscription;

  // Armazena a lista de IDs que está sendo atualmente "escutada"
  List<String> _currentlyStreamingGroupIds = [];

  GroupProvider({required this.groupService});

  // Este método é chamado pelo ProxyProvider sempre que o UserProvider atualiza
  void updateUserGroupIds(List<String> newGroupIds) {
    // Use listEquals para comparar as listas de forma eficiente
    bool listsDiffer = !listEquals(_currentlyStreamingGroupIds, newGroupIds);

    if (listsDiffer) {
      print("Lista de groupIds mudou. Atualizando stream.");
      // Cancelar a assinatura antiga se existir
      _groupsSubscription?.cancel();
      _groupsSubscription = null; // Limpa a referência

      _currentlyStreamingGroupIds =
          newGroupIds; // Atualiza a lista que estamos "escutando"

      // Se a nova lista de IDs não estiver vazia, inicie a nova escuta
      if (newGroupIds.isNotEmpty) {
        // Iniciar carregamento (opcional, pode remover se a UI lidar com a lista vazia inicial)
        _isLoading = true;
        notifyListeners(); // Notifica que o carregamento começou

        _groupsSubscription = groupService
            .streamGroups(newGroupIds)
            .listen(
              (listOfGroups) {
                // Este callback é chamado toda vez que qualquer grupo na lista muda
                print(
                  "Stream de grupos atualizado. ${listOfGroups.length} grupos recebidos.",
                );
                _groups =
                    listOfGroups; // Atualiza a lista de grupos no Provider
                _isLoading =
                    false; // Carregamento terminou (pelo menos o primeiro evento)
                notifyListeners(); // Notifica widgets que a lista de grupos mudou
              },
              onError: (error) {
                print("Erro no listener do stream de grupos: $error");
                _isLoading = false; // Carregamento terminou com erro
                // Opcional: Limpar lista de grupos ou definir estado de erro
                _groups = []; // Limpa a lista em caso de erro no stream
                notifyListeners(); // Notifica que houve um erro
              },
              // optional: onDone
            );
      } else {
        // Se a nova lista de IDs estiver vazia, limpe a lista de grupos e notifique
        print("Nova lista de groupIds está vazia. Limpando lista de grupos.");
        _groups = [];
        _isLoading = false;
        notifyListeners();
      }
    } else {
      //print("Lista de groupIds não mudou. Mantendo stream atual.");
      // Nada a fazer se a lista de IDs for a mesma
    }
  }

  // Método para descarte: ESSENCIAL para cancelar a assinatura do stream
  @override
  void dispose() {
    print("GroupProvider: Cancelando assinatura do stream.");
    _groupsSubscription
        ?.cancel(); // Cancela a assinatura para evitar vazamentos de memória
    super.dispose();
  }

  // Remova ou adapte o método loadGroups baseado em Future, pois a leitura
  // principal agora será via stream. Se você ainda precisar de uma leitura
  // única em algum lugar, mantenha o método readGroup no GroupService
  // e chame ele diretamente onde necessário (fora do fluxo principal de display).
  //
  // Exemplo: Se precisar carregar uma lista de grupos UMA ÚNICA VEZ para
  // alguma tela ou funcionalidade específica que não precise de real-time.
  // Future<void> loadGroupsOnce(List<String> groupIds) async {
  //    _isLoading = true;
  //    notifyListeners();
  //    try {
  //      _groups = await groupService.readGroup(groupId: groupIds);
  //    } catch (e) {
  //      print("Erro ao carregar grupos (one-time): $e");
  //    }
  //    _isLoading = false;
  //    notifyListeners();
  // }

  // Mantenha o método loadGroups atual que você mostrou se ele for
  // usado APENAS internamente pelo updateUserGroupIds para iniciar a escuta,
  // mas o nome updateUserGroupIds talvez seja mais claro para o que ele faz.
  // Vamos manter updateUserGroupIds chamando streamGroups e gerenciando a assinatura.
  // Portanto, o método loadGroups como estava (Future) pode ser removido ou adaptado.

  // Exemplo: Remover o método loadGroups Future se ele não for mais usado externamente
  // Future<void> loadGroups(List<String> groupIds) async { /* Removido */ }
}
