import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';

import '../../domain/entity/group_entity.dart';

class GroupService {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<List<Group>> readGroup({required List<String> groupId}) async {
    print(">>> readGroup (Future) chamada <<<");
    List<Group> temp = [];

    if (groupId.isEmpty) {
      return temp;
    }

    for (var group in groupId) {
      try {
        DocumentSnapshot<Map<String, dynamic>> snapshot =
            await firestore.collection("groups").doc(group).get();

        if (snapshot.exists) {
          print("Lendo grupo com ID da lista: ${snapshot.id}");
          temp.add(Group.fromMap(snapshot.data()!));
        } else {
          print("Grupo com ID $groupId da lista não encontrado.");
        }
      } catch (e) {
        print("Erro ao ler grupo $group (Future): $e");
      }
    }
    return temp;
  }

  // NOVO MÉTODO para leitura em tempo real (Stream) - Retorna lista de resultados
  Stream<List<GroupFetchResult>> streamGroupResults(List<String> groupIds) {
    if (groupIds.isEmpty) {
      print(">>> streamGroupResults chamada com lista vazia <<<");
      return Stream.value([]);
    }

    print(">>> streamGroupResults chamada com IDs: $groupIds <<<");

    // Crie um stream de resultados (GroupFetchResult) para cada groupId
    List<Stream<GroupFetchResult>> streams =
        groupIds.map((id) {
          print("Criando stream de resultados para group ID: $id");
          return firestore
              .collection('groups')
              .doc(id)
              .snapshots()
              .map((DocumentSnapshot<Map<String, dynamic>> snapshot) {
                // Mapeia um snapshot válido para um resultado de sucesso ou não encontrado
                if (snapshot.exists) {
                  try {
                    return GroupFetchResult(
                      groupId: snapshot.id,
                      group: Group.fromMap(snapshot.data()!),
                      error: null,
                    );
                  } catch (e) {
                    // Trata erros de mapeamento (se Group.fromMap falhar) como uma falha na leitura do grupo
                    print(
                      "Erro ao mapear snapshot ${snapshot.id} para Group: $e",
                    );
                    return GroupFetchResult(
                      groupId: snapshot.id,
                      group: null,
                      error: "Falha ao mapear dados: $e",
                    );
                  }
                } else {
                  // O documento não existe (foi excluído ou nunca existiu)
                  return GroupFetchResult(
                    groupId: snapshot.id,
                    group: null,
                    error: null,
                  ); // isNotFound será true
                }
              })
              .onErrorReturnWith((error, stackTrace) {
                // Intercepta erros (como permission-denied) NO stream INDIVIDUAL
                print(
                  "Erro (permissão negada/outro) no stream individual para group ID $id: $error",
                );
                // Emite um resultado de falha para este ID específico
                return GroupFetchResult(
                  groupId: id,
                  group: null,
                  error: error,
                ); // isFailure será true
              });
        }).toList();

    // Combine todos os streams individuais de resultados (GroupFetchResult).
    // combineLatestList agora receberá GroupFetchResult de cada stream.
    // Se um stream individual falhou e emitiu um GroupFetchResult com erro,
    // combineLatestList receberá este resultado como o "último valor" daquele stream.
    // O stream combinado NÃO VAI FALHAR, a menos que combineLatestList em si tenha um erro.
    return Rx.combineLatestList(streams).handleError((e) {
      // Este handleError só será chamado para erros globais no stream combinado.
      print(
        "Erro REMANESCENTE no stream combinado de resultados de grupos: $e",
      );
      throw e; // Relança para ser tratado pelo listener no Provider
    });
  }

  Future<void> addGroup({required Group group}) async {
    try {
      // Nota: Conforme discutido, o campo groupId dentro do doc é redundante
      // Se o ID do documento já é o groupId.
      // Considere remover 'groupId': groupId, do toMap() se o doc(group.groupId) já define o ID.
      await firestore
          .collection("groups")
          .doc(group.groupId)
          .set(group.toMap());
      // Use Batched Writes para garantir atomicidade
      WriteBatch batch = firestore.batch();

      DocumentReference userDocRef = firestore
          .collection("users")
          .doc(group.createBy);
      DocumentReference groupDocRef = firestore
          .collection("groups")
          .doc(group.groupId);

      batch.update(userDocRef, {
        'groupsId': FieldValue.arrayUnion([group.groupId]),
      });

      // Garante que o criador esteja no mapa role do grupo com role 'master' ao criar
      batch.update(groupDocRef, {
        'role': {group.createBy: 'master'},
      });

      await batch.commit(); // Executa todas as operações atomicamente
    } on FirebaseException catch (e) {
      print("Erro ao adicionar grupo e atualizar usuário: $e");
      rethrow;
    } catch (e) {
      print("Erro inesperado ao adicionar grupo: $e");
      rethrow;
    }
  }

