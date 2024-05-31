import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/candidature_modele.dart';

class CandidatureService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<Candidature?> postuler({
    required String CVCandidat,
    required DateTime dateDeNaissanceCandidat,
    required String idAnnonce,
    required String lettreMotivationCandidat,
    required String nationalite,
    required String nomCandidat,
    required String prenomCandidat,
    required File? lettreMotivationFile,
  }) async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        // Générer un nouvel ID de candidature
        final candidatureRef = _firestore.collection('candidatures').doc();

        String lettreMotivationUrl = '';
        if (lettreMotivationFile != null) {
          // Télécharger le fichier de lettre de motivation dans Firebase Storage
          Reference lmRef = _storage.ref().child(
              'lettresMotivation/${lettreMotivationFile.path.split('/').last}');
          UploadTask uploadTask = lmRef.putFile(lettreMotivationFile);
          await uploadTask.whenComplete(() => null);

          // Obtenir l'URL du fichier de lettre de motivation téléchargé
          lettreMotivationUrl = await lmRef.getDownloadURL();
        }

        // Référence à l'annonce
        DocumentReference annonceRef =
            _firestore.collection('annonces').doc(idAnnonce);

        // Créer un nouvel objet candidature
        final candidature = Candidature(
          idCandidature: candidatureRef.id,
          CVCandidat: CVCandidat,
          dateDeCandidature: Timestamp.now().toDate(),
          dateDeNaissanceCandidat: dateDeNaissanceCandidat,
          etat: 'Attente',
          annonce: annonceRef,
          idCandidat: user.uid,
          lettreMotivationCandidat: lettreMotivationUrl,
          nationalite: nationalite,
          nomCandidat: nomCandidat,
          prenomCandidat: prenomCandidat,
        );

        // Ajouter la candidature à Firestore
        await candidatureRef.set(candidature.toMap());

        return candidature;
      } catch (e) {
        print('Erreur lors de la postulation: $e');
        return null;
      }
    } else {
      print('Aucun utilisateur connecté');
      return null;
    }
  }
}
