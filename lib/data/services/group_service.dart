import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';

import '../../domain/entity/group_entity.dart';

class GroupService {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<List<Group>> readGroup({required List<String> groupId}) async {
    print(">>> readGroup (Guture) chamada <<<");
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

  // NOVO MÉTODO para leitura em tempo real (Stream)
  Stream<List<Group>> streamGroups(List<String> groupIds) {
    // Se a lista de IDs estiver vazia, retorne um stream que emite uma lista vazia imediatamente
    if (groupIds.isEmpty) {
      print(">>> streamGroups chamada com lista vazia <<<");
      return Stream.value([]);
    }

    print(">>> streamGroups chamada com IDs: $groupIds <<<");

    // Crie um stream de snapshots para cada groupId
    List<Stream<DocumentSnapshot<Map<String, dynamic>>>> streams =
        groupIds.map((id) {
          print("Criando stream para group ID: $id");
          return firestore.collection('groups').doc(id).snapshots();
        }).toList();

    // Combine todos os streams individuais.
    // combineLatest emite uma nova lista sempre que *qualquer* um dos streams de origem emite um novo valor.
    // Cada valor emitido será uma lista contendo o snapshot mais recente de cada stream individual.
    return Rx.combineLatestList(streams)
        .map((List<DocumentSnapshot<Map<String, dynamic>>> snapshots) {
          List<Group> groups = [];
          // Filtre os snapshots que existem e mapeie para Group
          for (var snapshot in snapshots) {
            if (snapshot.exists) {
              groups.add(Group.fromMap(snapshot.data()!));
            } else {
              // O documento pode ter sido excluído
              print("Documento não existe para ID: ${snapshot.id}");
            }
          }
          // Os grupos estarão na ordem em que os streams foram criados (baseado na ordem de groupIds)
          return groups;
        })
        .handleError((e) {
          print("Erro no stream combinado de grupos: $e");
          // Você pode relançar o erro, retornar um stream de erro, etc.
          // Depende de como você quer que o Provider lide com erros de stream.
          throw e; // Relança o erro para ser tratado pelo listener
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
        'groupIds': FieldValue.arrayUnion([group.groupId]),
      });

      // Garante que o criador esteja no mapa role do grupo com role 'master' ao criar
      batch.update(groupDocRef, {
        'role': {
          group.createBy: 'master',
        }, // Define o role do criador como master
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
}
