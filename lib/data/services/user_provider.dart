import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../domain/entity/user_entity.dart';

Stream<UserEntity> listenToUser(String uid) {
  return FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .snapshots()
      .map((doc) => UserEntity.fromFirestore(doc));
}

class UserProvider with ChangeNotifier {
  UserEntity? _user;
  StreamSubscription<UserEntity>? _subscription;

  UserEntity? get user => _user;

  void listenUser(String uid) {
    _subscription?.cancel();

    _subscription = listenToUser(uid).listen((userData) {
      _user = userData;
      notifyListeners();
    });
  }

  void resetForSignOut() {
    print(
      "UserProvider: resetForSignOut chamado. Cancelando assinatura de usuário.",
    );
    _subscription?.cancel();
    _subscription = null;
    _user = null;
  }

  @override
  void dispose() {
    print("UserProvider: dispose chamado!");
    _subscription?.cancel();
    super.dispose();
  }
}
