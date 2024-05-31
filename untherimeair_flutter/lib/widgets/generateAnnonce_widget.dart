import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:faker/faker.dart';
import 'package:flutter/material.dart';

class GenerateAdsWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Generate Ads'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            await generateAndAddAds(10); // Génère et ajoute 10 fausses annonces
          },
          child: Text('Generate Ads'),
        ),
      ),
    );
  }

  Future<void> generateAndAddAds(int numberOfAds) async {
    final firestore = FirebaseFirestore.instance;
    final faker = Faker();
    final adData = _getAdData();

    for (int i = 0; i < numberOfAds; i++) {
      final randomAd =
          adData.entries.toList()[faker.randomGenerator.integer(adData.length)];
      final randomDescription =
          randomAd.value[faker.randomGenerator.integer(randomAd.value.length)];

      // Créer un nouveau document dans la collection 'annonces'
      final annonceRef = firestore.collection('annonces').doc();

      final fakeAd = {
        'idAnnonce': annonceRef.id,
        // Utiliser l'ID du document comme ID de l'annonce
        'amplitudeHoraire': faker.randomGenerator.integer(12, min: 4),
        'dateDebut': Timestamp.fromDate(
            faker.date.dateTime(minYear: 2024, maxYear: 2025)),
        'dateFin': Timestamp.fromDate(
            faker.date.dateTime(minYear: 2024, maxYear: 2025)),
        'datePublication': Timestamp.fromDate(
            faker.date.dateTime(minYear: 2023, maxYear: 2024)),
        'description': randomDescription,
        'emplacement': _generateRandomLocationInFrance(),
        'idEmployeur': faker.guid.guid(),
        'metierCible': randomAd.key,
        'remuneration': faker.randomGenerator.integer(100, min: 10),
        'titre': randomAd.key,
        'ville': faker.address.city(),
        // Ville fictive pour exemple
      };

      await firestore.collection('annonces').add(fakeAd);
      print('Added ad $i');
    }
  }

  Map<String, List<String>> _getAdData() {
    return {
      "Manutentionnaire": [
        "Chargement et déchargement de camions.",
        "Préparation des commandes et gestion des stocks.",
        "Utilisation d'engins de manutention."
      ],
      "Agent de nettoyage": [
        "Nettoyage et entretien des locaux.",
        "Gestion des stocks de produits d'entretien.",
        "Respect des normes d'hygiène et de sécurité."
      ],
      "Serveur(se)": [
        "Prise de commandes et service en salle.",
        "Préparation des boissons et des plats.",
        "Encaissement et gestion des réservations."
      ],
      "Vendeur(se)": [
        "Accueil des clients et conseil à la vente.",
        "Gestion des stocks et mise en rayon.",
        "Encaissement et tenue de caisse."
      ],
      "Téléopérateur(trice)": [
        "Réception et émission d'appels.",
        "Gestion des demandes clients et prise de rendez-vous.",
        "Saisie informatique et mise à jour des bases de données."
      ],
      "Magasinier": [
        "Réception et expédition des marchandises.",
        "Gestion des stocks et des inventaires.",
        "Utilisation de chariots élévateurs."
      ],
      "Chauffeur-livreur": [
        "Livraison de marchandises chez les clients.",
        "Chargement et déchargement des colis.",
        "Entretien du véhicule de livraison."
      ],
      "Aide-soignant(e)": [
        "Assistance aux patients dans les actes de la vie quotidienne.",
        "Surveillance de l'état de santé des patients.",
        "Préparation et distribution des médicaments."
      ],
      "Ouvrier(e) du bâtiment": [
        "Travaux de construction et de rénovation.",
        "Utilisation des outils et machines de chantier.",
        "Respect des consignes de sécurité."
      ],
      "Assistant(e) administratif(ve)": [
        "Gestion des appels téléphoniques et des courriers.",
        "Organisation des réunions et rédaction des comptes rendus.",
        "Mise à jour des bases de données et des dossiers."
      ],
    };
  }

  GeoPoint _generateRandomLocationInFrance() {
    final faker = Faker();
    double lat = 41.0 +
        faker.randomGenerator.decimal() * 10.0; // Latitude entre 41.0 et 51.0
    double lon = -5.0 +
        faker.randomGenerator.decimal() * 14.0; // Longitude entre -5.0 et 9.0
    return GeoPoint(lat, lon);
  }
}
