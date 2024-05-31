import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:untherimeair_flutter/models/annonce_modele.dart';

class AnnonceService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Stream of annonces
  Stream<List<Annonce>> getAnnonces() {
    return _db.collection('annonces').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Annonce.fromFirestore(doc)).toList());
  }

  Future<Annonce?> ajouterAnnonce({
    required String idEmployeur,
    required String description,
    required DateTime dateDebut,
    required DateTime dateFin,
    required DateTime datePublication,
    required List<double> emplacement,
    required String metierCible,
    required double remuneration,
    required String ville,
    required int amplitudeHoraire,
  }) async {
    try {
      // Générer un nouvel ID d'annonce
      final annonceRef = _db.collection('annonces').doc();

      // Créer un nouvel objet annonce
      final annonce = Annonce(
        idAnnonce: annonceRef.id,
        idEmployeur: idEmployeur,
        description: description,
        dateDebut: dateDebut,
        dateFin: dateFin,
        datePublication: datePublication,
        emplacement: emplacement,
        metierCible: metierCible,
        remuneration: remuneration,
        ville: ville,
        amplitudeHoraire: amplitudeHoraire,
      );

      // Ajouter l'annonce à Firestore
      await annonceRef.set(annonce.toMap());

      return annonce;
    } catch (e) {
      print('Erreur lors de l\'ajout de l\'annonce: $e');
      return null;
    }
  }
}
