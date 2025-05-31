import 'dart:async';
import 'package:flutter/foundation.dart';

import '../../domain/entity/group_entity.dart';
import '../services/group_service.dart';

import 'user_provider.dart';

class GroupProvider with ChangeNotifier {
  final GroupService groupService;

  final UserProvider _userProvider;

  List<Group> _groups = [];
  List<Group> get groups => _groups;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Map<String, String> _failedGroupsErrors = {};
  Map<String, String> get failedGroupsErrors => _failedGroupsErrors;

  StreamSubscription<List<GroupFetchResult>>? _groupsResultsSubscription;

  // Armazena a lista de IDs que está sendo atualmente "escutada"
  List<String> _currentlyStreamingGroupIds = [];

  // Construtor: Aceita GroupService E UserProvider
  GroupProvider({
    required this.groupService,
    required UserProvider userProvider,
  }) : _userProvider =
           userProvider // Armazena a referência do UserProvider
           {
    print("GroupProvider: CONSTRUTOR chamado.");
    // Adiciona um listener ao UserProvider para ser notificado sobre mudanças
    _userProvider.addListener(_handleUserProviderChange);

    // Chama o handler inicial para carregar os grupos com base no estado atual do UserProvider
    // Isso substitui a chamada inicial que o ProxyProvider fazia.
    _handleUserProviderChange();
  }

  // Método privado chamado quando o UserProvider chama notifyListeners()
  void _handleUserProviderChange() async {
    print("GroupProvider: _handleUserProviderChange (listener) chamado.");
    // Obtém a nova lista de groupIds do UserProvider (que pode ser nulo se deslogou)
    final newGroupIds = _userProvider.user?.groupsId ?? [];
    print(
      "GroupProvider: _handleUserProviderChange - nova lista de IDs recebida: $newGroupIds",
    );

    // Usa listEquals para comparar as listas de forma eficiente
    bool listsDiffer = !listEquals(_currentlyStreamingGroupIds, newGroupIds);

    if (listsDiffer) {
      print("GroupProvider: Lista de groupIds mudou. Atualizando stream.");

      await Future.delayed(const Duration(milliseconds: 400));
      // Cancelar a assinatura antiga se existir
      _groupsResultsSubscription?.cancel();
      _groupsResultsSubscription = null; // Limpa a referência

      _currentlyStreamingGroupIds = newGroupIds; // Atualiza a lista que estamos "escutando"

      // Limpa a lista de grupos e possíveis erros anteriores
      _groups = [];
      _failedGroupsErrors = {}; // Limpa erros

      // Se a nova lista de IDs não estiver vazia, inicie a nova escuta
      if (newGroupIds.isNotEmpty) {
        print(
          "GroupProvider: Iniciando nova escuta de stream de resultados para ${newGroupIds.length} IDs.",
        );
        // Iniciar carregamento
        _isLoading = true;
        notifyListeners(); // Notifica que o carregamento começou

        // Chame o método do Service que retorna Stream<List<GroupFetchResult>>
        _groupsResultsSubscription = groupService
            .streamGroupResults(newGroupIds)
            .listen(
              (listOfResults) {
                // Este callback é chamado toda vez que qualquer snapshot na lista muda ou falha
                print(
                  "GroupProvider: Stream de resultados atualizado. Recebidos ${listOfResults.length} resultados.",
                );

                List<Group> loadedGroups = [];
                Map<String, String> currentFailedGroups = {};

                // Itere sobre a lista de resultados
                for (var result in listOfResults) {
                  if (result.isSuccess) {
                    loadedGroups.add(result.group!);
                  } else if (result.isFailure) {
                    print(
                      "GroupProvider: Grupo ${result.groupId} falhou ao carregar: ${result.error}",
                    );
                    currentFailedGroups[result.groupId] = result.error.toString();
                  } else if (result.isNotFound) {
                    print(
                      "GroupProvider: Grupo ${result.groupId} não encontrado no Firestore.",
                    );
                    currentFailedGroups[result.groupId] = "Não encontrado";
                  }
                }

                _groups = loadedGroups;
                _isLoading = false;

                _failedGroupsErrors = currentFailedGroups;

                // Opcional: logar se nenhum grupo carregou
                if (_groups.isEmpty && _currentlyStreamingGroupIds.isNotEmpty && !isLoading) {
                  print(
                    "GroupProvider: Nenhum grupo carregado dos IDs fornecidos. Possível problema de permissão para todos.",
                  );
                }

                notifyListeners(); // Notifica widgets que a lista de grupos mudou
              },
              onError: (error, stackTrace) {
                print(
                  "GroupProvider: Erro fatal no listener do stream de grupos: $error",
                );
                print(stackTrace);
                _isLoading = false;
                _groups = [];
                _failedGroupsErrors = {'fatal': error.toString()};
                notifyListeners();
              },
            );
      } else {
        // Se a nova lista de IDs estiver vazia (ex: usuário deslogou), limpe a lista e notifique
        print(
          "GroupProvider: Nova lista de groupIds está vazia. Limpando lista de grupos e cancelando stream.",
        );
        _groups = [];
        _isLoading = false;
        _failedGroupsErrors = {};
        notifyListeners();
      }
    } else {
      print(
        "GroupProvider: Lista de groupIds não mudou. Mantendo stream atual.",
      );
    }
  }

  // Método para descarte: ESSENCIAL para remover o listener do UserProvider e cancelar streams
  @override
  void dispose() {
    print(
      "GroupProvider: dispose chamado. Removendo listener do UserProvider e cancelando stream.",
    );
    // Remove o listener do UserProvider ANTES de cancelar as assinaturas e chamar super.dispose
    _userProvider.removeListener(_handleUserProviderChange);
    _groupsResultsSubscription?.cancel();
    _groupsResultsSubscription = null;
    // Não precisa limpar _groups, etc aqui, pois dispose significa que o Provider está morrendo
    super.dispose();
  }
}
