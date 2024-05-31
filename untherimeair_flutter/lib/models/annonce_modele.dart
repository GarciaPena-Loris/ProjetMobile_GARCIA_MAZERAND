import 'package:cloud_firestore/cloud_firestore.dart';

class Annonce {
  final String idAnnonce;
  final String idEmployeur;
  final String description;
  final DateTime dateDebut;
  final DateTime dateFin;
  final DateTime datePublication;
  final List<double> emplacement;
  final String metierCible;
  final double remuneration;
  final String ville;
  final double amplitudeHoraire;

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
        idAnnonce: data['idAnnonce'] ?? '',
        idEmployeur: data['idEmployeur'] ?? '',
        description: data['description'] ?? '',
        dateDebut: (data['dateDebut'] as Timestamp).toDate(),
        dateFin: (data['dateFin'] as Timestamp).toDate(),
        datePublication: (data['datePublication'] as Timestamp).toDate(),
        emplacement: [geoPoint.latitude, geoPoint.longitude],
        metierCible: data['metierCible'] ?? '',
        remuneration: (data['remuneration'] as num).toDouble(),
        ville: data['ville'] ?? '',
        amplitudeHoraire: (data['amplitudeHoraire'] as num).toDouble());
  }

  Map<String, dynamic> toMap() {
    return {
      'idAnnonce': idAnnonce,
      'idEmployeur': idEmployeur,
      'description': description,
      'dateDebut': dateDebut,
      'dateFin': dateFin,
      'datePublication': datePublication,
      'emplacement': GeoPoint(emplacement[0], emplacement[1]),
      'metierCible': metierCible,
      'remuneration': remuneration,
      'ville': ville,
      'amplitudeHoraire': amplitudeHoraire
    };
  }
}