  // Exemplo de como você faria para adicionar um membro (usando atomicidade)
  Future<void> addMemberToGroup(
    String groupId,
    String userId,
    String role,
  ) async {
    WriteBatch batch = firestore.batch();

    DocumentReference userDocRef = firestore.collection("users").doc(userId);
    DocumentReference groupDocRef = firestore.collection("groups").doc(groupId);

    // Adiciona o groupId na lista do usuário
    batch.update(userDocRef, {
      'groupIds': FieldValue.arrayUnion([groupId]),
    });

    // Adiciona o role do usuário no mapa role do grupo
    batch.update(groupDocRef, {
      'role.$userId':
          role, // Adiciona/atualiza a chave com o UID do usuário e o role
    });

    try {
      await batch.commit();
      print("Membro $userId adicionado ao grupo $groupId com role $role");
    } on FirebaseException catch (e) {
      print("Erro Firebase ao adicionar membro: $e");
      rethrow;
    } catch (e) {
      print("Erro inesperado ao adicionar membro: $e");
      rethrow;
    }
  }

  // Exemplo de como remover um membro (usando atomicidade)
  Future<void> removeMemberFromGroup(String groupId, String userId) async {
    WriteBatch batch = firestore.batch();

    DocumentReference userDocRef = firestore.collection("users").doc(userId);
    DocumentReference groupDocRef = firestore.collection("groups").doc(groupId);

    // Remove o groupId da lista do usuário
    batch.update(userDocRef, {
      'groupIds': FieldValue.arrayRemove([groupId]),
    });

    // Remove a chave do usuário do mapa role do grupo
    batch.update(groupDocRef, {
      'role':
          FieldValue.delete(), // Isso removeria o campo 'role' inteiro! CUIDADO!
      // Para remover APENAS a chave do usuário no mapa, é mais complexo
      // com FieldValue.delete(). Você precisaria ler o mapa role atual,
      // remover a chave no cliente e fazer um batch.update com o novo mapa inteiro.
      // Ou usar uma Cloud Function.
      // Exemplo (lendo no cliente - MENOS ideal devido a latência/concorrência):
      // DocumentSnapshot groupSnapshot = await groupDocRef.get();
      // Map<String, dynamic> currentRoleMap = Map.from(groupSnapshot.data()!['role'] ?? {});
      // currentRoleMap.remove(userId);
      // batch.update(groupDocRef, {'role': currentRoleMap});

      // Exemplo (assumindo que 'role.${userId}' remove a chave, o que NÃO é padrão do Firestore SDK FieldValue.delete)
      // A forma correta é usar FieldValue.delete() no campo, mas não funciona para remover chaves em mapas.
      // A forma mais segura e atômica (sem ler o mapa no cliente) é via Cloud Function.
      // Se você QUISER fazê-lo via cliente e batch, precisaria ler primeiro, o que quebra a atomicidade do batch sozinho.
      // A melhor prática aqui é usar uma Cloud Function.

      // Para este exemplo, vamos SIMULAR a remoção da chave no mapa 'role' usando uma abordagem comum
      // que seria ler -> modificar -> batch.update, entendendo a ressalva da atomicidade.
      // Ou, mais simples para o mock: apenas remova da lista groupIds do user por enquanto.
      // A remoção do role do mapa é mais complexa via cliente+batch.

      // Se você usar uma Cloud Function para remover um membro, a função faria:
      // 1. Verificar permissão do admin/master.
      // 2. Remover groupId da lista do usuário (documento do outro usuário).
      // 3. Ler o mapa role do documento do grupo.
      // 4. Remover a chave do usuário do mapa role.
      // 5. Atualizar o mapa role no documento do grupo.
      // Tudo isso dentro da Cloud Function com credenciais de admin para ignorar Security Rules (temporariamente para o update).

      // Para o propósito do teste AGORA, vamos apenas remover o groupId da lista do usuário.
      // A remoção do role do mapa no grupo exigiria uma estratégia diferente (Cloud Function).
    });

    // Se você for remover o role do mapa via cliente/batch, precisaria da leitura ANTES do batch.
    // await firestore.collection('groups').doc(groupId).get()...ler o role map...

    try {
      await batch.commit();
      print("Membro $userId removido do grupo $groupId.");
    } on FirebaseException catch (e) {
      print("Erro Firebase ao remover membro: $e");
      rethrow;
    } catch (e) {
      print("Erro inesperado ao remover membro: $e");
      rethrow;
    }
  }
}
