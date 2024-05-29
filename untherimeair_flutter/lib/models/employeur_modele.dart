import 'package:cloud_firestore/cloud_firestore.dart';

class Employeur {
  final String idEmployeur;
  final String adresseEntreprise;
  final String nomEntreprise;
  final String nom;
  final String mail;
  final String telephone;
  final List<String> liensPublics;

  Employeur({
    required this.idEmployeur,
    required this.adresseEntreprise,
    required this.nomEntreprise,
    required this.nom,
    required this.mail,
    required this.telephone,
    required this.liensPublics,
  });

  // Un constructeur de fabrique pour créer un employeur à partir d'un document Firestore correspondant
  factory Employeur.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return Employeur(
      idEmployeur: data['idEmployeur'] ?? "0",
      adresseEntreprise: data['adresseEntreprise'] ?? '',
      nomEntreprise: data['nomEntreprise'] ?? '',
      nom: data['nom'] ?? '',
      mail: data['mail'] ?? '',
      telephone: data['telephone'] ?? '',
      liensPublics: List<String>.from(data['liensPublics'] ?? []),
    );
  }
}