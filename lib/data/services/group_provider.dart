import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../domain/entity/group_entity.dart';
import '../services/group_service.dart';

class GroupProvider with ChangeNotifier {
  final GroupService groupService;

  List<Group> _groups = [];
  List<Group> get groups => _groups;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Map<String, String> _failedGroupsErrors = {};
  Map<String, String> get failedGroupsErrors => _failedGroupsErrors;

  StreamSubscription<List<GroupFetchResult>>? _groupsResultsSubscription;

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
      _groupsResultsSubscription?.cancel();
      _groupsResultsSubscription = null; // Limpa a referência

      _currentlyStreamingGroupIds =
          newGroupIds; // Atualiza a lista que estamos "escutando"

      // Limpa a lista de grupos e possíveis erros anteriores
      _groups = [];
      // Se a nova lista de IDs não estiver vazia, inicie a nova escuta
      if (newGroupIds.isNotEmpty) {
        print(
          "GroupProvider: Iniciando nova escuta de stream de resultados para ${newGroupIds.length} IDs.",
        );
        // Iniciar carregamento (opcional, pode remover se a UI lidar com a lista vazia inicial)
        _isLoading = true;
        notifyListeners(); // Notifica que o carregamento começou

        // Chame o novo método do Service que retorna Stream<List<DocumentSnapshot>>
        _groupsResultsSubscription = groupService
            .streamGroupResults(newGroupIds)
            .listen(
              (listOfResults) {
                // Este callback é chamado toda vez que qualquer snapshot na lista muda ou falha
                print(
                  "GroupProvider: Stream de snapshots atualizado. Recebidos ${listOfResults.length} snapshots.",
                );

                List<Group> loadedGroups = [];
                Map<String, String> currentFailedGroups =
                    {}; // Para rastrear falhas neste ciclo

                // Itere sobre a lista de snapshots
                for (var result in listOfResults) {
                  if (result.isSuccess) {
                    // Se o resultado é um sucesso, adicione o grupo à lista
                    loadedGroups.add(
                      result.group!,
                    ); // 'group!' é seguro porque isSuccess verifica null
                  } else if (result.isFailure) {
                    // Se o resultado é uma falha (erro de permissão, etc.)
                    print(
                      "GroupProvider: Grupo ${result.groupId} falhou ao carregar: ${result.error}",
                    );
                    currentFailedGroups[result.groupId] =
                        result.error.toString(); // Armazena o erro
                  } else if (result.isNotFound) {
                    // Se o documento não foi encontrado no Firestore
                    print(
                      "GroupProvider: Grupo ${result.groupId} não encontrado no Firestore.",
                    );
                    currentFailedGroups[result.groupId] =
                        "Não encontrado"; // Opcional: armazena status
                  }
                }

                _groups = loadedGroups;
                _isLoading = false;

                _failedGroupsErrors = currentFailedGroups;

                if (_groups.isEmpty &&
                    _currentlyStreamingGroupIds.isNotEmpty &&
                    !isLoading) {
                  print(
                    "GroupProvider: Nenhum grupo carregado dos IDs fornecidos. Possível problema de permissão para todos.",
                  );
                }

                notifyListeners(); // Notifica widgets que a lista de grupos mudou
              },
              onError: (error, stackTrace) {
                // Este onError só é chamado para erros que o stream combinado não tratou individualmente
                print(
                  "GroupProvider: Erro fatal no listener do stream de grupos: $error",
                );
                print(stackTrace); // Opcional: logar o stack trace
                _isLoading = false; // Carregamento terminou com erro
                _groups =
                    []; // Limpa a lista de grupos em caso de erro fatal no stream
                _failedGroupsErrors = {
                  'fatal': error.toString(),
                }; // Opcional: sinaliza erro fatal
                notifyListeners(); // Notifica que houve um erro fatal
              },
              // optional: onDone
            );
      } else {
        // Se a nova lista de IDs estiver vazia, limpe a lista de grupos e notifique
        print(
          "GroupProvider: Nova lista de groupIds está vazia. Limpando lista de grupos e cancelando stream.",
        );
        _groups = [];
        _isLoading = false; // Ensure loading state is false
        _failedGroupsErrors = {}; // Limpa erros
        notifyListeners();
      }
    } else {
      print(
        "GroupProvider: Lista de groupIds não mudou. Mantendo stream atual.",
      );
    }
  }

  // Método para descarte: ESSENCIAL para cancelar a assinatura do stream
  @override
  void dispose() {
    print("GroupProvider: Cancelando assinatura do stream.");
    resetForSignOut();
    super.dispose();
  }

  void resetForSignOut() {
    print("GroupProvider: Resetando estado no logout.");
    _groupsResultsSubscription?.cancel();
    _groupsResultsSubscription = null;
    _currentlyStreamingGroupIds = [];
    _groups = [];
    _isLoading = false;
    _failedGroupsErrors = {};
    notifyListeners();
  }
}
