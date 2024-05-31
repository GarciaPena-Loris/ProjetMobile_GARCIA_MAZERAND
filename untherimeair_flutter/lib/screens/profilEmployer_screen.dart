import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:untherimeair_flutter/models/utilisateur_modele.dart';

import '../main.dart';
import '../services/auth_service.dart';

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
            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('employeurs')
                  .doc(user!.uid)
                  .get(),
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
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.phone_enabled),
                            const SizedBox(width: 8),
                            Text(
                              telephoneEntreprise,
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
                                              fontSize: 16, color: Colors.blue),
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
                              child: const Text('Déconnexion'),
                            ),
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
                        FutureBuilder<QuerySnapshot>(
                          future: FirebaseFirestore.instance
                              .collection('annonces')
                              .where('employeurId', isEqualTo: user.uid)
                              .get(),
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
                              final annonces = snapshot.data!.docs;
                              return ListView.builder(
                                shrinkWrap: true,
                                itemCount: annonces.length,
                                itemBuilder: (context, index) {
                                  var annonce = annonces[index].data()
                                      as Map<String, dynamic>;
                                  return ListTile(
                                    title: Text(
                                        annonce['titre'] ?? 'Titre non fourni'),
                                    subtitle: Text(annonce['description'] ??
                                        'Description non fournie'),
                                    onTap: () {
                                      // Ajoutez ici la logique pour afficher les détails de l'annonce
                                    },
                                  );
                                },
                              );
                            } else {
                              return const Text('Aucune annonce trouvée');
                            }
                          },
                        ),
                      ],
                    ),
                  );
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
                          child: const Text('Déconnexion'),
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
