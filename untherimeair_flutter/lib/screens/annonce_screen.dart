import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../models/annonce_modele.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';
import 'applyForm_screen.dart';
import 'auth_screen.dart';
import 'candidatureDetails_screen.dart';
import 'editAnnonce_screen.dart';

class AnnonceScreen extends StatelessWidget {
  final String idAnnonce;
  final AuthService authService = AuthService();
  final StorageService storageService = StorageService();

  AnnonceScreen({super.key, required this.idAnnonce});

  Stream<Annonce> _fetchAnnonce() {
    return FirebaseFirestore.instance
        .collection('annonces')
        .doc(idAnnonce)
        .snapshots()
        .map((doc) => Annonce.fromFirestore(doc));
  }

  void _deleteAnnonce(BuildContext context) async {
    try {
      await FirebaseFirestore.instance
          .collection('annonces')
          .doc(idAnnonce)
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
    return StreamBuilder<Annonce>(
        stream: _fetchAnnonce(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }

          final annonce = snapshot.data!;
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
                  _buildDetailItem(Icons.location_on, annonce.ville),
                  const SizedBox(height: 8.0),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Divider(),
                  ),

                  // Amplitude horaire
                  const SizedBox(height: 8.0),
                  _buildDetailItem(Icons.access_time,
                      '${annonce.amplitudeHoraire} heures/jour'),
                  const SizedBox(height: 8.0),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Divider(),
                  ),

                  // Rémunération
                  const SizedBox(height: 8.0),
                  _buildDetailItem(
                      Icons.attach_money, '${annonce.remuneration} €/heure'),
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              EditAnnonceScreen(
                                                  annonce: annonce),
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
                                  builder: (context) => AuthScreen()),
                            );
                          },
                          child: Text(snapshot.hasData
                              ? 'Postuler à l\'annonce'
                              : 'Connectez-vous pour postuler'),
                        );
                      }
                    },
                  ),

                  StreamBuilder<User?>(
                    stream: FirebaseAuth.instance.authStateChanges(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData &&
                          snapshot.data!.uid == annonce.idEmployeur) {
                        return StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('candidatures')
                              .where('annonce',
                                  isEqualTo: FirebaseFirestore.instance
                                      .collection('annonces')
                                      .doc(annonce.idAnnonce))
                              .snapshots(),
                          builder: (context, snapshot) {
                            // Pendant le chargement
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }

                            // S'il n'y a pas de candidature
                            if (snapshot.data!.docs.isEmpty) {
                              return const Center(
                                  child: Text(
                                      'Aucune candidature pour cette annonce'));
                            }

                            // Sinon, afficher la liste
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start, // Aligne le titre à gauche
                              children: [
                                const SizedBox(height: 16.0),
                                const Divider(), // Ajoute un Divider avant "Candidatures"
                                const SizedBox(height: 16.0),
                                const Text(
                                  'Candidatures',
                                  style: TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8.0),
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: snapshot.data!.docs.length,
                                  itemBuilder: (context, index) {
                                    Map<String, dynamic> candidature =
                                        snapshot.data!.docs[index].data()
                                            as Map<String, dynamic>;
                                    final difference = DateTime.now()
                                        .difference(
                                            candidature['dateDeCandidature']
                                                .toDate())
                                        .inDays;
                                    return Card(
                                      child: ListTile(
                                        title: Text(
                                            '${candidature['nomCandidat']} ${candidature['prenomCandidat']}'),
                                        subtitle: Text(
                                            'Postulé il y a $difference jours'),
                                        trailing:
                                            const Icon(Icons.remove_red_eye),
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  CandidatureDetailsScreen(
                                                      candidature: candidature),
                                            ),
                                          );
                                        },
                                      ),
                                    );
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      } else {
                        return Container(); // Retourne un conteneur vide si l'utilisateur n'est pas l'employeur de l'annonce
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  Widget _buildDetailItem(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon),
        const SizedBox(width: 8.0),
        Expanded(
          child: Text(value),
        ),
      ],
    );
  }
}
