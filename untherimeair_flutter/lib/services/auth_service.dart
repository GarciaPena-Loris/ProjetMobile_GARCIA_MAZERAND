import 'package:firebase_auth/firebase_auth.dart';
import 'package:untherimeair_flutter/services/storage_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final StorageService _storageService = StorageService();

  Future<User?> signIn(String email, String password) async {
    try {
      // Utilisation de FirebaseAuth pour l'authentification
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Vérification si un Employeur existe avec cet email
      DocumentSnapshot userDoc = await _firestore.collection('employeurs').doc(result.user!.uid).get();
      bool isEmployeur = userDoc.exists;

      await _storageService.setEmployeurStatus(isEmployeur);

      return result.user;
    } catch (e) {
      // Gestion des exceptions
      print("Erreur lors de la connexion: $e");
      return null;
    }
  }

  Future<User?> signUp(String email, String password, bool isEmployeur) async {
    try {
      // Utilisation de FirebaseAuth pour l'authentification
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _storageService.setEmployeurStatus(isEmployeur);

      return result.user;
    } catch (e) {
      // Gestion des exceptions
      print("Erreur lors de l'inscription: $e");
      return null;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await _storageService.setEmployeurStatus(false);
  }
}
