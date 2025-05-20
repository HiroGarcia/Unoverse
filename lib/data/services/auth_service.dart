import 'package:firebase_auth/firebase_auth.dart';
import 'package:unoverse/data/services/user_service.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<String?> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-credential':
          return 'E-mail or password invalid.';
        case 'network-request-failed':
          return 'Network request failed.';
      }
      return e.code;
    } catch (e) {
      return 'Big error';
    }
    return null;
  }

  Future<String?> registerUser({
    required email,
    required password,
    required name,
    required user,
  }) async {
    try {
      UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      await userCredential.user!.updateDisplayName(name);
      await userCredential.user!.updatePhotoURL('1');
      UserService().createUser(user);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "email-already-in-use":
          return "E-mail already in use";
        case "invalid-email":
          return "invalid e-mail";
        case "weak-password":
          return "Weak password";
      }
      return e.code;
    } catch (e) {
      return 'Big error';
    }
    return null;
  }
}
