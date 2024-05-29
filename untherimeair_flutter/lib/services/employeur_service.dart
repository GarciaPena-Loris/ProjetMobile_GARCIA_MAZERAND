import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

import 'package:untherimeair_flutter/models/employeur_modele.dart';

class EmployeurService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Inscription d'un nouvel employeur
  Future<Employeur?> inscrireEmployeur({
    required String mail,
    required String motDePasse,
    required String nom,
    required String adresseEntreprise,
    required String nomEntreprise,
    required String telephone,
    required String telephoneEntreprise,
    required List<String> liensPublics,
  }) async {
    UserCredential? result;

    try {
      result = await _auth.createUserWithEmailAndPassword(
        email: mail,
        password: motDePasse,
      );

      String uid = result.user!.uid;

      await _firestore.collection('employeurs').doc(uid).set({
        'idEmployeur': uid,
        'nom': nom,
        'adresseEntreprise': adresseEntreprise,
        'nomEntreprise': nomEntreprise,
        'mail': mail,
        'telephone': telephone,
        'telephoneEntreprise': telephoneEntreprise,
        'liensPublics': liensPublics,
      });

      DocumentSnapshot employeurDoc =
      await _firestore.collection('employeurs').doc(uid).get();

      Employeur employeur = Employeur.fromFirestore(employeurDoc);

      return employeur;
    } catch (e) {
      print("Erreur lors de l'inscription de l'employeur: $e");
      if (result != null) {
        await result.user?.delete();
      }
      return null;
    }
  }
}