import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CandidatureDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> candidature;

  CandidatureDetailsScreen({required this.candidature});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails de la candidature'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('État: ${candidature['etat']}'),
            Text('Date de candidature: ${candidature['dateDeCandidature']}'),
            // Ajoutez ici d'autres informations de la candidature que vous voulez afficher
            const SizedBox(height: 16),
            Text('Annonce:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('Titre: ${candidature['annonce']['titre'] ?? 'Non spécifié'}'),
            Text('Description: ${candidature['annonce']['description'] ?? 'Non spécifiée'}'),

            const SizedBox(height: 16),
            Text('Candidat:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('Nom: ${candidature['nomCandidat'] ?? 'Non spécifié'}'),
            Text('Prénom: ${candidature['prenomCandidat'] ?? 'Non spécifié'}'),

          ],
        ),
      ),
    );
  }
}
