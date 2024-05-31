import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:untherimeair_flutter/models/utilisateur_modele.dart';

import '../main.dart';
import '../services/auth_service.dart';
import '../widgets/pdfView_widget.dart';

class ProfilUserScreen extends StatefulWidget {
  const ProfilUserScreen({super.key});

  @override
  _ProfilUserScreenState createState() => _ProfilUserScreenState();
}

class _ProfilUserScreenState extends State<ProfilUserScreen> {
  bool _cvDeposed = false;
  final _storage = FirebaseStorage.instance;
  final AuthService authService = AuthService();

  @override
  Widget build(BuildContext context) {
    String calculerAge(DateTime? dateDeNaissance) {
      if (dateDeNaissance == null) {
        return 'Date de naissance non fournie';
      }

      DateTime now = DateTime.now();
      int age = now.year - dateDeNaissance.year;
      if (now.month < dateDeNaissance.month ||
          (now.month == dateDeNaissance.month &&
              now.day < dateDeNaissance.day)) {
        age--;
      }
      return age.toString();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
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
                  .collection('utilisateurs')
                  .doc(user!.uid)
                  .get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(
                      child: Text('Erreur de chargement du profil'));
                } else if (snapshot.hasData) {
                  Utilisateur utilisateur =
                      Utilisateur.fromFirestore(snapshot.data!);
                  _cvDeposed = utilisateur.cv != '';
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${utilisateur.nom} ${utilisateur.prenom}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.cake),
                            const SizedBox(width: 8),
                            Text(
                              '${calculerAge(utilisateur.dateDeNaissance)} ans',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const Icon(Icons.email),
                            const SizedBox(width: 8),
                            Text(
                              utilisateur.mail,
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
                              utilisateur.telephone ?? 'Non fourni',
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
                              utilisateur.ville ?? 'Non fournie',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.flag),
                            const SizedBox(width: 8),
                            Text(
                              utilisateur.nationalite ?? 'Non fournie',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.comment),
                            const SizedBox(width: 8),
                            Text(
                              utilisateur.commentaire ?? '',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),
                        // Ajoutez d'autres informations de l'utilisateur ici avec des icônes correspondantes

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          // Centrer les boutons dans la ligne
                          children: [
                            // Bouton pour modifier le profil
                            ElevatedButton(
                              onPressed: () {
                                // Ajoutez ici la logique pour modifier les informations de l'utilisateur
                              },
                              child: const Text('Modifier le profil'),
                            ),
                            // Bouton de déconnexion
                            ElevatedButton(
                              onPressed: () async {
                                await authService.signOut();
                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                  navigatorKey.currentState!.pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false);
                                });
                              },
                              child: const Text('Déconnexion'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 16),
                        const Text(
                          'CV',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Card(
                          color: _cvDeposed ? Colors.lightBlueAccent : null,
                          child: ListTile(
                            leading: const Icon(Icons.description),
                            title: Text(_cvDeposed
                                ? 'CV déjà déposé'
                                : 'Déposé votre CV (pdf)'),
                            trailing: _cvDeposed
                                ? Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.visibility),
                                        onPressed: () async {
                                          try {
                                            final ref = FirebaseStorage.instance
                                                .ref(
                                                    'cvs/${FirebaseAuth.instance.currentUser!.uid}.pdf');
                                            final url =
                                                await ref.getDownloadURL();

                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    PdfViewPage(url: url),
                                              ),
                                            );
                                          } catch (e) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                  content: Text(
                                                      'Erreur de chargement du CV: $e')),
                                            );
                                          }
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.clear),
                                        onPressed: () {
                                          setState(() {
                                            _cvDeposed = false;
                                          });
                                          // Supprimer le CV de Firebase Storage
                                          _storage
                                              .ref(
                                                  'cvs/${FirebaseAuth.instance.currentUser!.uid}.pdf')
                                              .delete();
                                          // Supprimer le lien du CV de la base de données
                                          FirebaseFirestore.instance
                                              .collection('utilisateurs')
                                              .doc(FirebaseAuth
                                                  .instance.currentUser!.uid)
                                              .update({'cv': ''});

                                          const SnackBar(
                                            content: Text('Cv supprimé'),
                                            backgroundColor: Colors.red,
                                          );
                                        },
                                      ),
                                    ],
                                  )
                                : null,
                            onTap: () async {
                              if (!_cvDeposed) {
                                FilePickerResult? result =
                                    await FilePicker.platform.pickFiles(
                                  type: FileType.custom,
                                  allowedExtensions: ['pdf'],
                                );

                                if (result != null) {
                                  if (result.files.single.extension == 'pdf') {
                                    // Upload to Firebase Storage
                                    try {
                                      TaskSnapshot snapshot = await _storage
                                          .ref(
                                              'cvs/${FirebaseAuth.instance.currentUser!.uid}.pdf')
                                          .putFile(
                                              File(result.files.single.path!));

                                      // Get the download URL
                                      String downloadURL =
                                          await snapshot.ref.getDownloadURL();

                                      // Update the CV link in the database
                                      await FirebaseFirestore.instance
                                          .collection('utilisateurs')
                                          .doc(FirebaseAuth
                                              .instance.currentUser!.uid)
                                          .update({'cv': downloadURL});

                                      setState(() {
                                        _cvDeposed = true;
                                      });

                                      if (mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text('CV déposé.'),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                      }
                                    } catch (e) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              'Failed to upload CV. Error: $e'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'Veuillez sélectionner un fichier PDF.'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                }
                              }
                            },
                          ),
                        ),

                        const SizedBox(height: 16),

                        const Divider(),
                        const SizedBox(height: 16),
                        const Text(
                          'Candidature',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Actuellement vous avez x candidatures',
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            // Ajoutez ici la logique pour afficher les candidatures de l'utilisateur
                          },
                          child: const Text('Voir mes candidatures'),
                        ),
                      ],
                    ),
                  );
                } else {
                  return const Center(child: Text('Aucun profil trouvé'));
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
