import 'package:unoverse/data/services/auth_service.dart';

class AuthController {
  AuthService authService = AuthService();

  loginUser({required String email, required String password}) {
    authService.loginUser(email: email, password: password).then((
      String? error,
    ) {
      if (error != null) {
        print(error);
      }
    });
  }
}
