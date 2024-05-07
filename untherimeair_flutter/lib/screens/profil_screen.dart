import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:untherimeair_flutter/models/utilisateur_modele.dart';

class ProfilScreen extends StatefulWidget {
  const ProfilScreen({super.key});

  @override
  _ProfilScreenState createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  File? _cvFile;

  @override
  Widget build(BuildContext context) {
    String calculerAge(DateTime dateDeNaissance) {
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
                              utilisateur.telephone,
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
                              utilisateur.ville,
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
                              utilisateur.nationalite,
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
                              utilisateur.commentaire,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),
                        // Ajoutez d'autres informations de l'utilisateur ici avec des icônes correspondantes
                        ElevatedButton(
                          onPressed: () {
                            // Ajoutez ici la logique pour modifier les informations de l'utilisateur
                          },
                          child: const Text('Modifier le profil'),
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
                          color:
                              _cvFile != null ? Colors.lightGreenAccent : null,
                          child: ListTile(
                            leading: const Icon(Icons.description),
                            title: Text(_cvFile == null
                                ? 'Sélectionnez votre CV (pdf)'
                                : _cvFile!.path),
                            trailing: _cvFile != null
                                ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      setState(() {
                                        _cvFile = null;
                                      });
                                    },
                                  )
                                : null,
                            onTap: () async {
                              FilePickerResult? result =
                                  await FilePicker.platform.pickFiles(
                                type: FileType.custom,
                                allowedExtensions: ['pdf'],
                              );

                              if (result != null) {
                                if (result.files.single.extension == 'pdf') {
                                  setState(() {
                                    _cvFile = File(result.files.single.path!);
                                  });
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
