import 'package:cloud_firestore/cloud_firestore.dart';

class Utilisateur {
  final String idUtilisateur;
  final String mail;
  final String nom;
  final String prenom;
  final DateTime? dateDeNaissance;
  final String? telephone;
  final String? ville;
  final String? nationalite;
  final String? commentaire;
  final String? cv;

  Utilisateur({
    required this.idUtilisateur,
    required this.mail,
    required this.nom,
    required this.prenom,
    required this.dateDeNaissance,
    required this.telephone,
    required this.ville,
    required this.nationalite,
    required this.commentaire,
    required this.cv,
  });

  // Un constructeur de fabrique pour créer un utilisateur à partir d'un document Firestore correspondant
  factory Utilisateur.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return Utilisateur(
      idUtilisateur: data['idUtilisateur'] ?? "0",
      mail: data['mail'] ?? '',
      nom: data['nom'] ?? '',
      prenom: data['prenom'] ?? '',
      dateDeNaissance: (data['dateDeNaissance'] as Timestamp).toDate(),
      telephone: data['telephone'] ?? '',
      ville: data['ville'] ?? '',
      nationalite: data['nationalite'] ?? '',
      commentaire: data['commentaire'] ?? '',
      cv: data['cv'] ?? '',
    );
  }
}
