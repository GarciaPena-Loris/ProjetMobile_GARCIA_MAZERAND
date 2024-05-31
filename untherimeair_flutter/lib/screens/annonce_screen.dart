import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:untherimeair_flutter/screens/applyForm_screen.dart';
import 'package:untherimeair_flutter/screens/auth_screen.dart';
import 'package:untherimeair_flutter/services/auth_service.dart';

import '../models/annonce_modele.dart';
import '../services/storage_service.dart';

class AnnonceScreen extends StatelessWidget {
  final Annonce annonce;
  final AuthService authService = AuthService();
  final storageService = StorageService();

  AnnonceScreen({super.key, required this.annonce});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails de l\'annonce'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Titre de l'annonce
            Text(
              annonce.metierCible,
              style: const TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16.0),

            // Description de l'annonce
            Text(
              annonce.description,
              style: const TextStyle(fontSize: 16.0),
            ),
            const SizedBox(height: 16.0),
            // Barre horizontale
            const Divider(),

            // Date du contrat
            const SizedBox(height: 16.0),
            _buildDetailItem(
              'Date du contrat',
              Icons.date_range,
              'Du ${DateFormat('dd MMMM yyyy', 'fr_FR').format(annonce.dateDebut)} au ${DateFormat('dd MMMM yyyy', 'fr_FR').format(annonce.dateFin)}',
            ),
            const SizedBox(height: 16.0),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Divider(),
            ),

            // Lieu
            const SizedBox(height: 16.0),
            _buildDetailItem('Lieu', Icons.location_on, annonce.ville),
            const SizedBox(height: 16.0),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Divider(),
            ),

            // Amplitude horaire
            const SizedBox(height: 16.0),
            _buildDetailItem('Amplitude horaire', Icons.access_time,
                '${annonce.amplitudeHoraire} heures par jour'),
            const SizedBox(height: 16.0),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Divider(),
            ),

            // Rémunération
            const SizedBox(height: 16.0),
            _buildDetailItem('Rémunération', Icons.attach_money,
                '${annonce.remuneration} €/heure'),
            const SizedBox(height: 32.0),

            // Bouton "Postuler à l'annonce"
            StreamBuilder<User?>(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return FutureBuilder<bool>(
                    future: storageService.getEmployeurStatus(),
                    builder: (context, snapshotEmployeur) {
                      if (snapshotEmployeur.hasData &&
                          snapshotEmployeur.data!) {
                        // Si l'utilisateur est un employeur
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                // Ajoutez ici la logique pour modifier l'annonce
                              },
                              child: const Text('Modifier annonce'),
                            ),
                            const SizedBox(width: 20),
                            // Ajoutez cette ligne pour ajouter de l'espace entre les boutons
                            ElevatedButton(
                              onPressed: () {
                                // Ajoutez ici la logique pour supprimer l'annonce
                              },
                              child: const Text(
                                'Supprimer annonce',
                                style: TextStyle(
                                    color: Colors
                                        .red), // Change la couleur du texte en rouge
                              ),
                            ),
                          ],
                        );
                      } else {
                        // Si l'utilisateur est un candidat
                        return ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      ApplyFormPage(annonce: annonce)),
                            );
                          },
                          child: const Text('Postuler à l\'annonce'),
                        );
                      }
                    },
                  );
                } else {
                  // Si l'utilisateur n'est pas connecté
                  return ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                            AuthScreen()),
                      );
                    }
                  },
                  child: Text(snapshot.hasData
                      ? 'Postuler à l\'annonce'
                      : 'Connectez-vous pour postuler'),
                );
              },
            )
          ],
        ),
      ),
    );
  }

  // Widget pour afficher chaque élément de détail
  Widget _buildDetailItem(String label, IconData icon, String value) {
    return Row(
      children: [
        Icon(icon),
        const SizedBox(width: 8.0),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(value),
            ],
          ),
        ),
      ],
    );
  }
}
