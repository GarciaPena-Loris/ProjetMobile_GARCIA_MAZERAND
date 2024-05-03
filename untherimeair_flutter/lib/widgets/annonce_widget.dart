import 'package:flutter/material.dart';
import 'package:untherimeair_flutter/models/annonce.dart';

class AnnonceWidget extends StatelessWidget {
  final Annonce annonce;

  AnnonceWidget({required this.annonce});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              annonce.titre,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Description: ${annonce.description}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 4),
            Text(
              'Début: ${annonce.dateDebut}',
              style: TextStyle(fontSize: 16),
            ),
            Text(
              'Fin: ${annonce.dateFin}',
              style: TextStyle(fontSize: 16),
            ),
            Text(
              'Date de publication: ${annonce.datePublication}',
              style: TextStyle(fontSize: 16),
            ),
            Text(
              'Emplacement: ${annonce.emplacement}',
              style: TextStyle(fontSize: 16),
            ),
            Text(
              'Métier cible: ${annonce.metierCible}',
              style: TextStyle(fontSize: 16),
            ),
            Text(
              'Rémunération: ${annonce.remuneration}€',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
