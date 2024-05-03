import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:untherimeair_flutter/models/annonce_modele.dart';

class AnnonceService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Stream of annonces
  Stream<List<Annonce>> getAnnonces() {
    return _db.collection('annonces').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Annonce.fromFirestore(doc)).toList()
    );
  }
}