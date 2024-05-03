import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User?> signIn(String email, String password) async {
    try {
      // Utilisation de FirebaseAuth pour l'authentification
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      // Gestion des exceptions
      print("Erreur lors de la connexion: $e");
      return null;
    }
  }

  Future<User?> signUp(String email, String password) async {
    try {
      // Utilisation de FirebaseAuth pour l'authentification
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      // Gestion des exceptions
      print("Erreur lors de l'inscription: $e");
      return null;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
