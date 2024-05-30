import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:untherimeair_flutter/models/utilisateur_modele.dart';
import 'package:untherimeair_flutter/services/auth_service.dart';

class UtilisateurService {
  final FirebaseAuth _auth = FirebaseAuth.instance; // Instance de FirebaseAuth
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance; // Instance de Firestore
  final FirebaseStorage _storage =
      FirebaseStorage.instance; // Instance de FirebaseStorage
  final AuthService authService = AuthService(); // Instance de AuthService

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
    required File? cv,
    required Timestamp dateDeNaissance,
  }) async {
    UserCredential? result; // Déclaration de result en dehors du bloc try

    try {
      User? user = await authService.signUp(mail, motDePasse, false);
      String uid = user!.uid;

      String cvUrl = ''; // Initialise cvUrl à une chaîne vide
      if (cv != null) {
        // Téléchargez le fichier CV dans Firebase Storage
        Reference cvRef =
            _storage.ref().child('cvs/${cv.path.split('/').last}');
        UploadTask uploadTask = cvRef.putFile(cv);
        await uploadTask.whenComplete(() => null);

        // Obtenez l'URL du fichier CV téléchargé
        cvUrl = await cvRef.getDownloadURL();
      }

      // Crée un document utilisateur dans Firestore avec l'identifiant de l'utilisateur comme clé
      await _firestore.collection('utilisateurs').doc(uid).set({
        // Initialise les champs de l'utilisateur dans Firestore
        'idUtilisateur': uid,
        'nom': nom,
        'prenom': prenom,
        'mail': mail,
        'telephone': telephone,
        'ville': ville,
        'nationalite': nationalite,
        'commentaire': commentaire,
        'cv': cvUrl,
        'dateDeNaissance': dateDeNaissance,
        // Ajoutez d'autres champs d'utilisateur si nécessaire
      });

      // Récupère les données de l'utilisateur nouvellement créé à partir de Firestore
      DocumentSnapshot utilisateurDoc =
          await _firestore.collection('utilisateurs').doc(uid).get();

      print("Utilisateur créé avec succès : $utilisateurDoc");

      // Crée un objet Utilisateur à partir des données Firestore
      Utilisateur utilisateur = Utilisateur.fromFirestore(utilisateurDoc);

      return utilisateur;
    } catch (e) {
      // Gère les erreurs lors de l'inscription
      print("Erreur lors de l'inscription: $e");

      // Si une erreur se produit lors de l'ajout de l'utilisateur à la base de données Firestore
      // et que result est non null, supprime l'utilisateur créé dans l'authentificateur Firebase
      if (result != null) {
        await result.user?.delete();
      }

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
