import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:untherimeair_flutter/screens/editEmployerProfile_screen.dart';
import 'package:url_launcher/url_launcher.dart';

import '../main.dart';
import '../models/annonce_modele.dart';
import '../services/auth_service.dart';
import 'annonce_screen.dart';

class ProfilEmployerScreen extends StatefulWidget {
  const ProfilEmployerScreen({super.key});

  @override
  _ProfilEmployerScreenState createState() => _ProfilEmployerScreenState();
}

class _ProfilEmployerScreenState extends State<ProfilEmployerScreen> {
  final AuthService authService = AuthService();

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    await launchUrl(uri);
  }

  Future<int> _getAttenteCandidatureCount(String annonceId) async {
    DocumentReference annonceRef =
        FirebaseFirestore.instance.collection('annonces').doc(annonceId);
    QuerySnapshot query = await FirebaseFirestore.instance
        .collection('candidatures')
        .where('annonce', isEqualTo: annonceRef)
        .where('etat', isEqualTo: 'Attente')
        .get();
    return query.docs.length;
  }

  Future<int> _getAcceptedCandidatureCount(String annonceId) async {
    QuerySnapshot query = await FirebaseFirestore.instance
        .collection('candidatures')
        .where('annonce',
            isEqualTo: FirebaseFirestore.instance
                .collection('annonces')
                .doc(annonceId))
        .where('etat', isEqualTo: 'Acceptee')
        .get();
    return query.docs.length;
  }

  Future<int> _getValidatedCandidatureCount(String annonceId) async {
    QuerySnapshot query = await FirebaseFirestore.instance
        .collection('candidatures')
        .where('annonce',
            isEqualTo: FirebaseFirestore.instance
                .collection('annonces')
                .doc(annonceId))
        .where('etat', isEqualTo: 'Validee')
        .get();
    return query.docs.length;
  }

  Stream<List<AnnonceWithCounts>> _fetchAnnoncesWithCountsStream(
      List<DocumentSnapshot> docs) async* {
    List<AnnonceWithCounts> annoncesWithCounts = [];
    for (var doc in docs) {
      var annonce = Annonce.fromFirestore(doc);
      int attenteCandidatureCount = await _getAttenteCandidatureCount(annonce.idAnnonce);
      int acceptedCandidatureCount =
          await _getAcceptedCandidatureCount(annonce.idAnnonce);
      int validatedCandidatureCount =
          await _getValidatedCandidatureCount(annonce.idAnnonce);
      annoncesWithCounts.add(
        AnnonceWithCounts(
          annonce: annonce,
          attenteCandidatureCount: attenteCandidatureCount,
          acceptedCandidatureCount: acceptedCandidatureCount,
          validatedCandidatureCount: validatedCandidatureCount,
        ),
      );
    }
    // Trier les annonces
    annoncesWithCounts.sort((a, b) {
      if (a.attenteCandidatureCount != b.attenteCandidatureCount) {
        return b.attenteCandidatureCount.compareTo(a.attenteCandidatureCount);
      } else if (a.acceptedCandidatureCount != b.acceptedCandidatureCount) {
        return b.acceptedCandidatureCount.compareTo(a.acceptedCandidatureCount);
      } else if (a.validatedCandidatureCount != b.validatedCandidatureCount) {
        return b.validatedCandidatureCount.compareTo(a.validatedCandidatureCount);
      } else {
        return b.annonce.datePublication.compareTo(a.annonce.datePublication);
      }
    });
    yield annoncesWithCounts;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Employeur'),
      ),
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Erreur de chargement du profil'));
          } else if (snapshot.hasData) {
            User? user = snapshot.data;
            return StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('employeurs')
                  .doc(user!.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(
                      child: Text('Erreur de chargement du profil'));
                } else if (snapshot.hasData && snapshot.data!.exists) {
                  var employeurData =
                      snapshot.data!.data() as Map<String, dynamic>;
                  String nom = employeurData['nom'] ?? 'Nom non fourni';
                  String mail = employeurData['mail'] ?? 'Mail non fourni';
                  String telephoneEntreprise =
                      employeurData['telephoneEntreprise'] ?? 'Non fourni';
                  String adresseEntreprise =
                      employeurData['adresseEntreprise'] ?? 'Non fournie';
                  List<String> liensPublics =
                      List<String>.from(employeurData['liensPublics'] ?? []);

                  return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              nom,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.email),
                                const SizedBox(width: 8),
                                Text(
                                  mail,
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.phone),
                                const SizedBox(width: 8),
                                Text(
                                  telephoneEntreprise,
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.location_city),
                                const SizedBox(width: 8),
                                Text(
                                  adresseEntreprise,
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Liens publics',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ...liensPublics
                                .map((lien) => InkWell(
                                      onTap: () async {
                                        await _launchUrl(lien);
                                      },
                                      child: Row(
                                        children: [
                                          const Icon(Icons.link),
                                          // Ajoutez cette ligne pour l'icône
                                          const SizedBox(width: 8),
                                          Flexible(
                                            // Ajoutez ce widget
                                            child: Text(
                                              lien,
                                              style: const TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.blue),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ))
                                .toList(),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            EditEmployerProfilePage(
                                                employeurData: employeurData),
                                      ),
                                    );
                                  },
                                  child: const Text('Modifier le profil'),
                                ),
                                ElevatedButton(
                                    onPressed: () async {
                                      await authService.signOut();
                                      navigatorKey.currentState!
                                          .pushNamedAndRemoveUntil('/home',
                                              (Route<dynamic> route) => false);
                                    },
                                    child: const Text('Déconnexion',
                                        style: TextStyle(color: Colors.red))),
                              ],
                            ),
                            const SizedBox(height: 16),
                            const Divider(),
                            const SizedBox(height: 16),
                            const Text(
                              'Annonces postées',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('annonces')
                                  .where('idEmployeur', isEqualTo: user.uid)
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                } else if (snapshot.hasError) {
                                  return const Center(
                                      child: Text(
                                          'Erreur de chargement des annonces'));
                                } else if (snapshot.hasData) {
                                  final docs = snapshot.data!.docs;

                                  return StreamBuilder<List<AnnonceWithCounts>>(
                                    stream:
                                        _fetchAnnoncesWithCountsStream(docs),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const Center(
                                            child: CircularProgressIndicator());
                                      } else if (snapshot.hasError) {
                                        return const Center(
                                            child: Text(
                                                'Erreur de chargement des candidatures'));
                                      } else if (snapshot.hasData) {
                                        final annoncesWithCounts =
                                            snapshot.data!;
                                        return ListView.builder(
                                          shrinkWrap: true,
                                          itemCount: annoncesWithCounts.length,
                                          itemBuilder: (context, index) {
                                            var annonceWithCounts =
                                                annoncesWithCounts[index];
                                            var annonce =
                                                annonceWithCounts.annonce;
                                            var datePublication =
                                                annonce.datePublication;
                                            var now = DateTime.now();
                                            var difference = now
                                                .difference(datePublication)
                                                .inDays;

                                            return Card(
                                              child: ListTile(
                                                title:
                                                    Text(annonce.metierCible),
                                                subtitle: Text(
                                                    'Posté il y a $difference jour(s)'),
                                                trailing: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    if (annonceWithCounts
                                                            .validatedCandidatureCount >
                                                        0)
                                                      Row(
                                                        children: [
                                                          const Icon(
                                                              Icons.how_to_reg,
                                                              color:
                                                                  Colors.green),
                                                          const SizedBox(
                                                              width: 4),
                                                          Text(
                                                              '${annonceWithCounts.validatedCandidatureCount}'),
                                                        ],
                                                      )
                                                    else ...[
                                                      if (annonceWithCounts
                                                              .attenteCandidatureCount >
                                                          0)
                                                        Row(
                                                          children: [
                                                            const Icon(
                                                                Icons
                                                                    .notifications,
                                                                color: Colors
                                                                    .orange),
                                                            const SizedBox(
                                                                width: 4),
                                                            Text(
                                                                '${annonceWithCounts.attenteCandidatureCount}'),
                                                          ],
                                                        ),
                                                      if (annonceWithCounts
                                                              .acceptedCandidatureCount >
                                                          0)
                                                        Row(
                                                          children: [
                                                            const Icon(
                                                                Icons
                                                                    .access_time,
                                                                color: Colors
                                                                    .orangeAccent),
                                                            const SizedBox(
                                                                width: 4),
                                                            Text(
                                                                '${annonceWithCounts.acceptedCandidatureCount}'),
                                                          ],
                                                        ),
                                                    ]
                                                  ],
                                                ),
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          AnnonceScreen(
                                                        idAnnonce:
                                                            annonce.idAnnonce,
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            );
                                          },
                                        );
                                      } else {
                                        return const Center(
                                            child:
                                                Text('Aucune annonce trouvée'));
                                      }
                                    },
                                  );
                                } else {
                                  return const Center(
                                      child: Text('Aucune annonce trouvée'));
                                }
                              },
                            ),
                          ],
                        ),
                      ));
                } else {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Aucun profil trouvé'),
                        const SizedBox(height: 16.0),
                        ElevatedButton(
                          onPressed: () async {
                            await authService.signOut();
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              navigatorKey.currentState!
                                  .pushNamedAndRemoveUntil(
                                      '/home', (Route<dynamic> route) => false);
                            });
                          },
                          child: const Text('Déconnexion',
                              style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                }
              },
            );
          } else {
            return const Center(
              child: Text('Veuillez vous connecter pour voir le profil'),
            );
          }
        },
      ),
    );
  }
}

class AnnonceWithCounts {
  final Annonce annonce;
  final int attenteCandidatureCount;
  final int acceptedCandidatureCount;
  final int validatedCandidatureCount;

  AnnonceWithCounts({
    required this.annonce,
    required this.attenteCandidatureCount,
    required this.acceptedCandidatureCount,
    required this.validatedCandidatureCount,
  });
}
