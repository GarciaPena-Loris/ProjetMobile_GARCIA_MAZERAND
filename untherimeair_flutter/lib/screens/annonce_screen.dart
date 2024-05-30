import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:untherimeair_flutter/services/auth_service.dart';

import '../models/annonce_modele.dart';

class AnnonceScreen extends StatelessWidget {
  final Annonce annonce;
  final AuthService authService = AuthService();

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
                return ElevatedButton(
                  onPressed: () {
                    if (snapshot.hasData) {
                      // Si l'utilisateur est connecté, implémentez ici la logique pour postuler à l'annonce
                      print(
                          'Utilisateur connecté. Implémentez ici la logique pour postuler à l\'annonce.');
                    } else {
                      // Si l'utilisateur n'est pas connecté, afficher un message l'invitant à se connecter
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text(
                            'Connectez-vous pour postuler à cette annonce.'),
                      ));
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
