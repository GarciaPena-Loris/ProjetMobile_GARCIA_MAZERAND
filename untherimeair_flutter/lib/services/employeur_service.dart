import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:untherimeair_flutter/services/auth_service.dart';

import 'package:untherimeair_flutter/models/employeur_modele.dart';

class EmployeurService {
  final AuthService authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Inscription d'un nouvel employeur
  Future<Employeur?> inscrireEmployeur({
    required String mail,
    required String motDePasse,
    required String nom,
    required String adresseEntreprise,
    required String nomEntreprise,
    required String telephoneEntreprise,
    required List<String> liensPublics,
  }) async {
    try {
      User? user = await authService.signUp(mail, motDePasse, true);
      String uid = user!.uid;

      await _firestore.collection('employeurs').doc(uid).set({
        'idEmployeur': uid,
        'nom': nom,
        'adresseEntreprise': adresseEntreprise,
        'nomEntreprise': nomEntreprise,
        'mail': mail,
        'telephoneEntreprise': telephoneEntreprise,
        'liensPublics': liensPublics,
      });

      DocumentSnapshot employeurDoc =
          await _firestore.collection('employeurs').doc(uid).get();

      Employeur employeur = Employeur.fromFirestore(employeurDoc);

      return employeur;
    } catch (e) {
      print("Erreur lors de l'inscription de l'employeur: $e");
      return null;
    }
  }
}
