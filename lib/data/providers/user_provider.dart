// import 'dart:async';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/foundation.dart';

// import '../../domain/entity/user_entity.dart';

// Stream<UserEntity> listenToUser(String uid) {
//   return FirebaseFirestore.instance
//       .collection('users')
//       .doc(uid)
//       .snapshots()
//       .map((doc) => UserEntity.fromFirestore(doc));
// }

// class UserProvider with ChangeNotifier {
//   UserEntity? _user;
//   StreamSubscription<UserEntity>? _subscription;

//   UserEntity? get user => _user;

//   void listenUser(String uid) {
//     _subscription?.cancel();

//     _subscription = listenToUser(uid).listen((userData) {
//       _user = userData;
//       notifyListeners();
//     });
//   }

//   void resetForSignOut() {
//     print(
//       "UserProvider: resetForSignOut chamado. Cancelando assinatura de usuário.",
//     );
//     _subscription?.cancel();
//     _subscription = null;
//     _user = null;
//   }

//   @override
//   void dispose() {
//     print("UserProvider: dispose chamado!");
//     _subscription?.cancel();
//     super.dispose();
//   }
// }

// Em user_provider.dart (Implementar esta versão)

import 'dart:async';
import 'package:flutter/foundation.dart'; // Para ChangeNotifier
import 'package:firebase_auth/firebase_auth.dart'; // Para FirebaseAuth e User
import 'package:cloud_firestore/cloud_firestore.dart'; // Para FirebaseFirestore e DocumentSnapshot

// Importe sua entidade User (UserEntity)
import '../../domain/entity/user_entity.dart'; // Ajuste o caminho conforme sua estrutura

class UserProvider with ChangeNotifier {
  // Campo para armazenar os dados do usuário Entity
  UserEntity? _user;
  UserEntity? get user => _user;

  // Assinaturas dos streams que este Provider gerencia
  // A assinatura do authStateChanges inicia no construtor
  StreamSubscription? _authStateSubscription;
  // A assinatura do stream do documento do usuário é gerenciada pelo listener acima
  StreamSubscription? _userDocumentSubscription;

  // Construtor: Inicia a escuta DO ESTADO DE AUTENTICAÇÃO do Firebase Auth
  UserProvider() {
    print("UserProvider: CONSTRUTOR chamado.");

    // Listener principal: reage às mudanças no estado de autenticação do Firebase Auth
    _authStateSubscription = FirebaseAuth.instance.authStateChanges().listen((
      firebaseUser,
    ) {
      print(
        "UserProvider: Auth state changed. firebaseUser is null: ${firebaseUser == null}",
      );

      // Cancela a assinatura do stream do documento de usuário ANTERIOR, se houver.
      // Isso é feito sempre que o estado de auth muda.
      _userDocumentSubscription?.cancel();
      _userDocumentSubscription = null;

      if (firebaseUser != null) {
        // --- Usuário LOGOU ---
        // O estado de autenticação mudou para logado.
        // Agora, vamos iniciar a escuta DO DOCUMENTO deste usuário específico no Firestore.
        print(
          "UserProvider: Usuário logado (${firebaseUser.uid}). Iniciando escuta do documento de usuário.",
        );

        _userDocumentSubscription = _listenToUserDocument(
          firebaseUser.uid,
        ).listen(
          (userData) {
            // Este listener é chamado sempre que o documento do usuário muda NO FIRESTORE
            print(
              "UserProvider: Dados do documento de usuário recebidos do stream. Dados nulos: ${userData == null}",
            );
            _user =
                userData; // Atualiza o estado do Provider com os dados do usuário Entity
            // Chama notifyListeners() para que os widgets que observam o Provider (como RoteadorTelas e HomePage) reajam
            notifyListeners();
          },
          onError: (error) {
            // --- Erro no stream do documento de usuário ---
            print(
              "UserProvider: ERRO no stream do documento de usuário para UID ${firebaseUser.uid}: $error",
            );
            // Lida com o erro (ex: permissão negada se a regra /users/{uid} estiver errada)
            _user = null; // Limpa os dados do usuário em caso de erro no stream
            notifyListeners(); // Notifica os listeners sobre a mudança (usuário = null ou estado de erro)
          },
        );
      } else {
        // --- Usuário DESLOGOU ---
        // O estado de autenticação mudou para deslogado.
        // Já cancelamos a assinatura do documento de usuário no início deste listener.
        // Agora, limpa o estado do usuário no Provider.
        print("UserProvider: Usuário deslogou. Limpando dados do usuário.");
        _user = null;
        // Chama notifyListeners() para que os widgets reajam (RoteadorTelas mostrará AuthPage)
        notifyListeners();
      }
    });
  }

  // REMOVA O MÉTODO listenUser(String uid) público!
  // Ele não deve ser chamado de fora. O Provider se gerencia.
  // void listenUser(String uid) { ... REMOVA ... }

  // Método privado para retornar o stream do documento de usuário do Firestore
  // É usado INTERNAMENTE pelo listener de authStateChanges
  Stream<UserEntity?> _listenToUserDocument(String uid) {
    print(
      "UserProvider: Configurando stream Firestore para documento do usuário UID: $uid",
    );
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((snapshot) {
          // Mapeamento do Snapshot para UserEntity
          if (snapshot.exists && snapshot.data() != null) {
            try {
              // Use UserEntity.fromMap ou UserEntity.fromFirestore
              return UserEntity.fromMap(
                snapshot.data()!,
              ); // Ou UserEntity.fromFirestore(snapshot)
            } catch (e) {
              print(
                "UserProvider: ERRO ao mapear dados do documento de usuário ${snapshot.id}: $e",
              );
              return null; // Retorna null em caso de erro de mapeamento
            }
          } else {
            // Documento não encontrado (pode acontecer no primeiro login antes de criar o doc)
            print(
              "UserProvider: Documento do usuário não encontrado ou dados nulos para UID: $uid",
            );
            return null;
          }
        })
        .handleError((error) {
          // Erro no stream do Firestore (antes do mapeamento) - ex: permissão negada, rede
          print(
            "UserProvider: ERRO no stream Firestore (antes do mapeamento) para UID $uid: $error",
          );
          throw error; // Re-lança o erro para ser capturado pelo listener onError
        });
  }

  // O método resetForSignOut() público não é mais necessário
  // pois o listener de authStateChanges gerencia a limpeza e cancelamento
  // ao detectar o logout.
  // void resetForSignOut() { ... REMOVA ... }

  // Dispose: Limpa AMBAS as assinaturas quando o Provider é descartado pelo framework (no encerramento do app)
  @override
  void dispose() {
    print(
      "UserProvider: dispose chamado!",
    ); // Deve aparecer SOMENTE no encerramento do app
    _authStateSubscription
        ?.cancel(); // Cancela a escuta do estado de autenticação
    _authStateSubscription = null;
    _userDocumentSubscription
        ?.cancel(); // Cancela a escuta do documento de usuário
    _userDocumentSubscription = null;
    super.dispose();
  }
}
