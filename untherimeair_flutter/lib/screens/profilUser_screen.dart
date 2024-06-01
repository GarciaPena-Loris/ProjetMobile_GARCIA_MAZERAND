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
import 'candidatureDetails_screen.dart';
import 'editProfil_screen.dart';

class ProfilUserScreen extends StatefulWidget {
  const ProfilUserScreen({super.key});

  @override
  _ProfilUserScreenState createState() => _ProfilUserScreenState();
}

class _ProfilUserScreenState extends State<ProfilUserScreen> {
  bool _cvDeposed = false;
  final _storage = FirebaseStorage.instance;
  final AuthService authService = AuthService();
  late Stream<List<Map<String, dynamic>>> _candidaturesStream;

  @override
  void initState() {
    super.initState();
    _candidaturesStream = _loadCandidatures();
  }

  String calculerAge(DateTime? dateDeNaissance) {
    if (dateDeNaissance == null) {
      return 'Date de naissance non fournie';
    }

    DateTime now = DateTime.now();
    int age = now.year - dateDeNaissance.year;
    if (now.month < dateDeNaissance.month ||
        (now.month == dateDeNaissance.month && now.day < dateDeNaissance.day)) {
      age--;
    }
    return age.toString();
  }

  Stream<List<Map<String, dynamic>>> _loadCandidatures() async* {
    List<Map<String, dynamic>> candidatures = [];
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final snapshot = await FirebaseFirestore.instance
          .collection('candidatures')
          .where('idCandidat', isEqualTo: user.uid)
          .snapshots();

      await for (var snap in snapshot) {
        candidatures = [];
        for (var doc in snap.docs) {
          var data = doc.data();
          var annonceRef = data['annonce'] as DocumentReference;
          var annonceSnapshot = await annonceRef.get();
          if (annonceSnapshot.exists) {
            var annonceData = annonceSnapshot.data() as Map<String, dynamic>;
            data['annonce'] = annonceData;
            candidatures.add(data);
          }
        }
        yield candidatures;
      }
    }
  }

  Widget _buildCandidatureStateIcon(String etat) {
    IconData iconData;
    Color iconColor;
    String tooltip;

    switch (etat) {
      case 'Acceptee':
        iconData = Icons.check_circle;
        iconColor = Colors.green;
        tooltip = 'Candidature acceptée';
        break;
      case 'Refusee':
        iconData = Icons.cancel;
        iconColor = Colors.red;
        tooltip = 'Candidature refusée';
        break;
      case 'Attente':
        iconData = Icons.access_time;
        iconColor = Colors.orange;
        tooltip = 'Candidature en cours';
        break;
      case 'Validee':
        iconData = Icons.done;
        iconColor = Colors.deepPurpleAccent;
        tooltip = 'Candidature validée';
        break;
      default:
        iconData = Icons.info;
        iconColor = Colors.grey;
        tooltip = 'État de la candidature inconnu';
        break;
    }

    return Tooltip(
      message: tooltip,
      child: Icon(
        iconData,
        color: iconColor,
      ),
    );
  }

  Widget _buildPostulationDate(Timestamp? dateDeCandidature) {
    if (dateDeCandidature != null) {
      final now = DateTime.now();
      final difference = now.difference(dateDeCandidature.toDate());
      final days = difference.inDays;
      return Text('Postulé il y a $days jours');
    } else {
      return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
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
            return StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('utilisateurs')
                  .doc(user!.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(
                      child: Text('Erreur de chargement du profil'));
                } else if (snapshot.hasData && snapshot.data!.exists) {
                  Utilisateur utilisateur =
                      Utilisateur.fromFirestore(snapshot.data!);
                  _cvDeposed = utilisateur.cv != '';
                  return SingleChildScrollView(
                    child: Padding(
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EditProfilePage(
                                          utilisateur: utilisateur),
                                    ),
                                  );
                                },
                                child: const Text('Modifier le profil'),
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  await authService.signOut();
                                  WidgetsBinding.instance
                                      .addPostFrameCallback((_) {
                                    navigatorKey.currentState!
                                        .pushNamedAndRemoveUntil('/home',
                                            (Route<dynamic> route) => false);
                                  });
                                },
                                child: const Text('Déconnexion',
                                    style: TextStyle(color: Colors.red)),
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
                                  : 'Déposez votre CV (pdf)'),
                              trailing: _cvDeposed
                                  ? Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.visibility),
                                          onPressed: () async {
                                            try {
                                              final ref =
                                                  FirebaseStorage.instance.ref(
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
                                            _storage
                                                .ref(
                                                    'cvs/${FirebaseAuth.instance.currentUser!.uid}.pdf')
                                                .delete();
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
                                    if (result.files.single.extension ==
                                        'pdf') {
                                      try {
                                        TaskSnapshot snapshot = await _storage
                                            .ref(
                                                'cvs/${FirebaseAuth.instance.currentUser!.uid}.pdf')
                                            .putFile(File(
                                                result.files.single.path!));

                                        String downloadURL =
                                            await snapshot.ref.getDownloadURL();

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
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
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
                          StreamBuilder<List<Map<String, dynamic>>>(
                            stream: _loadCandidatures(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              } else if (snapshot.hasError) {
                                return Center(
                                    child: Text('Erreur: ${snapshot.error}'));
                              } else if (!snapshot.hasData ||
                                  snapshot.data!.isEmpty) {
                                return const Center(
                                    child: Text('Aucune candidature trouvée.'));
                              } else {
                                var candidatures = snapshot.data!;
                                return ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: candidatures.length,
                                  itemBuilder: (context, index) {
                                    var candidature = candidatures[index];
                                    var annonce = candidature['annonce'];

                                    return Card(
                                      child: ListTile(
                                        title: Text(annonce['titre'] ??
                                            'Titre de l\'annonce'),
                                        subtitle: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(annonce['description'] ??
                                                'Description de l\'annonce'),
                                            const SizedBox(height: 8),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                Row(
                                                  children: [
                                                    Text(
                                                      candidature['etat'] ??
                                                          'État inconnu',
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.black87,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    _buildCandidatureStateIcon(
                                                        candidature['etat'] ??
                                                            ''),
                                                  ],
                                                ),
                                                const SizedBox(width: 8),
                                                _buildPostulationDate(
                                                    candidature[
                                                        'dateDeCandidature']),
                                              ],
                                            ),
                                          ],
                                        ),
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  CandidatureDetailsScreen(
                                                      idCandidature:
                                                          candidature[
                                                              'idCandidature']),
                                            ),
                                          );
                                        },
                                      ),
                                    );
                                  },
                                );
                              }
                            },
                          ),
                        ],
                      ),
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
