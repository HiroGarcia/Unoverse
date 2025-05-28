import 'package:flutter/material.dart';

import '../data/services/auth_service.dart';
import '../domain/entity/user_entity.dart';
import '../presentation/widgets/show_snackbar.dart';

class AuthController {
  AuthService authService = AuthService();

  loginUser({
    required String email,
    required String password,
    required BuildContext context,
  }) {
    authService.loginUser(email: email, password: password).then((
      String? error,
    ) {
      if (!context.mounted) return;
      if (error != null) {
        showSnackBar(context: context, mensagem: error);
      }
    });
  }

  registerUser({
    required String email,
    required String password,
    required String name,
    required BuildContext context,
  }) async {
    String? error = await authService.registerUser(
      email: email,
      password: password,
      name: name,
      user: UserEntity(name: name, email: email, groupsId: []),
    );

    if (!context.mounted) return;

    if (error != null) {
      showSnackBar(context: context, mensagem: error);
    }
  }
}
