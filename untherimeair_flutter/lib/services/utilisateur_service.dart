import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:untherimeair_flutter/models/utilisateur_modele.dart';

class UtilisateurService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Inscription d'un nouvel utilisateur
  Future<Utilisateur?> inscrireUtilisateur({
    required String mail,
    required String motDePasse,
    required String nom,
    required String prenom,
    required String telephone,
    required String ville,
    required String nationalite,
    required String commentaire,
    required String cv,
    required Timestamp dateDeNaissance,
  }) async {
    try {
      // Crée un nouvel utilisateur dans Firebase Authentication
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: mail,
        password: motDePasse,
      );

      // Récupère l'identifiant de l'utilisateur
      String uid = result.user!.uid;

      // Crée un document utilisateur dans Firestore avec l'identifiant de l'utilisateur comme clé
      await _firestore.collection('utilisateurs').doc(uid).set({
        // Initialise les champs de l'utilisateur dans Firestore
        'nom': nom,
        'prenom': prenom,
        'mail': mail,
        'telephone': telephone,
        'ville': ville,
        'nationalite': nationalite,
        'commentaire': commentaire,
        'cv': cv,
        'dateDeNaissance': dateDeNaissance,
        // Ajoutez d'autres champs d'utilisateur si nécessaire
      });

      // Récupère les données de l'utilisateur nouvellement créé à partir de Firestore
      DocumentSnapshot utilisateurDoc =
          await _firestore.collection('utilisateurs').doc(uid).get();

      // Crée un objet Utilisateur à partir des données Firestore
      Utilisateur utilisateur = Utilisateur.fromFirestore(utilisateurDoc);

      return utilisateur;
    } catch (e) {
      // Gère les erreurs lors de l'inscription
      print("Erreur lors de l'inscription: $e");
      return null;
    }
  }

  // Connexion de l'utilisateur existant
  Future<Utilisateur?> connecterUtilisateur(
      String mail, String motDePasse) async {
    try {
      // Connecte l'utilisateur avec son e-mail et son mot de passe dans Firebase Authentication
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: mail,
        password: motDePasse,
      );

      // Récupère l'identifiant de l'utilisateur
      String uid = result.user!.uid;

      // Récupère les données de l'utilisateur à partir de Firestore
      DocumentSnapshot utilisateurDoc =
          await _firestore.collection('utilisateurs').doc(uid).get();

      // Crée un objet Utilisateur à partir des données Firestore
      Utilisateur utilisateur = Utilisateur.fromFirestore(utilisateurDoc);

      return utilisateur;
    } catch (e) {
      // Gère les erreurs lors de la connexion
      print("Erreur lors de la connexion: $e");
      return null;
    }
  }
}
