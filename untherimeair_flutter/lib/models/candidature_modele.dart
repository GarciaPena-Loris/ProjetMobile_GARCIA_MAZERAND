import 'package:cloud_firestore/cloud_firestore.dart';

class Candidature {
  final String idCandidature;
  final String CVCandidat;
  final DateTime dateDeCandidature;
  final DateTime dateDeNaissanceCandidat;
  final String etat;
  final DocumentReference annonce;
  final String idCandidat;
  final String lettreMotivationCandidat;
  final String nationalite;
  final String nomCandidat;
  final String prenomCandidat;
  final String numeroTelephoneCandidat;
  final String emailCandidat;

  Candidature({
    required this.idCandidature,
    required this.CVCandidat,
    required this.dateDeCandidature,
    required this.dateDeNaissanceCandidat,
    required this.etat,
    required this.annonce,
    required this.idCandidat,
    required this.lettreMotivationCandidat,
    required this.nationalite,
    required this.nomCandidat,
    required this.prenomCandidat,
    required this.numeroTelephoneCandidat,
    required this.emailCandidat,
  });

  factory Candidature.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return Candidature(
      idCandidature: data['idCandidature'] ?? '',
      CVCandidat: data['CVCandidat'] ?? '',
      dateDeCandidature: (data['dateDeCandidature'] as Timestamp).toDate(),
      dateDeNaissanceCandidat: (data['dateDeNaissanceCandidat'] as Timestamp).toDate(),
      etat: data['etat'] ?? '',
      annonce: data['annonce'],
      idCandidat: data['idCandidat'] ?? '',
      lettreMotivationCandidat: data['lettreMotivationCandidat'] ?? '',
      nationalite: data['nationalite'] ?? '',
      nomCandidat: data['nomCandidat'] ?? '',
      prenomCandidat: data['prenomCandidat'] ?? '',
      numeroTelephoneCandidat: data['numeroTelephoneCandidat'] ?? '',
      emailCandidat: data['emailCandidat'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'idCandidature': idCandidature,
      'CVCandidat': CVCandidat,
      'dateDeCandidature': dateDeCandidature,
      'dateDeNaissanceCandidat': dateDeNaissanceCandidat,
      'etat': etat,
      'annonce': annonce,
      'idCandidat': idCandidat,
      'lettreMotivationCandidat': lettreMotivationCandidat,
      'nationalite': nationalite,
      'nomCandidat': nomCandidat,
      'prenomCandidat': prenomCandidat,
      'numeroTelephoneCandidat': numeroTelephoneCandidat,
      'emailCandidat': emailCandidat,
    };
  }
}