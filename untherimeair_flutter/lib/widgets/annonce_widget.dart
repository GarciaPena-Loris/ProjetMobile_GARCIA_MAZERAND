import 'package:flutter/material.dart';
import 'package:untherimeair_flutter/models/annonce_modele.dart';

import '../screens/annonce_screen.dart';

class AnnonceWidget extends StatelessWidget {
  final Annonce annonce;

  AnnonceWidget({required this.annonce});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AnnonceScreen(annonce: annonce),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(
          left: 16.0,
          right: 16.0,
          top: 4.0,
          bottom: 4.0,
        ),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Titre de l'annonce
                Text(
                  annonce.metierCible,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                // Lieu de l'annonce
                Text(
                  '${annonce.metierCible} à ${annonce.ville}',
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 16),
                // Date de publication de l'annonce
                Text(
                  'Offre publiée il y a ${DateTime.now().difference(annonce.datePublication).inDays} jours',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}