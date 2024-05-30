import 'package:cloud_firestore/cloud_firestore.dart';

class Annonce {
  final int idAnnonce;
  final DocumentReference idEmployeur;
  final String description;
  final DateTime dateDebut;
  final DateTime dateFin;
  final DateTime datePublication;
  final List<double> emplacement;
  final String metierCible;
  final int remuneration;
  final String ville;
  final int amplitudeHoraire;

  Annonce({
    required this.idAnnonce,
    required this.idEmployeur,
    required this.description,
    required this.dateDebut,
    required this.dateFin,
    required this.datePublication,
    required this.emplacement,
    required this.metierCible,
    required this.remuneration,
    required this.ville,
    required this.amplitudeHoraire,
  });

  // a factory method to create an Annonce from a corresponding Firestore document
  factory Annonce.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    GeoPoint geoPoint = data['emplacement'] as GeoPoint;
    return Annonce(
      idAnnonce: data['idAnnonce'] ?? 0,
      idEmployeur: data['idEmployeur'] as DocumentReference,
      description: data['description'] ?? '',
      dateDebut: (data['dateDebut'] as Timestamp).toDate(),
      dateFin: (data['dateFin'] as Timestamp).toDate(),
      datePublication: (data['datePublication'] as Timestamp).toDate(),
      emplacement: [geoPoint.latitude, geoPoint.longitude],
      metierCible: data['metierCible'] ?? '',
      remuneration: data['remuneration'] ?? 0,
      ville: data['ville'] ?? '',
      amplitudeHoraire: data['amplitudeHoraire'] ?? 0
    );
  }
}