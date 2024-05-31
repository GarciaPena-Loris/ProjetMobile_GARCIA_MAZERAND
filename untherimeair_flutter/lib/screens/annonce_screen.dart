import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../models/annonce_modele.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';
import 'candidatureDetails_screen.dart';
import 'editAnnonce_screen.dart';

class AnnonceScreen extends StatelessWidget {
  final Annonce annonce;
  final AuthService authService = AuthService();
  final StorageService storageService = StorageService();

  AnnonceScreen({super.key, required this.annonce});

  void _deleteAnnonce(BuildContext context) async {
    try {
      await FirebaseFirestore.instance
          .collection('annonces')
          .doc(annonce.idAnnonce)
          .delete();
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la suppression: $e')),
      );
    }
  }

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
            const SizedBox(height: 8.0),

            // Description de l'annonce
            Text(
              annonce.description,
              style: const TextStyle(fontSize: 16.0),
            ),
            const SizedBox(height: 8.0),
            // Barre horizontale
            const Divider(),

            // Date du contrat
            const SizedBox(height: 8.0),
            _buildDetailItem(
              'Date',
              Icons.date_range,
              'Du ${DateFormat('dd MMMM yyyy', 'fr_FR').format(annonce.dateDebut)} au ${DateFormat('dd MMMM yyyy', 'fr_FR').format(annonce.dateFin)}',
            ),
            const SizedBox(height: 8.0),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Divider(),
            ),

            // Lieu
            const SizedBox(height: 8.0),
            _buildDetailItem('Lieu', Icons.location_on, annonce.ville),
            const SizedBox(height: 8.0),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Divider(),
            ),

            // Amplitude horaire
            const SizedBox(height: 8.0),
            _buildDetailItem('Amplitude horaire', Icons.access_time,
                '${annonce.amplitudeHoraire} heures par jour'),
            const SizedBox(height: 8.0),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Divider(),
            ),

            // Rémunération
            const SizedBox(height: 8.0),
            _buildDetailItem('Rémunération', Icons.attach_money,
                '${annonce.remuneration} €/heure'),
            const SizedBox(height: 16.0),

            // Boutons
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
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        EditAnnonceScreen(annonce: annonce),
                                  ),
                                );
                              },
                              child: const Text('Modifier annonce'),
                            ),
                            const SizedBox(width: 20),
                            ElevatedButton(
                              onPressed: () => _deleteAnnonce(context),
                              child: const Text(
                                'Supprimer annonce',
                                style: TextStyle(
                                    color: Colors.red), // Change la couleur du texte en rouge
                              ),
                            ),
                          ],
                        );
                      }
                      return Container();
                    },
                  );
                }
                return Container();
              },
            ),

            const SizedBox(height: 16.0),
            const Divider(),
            const Text(
              'Candidatures',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),

            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('candidatures')
                  .where('annonce', isEqualTo: FirebaseFirestore.instance.collection('annonces').doc(annonce.idAnnonce))
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                return Expanded(
                  child: ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      Map<String, dynamic> candidature = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                      DateTime dateDeCandidature = (candidature['dateDeCandidature'] as Timestamp).toDate();
                      int difference = DateTime.now().difference(dateDeCandidature).inDays;

                      return Card(
                        child: ListTile(
                          title: Text('${candidature['nomCandidat']} ${candidature['prenomCandidat']}'),
                          subtitle: Text('Postulé il y a $difference jours'),
                          trailing: const Icon(Icons.remove_red_eye),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CandidatureDetailsScreen(candidature: candidature),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String title, IconData icon, String value) {
    return Row(
      children: [
        Icon(icon),
        const SizedBox(width: 8.0),
        Text(
          '$title: ',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        Expanded(
          child: Text(value),
        ),
      ],
    );
  }
}
