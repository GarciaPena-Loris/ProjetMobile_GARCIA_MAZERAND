import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:untherimeair_flutter/models/candidature_modele.dart';
import 'package:untherimeair_flutter/models/employeur_modele.dart';
import 'package:url_launcher/url_launcher.dart';

import '../main.dart';
import '../models/annonce_modele.dart';
import '../services/storage_service.dart';
import '../widgets/pdfView_widget.dart';

class CandidatureDetailsScreen extends StatefulWidget {
  final String idCandidature;

  const CandidatureDetailsScreen({Key? key, required this.idCandidature})
      : super(key: key);

  @override
  _CandidatureDetailsScreenState createState() =>
      _CandidatureDetailsScreenState();
}

class _CandidatureDetailsScreenState extends State<CandidatureDetailsScreen> {
  bool _cvDeposed = false;
  bool _lettreMotivationDeposed = false;
  final StorageService storageService = StorageService();

  Stream<Candidature> _fetchCandidature() {
    return FirebaseFirestore.instance
        .collection('candidatures')
        .doc(widget.idCandidature)
        .snapshots()
        .map((doc) => Candidature.fromFirestore(doc));
  }

  Stream<Employeur> _fetchEmployeur(String idEmployeur) {
    return FirebaseFirestore.instance
        .collection('employeurs')
        .doc(idEmployeur)
        .snapshots()
        .map((doc) => Employeur.fromFirestore(doc));
  }

  Stream<Annonce> _fetchAnnonce(DocumentReference annonceRef) {
    return annonceRef.snapshots().map((doc) => Annonce.fromFirestore(doc));
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

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Candidature>(
        stream: _fetchCandidature(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }

          final candidature = snapshot.data!;
          _cvDeposed = candidature.CVCandidat.isNotEmpty;
          _lettreMotivationDeposed =
              candidature.lettreMotivationCandidat.isNotEmpty;

          return Scaffold(
            appBar: AppBar(
              title: const Text('Détails de la candidature'),
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Annonce',
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      StreamBuilder<Annonce>(
                        stream: _fetchAnnonce(candidature.annonce),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }

                          if (snapshot.hasError) {
                            return Center(
                                child: Text('Erreur: ${snapshot.error}'));
                          }

                          final annonce = snapshot.data!;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                annonce.metierCible,
                                style: const TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8.0),

                              // Description de l'annonce
                              Text(
                                'Publiée le ${DateFormat('dd MMMM yyyy', 'fr_FR').format(annonce.datePublication)} (${DateTime.now().difference(annonce.datePublication).inDays} jour(s))',
                                style: const TextStyle(fontSize: 14.0),
                              ),
                              const SizedBox(height: 8.0),
                              // Barre horizontale
                            ],
                          );
                        },
                      ),
                      const Divider(),
                      const SizedBox(height: 8.0),
                      FutureBuilder<bool>(
                        future: storageService.getEmployeurStatus(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return const Center(
                                child:
                                    Text('Erreur de chargement des données.'));
                          } else {
                            bool isEmployer = snapshot.data ?? false;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (isEmployer) ...[
                                  const Text(
                                    'Information sur le candidat',
                                    style: TextStyle(
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  // nom  du candidat
                                  const SizedBox(height: 16.0),
                                  _buildDetailItem(
                                    Icons.person,
                                    candidature.nomCandidat,
                                  ),
                                  const SizedBox(height: 4.0),
                                  const Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 16.0),
                                    child: Divider(),
                                  ),
                                  // prénom du candidat
                                  const SizedBox(height: 4.0),
                                  _buildDetailItem(
                                    Icons.perm_identity,
                                    candidature.prenomCandidat,
                                  ),
                                  const SizedBox(height: 4.0),
                                  const Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 16.0),
                                    child: Divider(),
                                  ),
                                  const SizedBox(height: 4.0),

                                  // date de naissance du candidat
                                  const SizedBox(height: 4.0),
                                  _buildDetailItem(
                                    Icons.cake,
                                    'Née le ${DateFormat('dd MMMM yyyy', 'fr_FR').format(candidature.dateDeNaissanceCandidat)}',
                                  ),
                                  const SizedBox(height: 4.0),
                                  const Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 16.0),
                                    child: Divider(),
                                  ),
                                  // nationalité du candidat
                                  const SizedBox(height: 4.0),
                                  _buildDetailItem(
                                    Icons.flag,
                                    candidature.nationalite,
                                  ),
                                  const Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 16.0),
                                    child: Divider(),
                                  ),
                                  const SizedBox(height: 4.0),
                                  // CV du candidat
                                  const SizedBox(height: 4.0),
                                  if (_cvDeposed) ...[
                                    Card(
                                      color: Colors.green,
                                      child: ListTile(
                                        leading: const Icon(Icons.description),
                                        title: const Text('Voir le CV'),
                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon:
                                                  const Icon(Icons.visibility),
                                              onPressed: () async {
                                                try {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          PdfViewPage(
                                                              url: candidature
                                                                  .CVCandidat),
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
                                          ],
                                        ),
                                      ),
                                    ),
                                  ] else ...[
                                    const Text(
                                      'CV non déposé',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ],
                                  const SizedBox(height: 4.0),
                                  const Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 16.0),
                                    child: Divider(),
                                  ),
                                  // lettre de motivation du candidat
                                  const SizedBox(height: 4.0),
                                  if (_lettreMotivationDeposed) ...[
                                    Card(
                                      color: Colors.green,
                                      child: ListTile(
                                        leading: const Icon(Icons.auto_stories),
                                        title: const Text(
                                            'Voir la lettre de motivation'),
                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon:
                                                  const Icon(Icons.visibility),
                                              onPressed: () async {
                                                try {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          PdfViewPage(
                                                              url: candidature
                                                                  .lettreMotivationCandidat),
                                                    ),
                                                  );
                                                } catch (e) {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                        content: Text(
                                                            'Erreur de chargement de la lettre de motivation: $e')),
                                                  );
                                                }
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ] else ...[
                                    const Text(
                                      'Lettre de motivation non déposée',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ],
                                  const Divider(),
                                ],
                                const SizedBox(height: 8.0),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'État de la candidature',
                                      style: TextStyle(
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8.0),
                                    _buildCandidatureStatus(candidature.etat),
                                    // ...
                                  ],
                                ),
                                if (isEmployer)
                                  ..._buildEmployerActions(context),
                                if (!isEmployer)
                                  ..._buildCandidateActions(context),
                              ],
                            );
                          }
                        },
                      )
                    ]),
              ),
            ),
          );
        });
  }

  Widget _buildCandidatureStatus(String etat) {
    IconData icon;
    String text;
    Color color;

    switch (etat) {
      case 'Attente':
        icon = Icons.hourglass_empty;
        text = 'Candidature en attente de validation de l\'employeur';
        color = Colors.orange;
        break;
      case 'Acceptee':
        icon = Icons.check_circle_outline;
        text =
            'Candidature validée par l\'employeur, en attente de confirmation du candidat';
        color = Colors.green;
        break;
      case 'Refusee':
        icon = Icons.cancel_outlined;
        text = 'Candidature refusée';
        color = Colors.red;
        break;
      case 'Validee':
        icon = Icons.check_circle;
        text = 'Candidature validée par les deux parties';
        color = Colors.deepPurpleAccent;
        break;
      default:
        icon = Icons.help_outline;
        text = 'État de la candidature inconnu';
        color = Colors.grey;
    }

    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(text, style: TextStyle(color: color)),
    );
  }

  // Accepter candidature
  void acceptCandidature() {
    FirebaseFirestore.instance
        .collection('candidatures')
        .doc(widget.idCandidature)
        .update({'etat': 'Acceptee'});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Candidature acceptée avec succès.'),
        backgroundColor: Colors.green,
      ),
    );
  }

  // Refuser candidature
  void refuseCandidature() {
    FirebaseFirestore.instance
        .collection('candidatures')
        .doc(widget.idCandidature)
        .update({'etat': 'Refusee'});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Candidature refusée avec succès.'),
        backgroundColor: Colors.red,
      ),
    );
  }

  // Annuler candidature
  void cancelCandidature() {
    navigatorKey.currentState!
        .pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false);
    FirebaseFirestore.instance
        .collection('candidatures')
        .doc(widget.idCandidature)
        .delete();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Candidature annulée avec succès.'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  // Confirmer candidature
  void confirmCandidature() {
    FirebaseFirestore.instance
        .collection('candidatures')
        .doc(widget.idCandidature)
        .update({'etat': 'Validee'});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Candidature confirmée avec succès.'),
        backgroundColor: Colors.green,
      ),
    );
  }

  // Contact pour employeur
  void contactEmployerTelephone(String numeroTelephone) async {
    String url = 'tel:$numeroTelephone';
    launch(url);
  }

  void contactEmployerEmail(String email) {
    String url = 'mailto:$email';
    launch(url);
  }

  // Contact pour candidat
  void contactCandidateTelephone(String numeroTelephone) {
    String url = 'tel:$numeroTelephone';
    launch(url);
  }

  void contactCandidateSMS(String numeroTelephone) {
    String url = 'sms:$numeroTelephone';
    launch(url);
  }

  void contactCandidateEmail(String email) {
    String url = 'mailto:$email';
    launch(url);
  }

  List<Widget> _buildEmployerActions(BuildContext context) {
    return [
      StreamBuilder<Candidature>(
        stream: _fetchCandidature(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const CircularProgressIndicator();
          }
          final candidature = snapshot.data!;
          if (candidature.etat == 'Attente') {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    acceptCandidature();
                  },
                  child: const Text('Accepter'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    refuseCandidature();
                  },
                  child: const Text('Refuser',
                      style: TextStyle(color: Colors.red)),
                ),
              ],
            );
          } else if (candidature.etat == 'Acceptee' ||
              candidature.etat == 'Validee') {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Contacter le candidat',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        // Action pour contacter par email
                        contactCandidateEmail(candidature.emailCandidat);
                      },
                      child: const Icon(Icons.email),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        contactCandidateTelephone(
                            candidature.numeroTelephoneCandidat);
                      },
                      child: const Icon(Icons.phone),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        // Action pour contacter par SMS
                        contactCandidateSMS(
                            candidature.numeroTelephoneCandidat);
                      },
                      child: const Icon(Icons.sms),
                    ),
                  ],
                ),
              ],
            );
          } else if (candidature.etat == 'Refusee') {
            return Center(
              child: ElevatedButton(
                onPressed: () {
                  refuseCandidature();
                },
                child: const Text('Reconsidérer',
                    style: TextStyle(color: Colors.red)),
              ),
            );
          } else {
            return Container();
          }
        },
      ),
    ];
  }

  List<Widget> _buildCandidateActions(BuildContext context) {
    return [
      StreamBuilder<Candidature>(
        stream: _fetchCandidature(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const CircularProgressIndicator();
          }
          final candidature = snapshot.data!;
          if (candidature.etat == 'Attente') {
            return Center(
              child: ElevatedButton(
                onPressed: () {
                  cancelCandidature();
                },
                child: const Text('Annuler la candidature',
                    style: TextStyle(color: Colors.red)),
              ),
            );
          } else if (candidature.etat == 'Acceptee') {
            return StreamBuilder<Annonce>(
              stream: _fetchAnnonce(candidature.annonce),
              builder: (context, snapshotAnnonce) {
                if (snapshotAnnonce.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final annonce = snapshotAnnonce.data!;
                return StreamBuilder<Employeur>(
                  stream: _fetchEmployeur(annonce.idEmployeur),
                  builder: (context, snapshotEmployeur) {
                    if (snapshotEmployeur.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final employeur = snapshotEmployeur.data!;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                confirmCandidature();
                              },
                              child: const Text('Confirmer l\'acceptation'),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton(
                              onPressed: () {
                                refuseCandidature();
                              },
                              child: const Text('Refuser',
                                  style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8.0),
                        const Text(
                          'Contacter l\'employeur',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (employeur.telephoneEntreprise != null)
                              ElevatedButton(
                                onPressed: () {
                                  contactEmployerTelephone(
                                      employeur.telephoneEntreprise!);
                                },
                                child: const Icon(Icons.phone),
                              ),
                            const SizedBox(width: 10),
                            ElevatedButton(
                              onPressed: () {
                                contactEmployerEmail(employeur.mail);
                              },
                              child: const Icon(Icons.email),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                );
              },
            );
          } else if (candidature.etat == 'Refusee') {
            return Center(
              child: ElevatedButton(
                onPressed: () {
                  navigatorKey.currentState!.pushNamedAndRemoveUntil(
                      '/home', (Route<dynamic> route) => false);
                },
                child: const Text('Retourner a la liste des annonces',
                    style: TextStyle(color: Colors.orange)),
              ),
            );
          } else if (candidature.etat == 'Validee') {
            return StreamBuilder<Annonce>(
              stream: _fetchAnnonce(candidature.annonce),
              builder: (context, snapshotAnnonce) {
                if (snapshotAnnonce.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final annonce = snapshotAnnonce.data!;
                return StreamBuilder<Employeur>(
                  stream: _fetchEmployeur(annonce.idEmployeur),
                  builder: (context, snapshotEmployeur) {
                    if (snapshotEmployeur.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final employeur = snapshotEmployeur.data!;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Contacter le candidat',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (employeur.telephoneEntreprise != null)
                              ElevatedButton(
                                onPressed: () {
                                  contactEmployerTelephone(
                                      employeur.telephoneEntreprise!);
                                },
                                child: const Icon(Icons.phone),
                              ),
                            const SizedBox(width: 10),
                            ElevatedButton(
                              onPressed: () {
                                contactEmployerEmail(employeur.mail);
                              },
                              child: const Icon(Icons.email),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                );
              },
            );
          } else {
            return Container();
          }
        },
      ),
    ];
  }
}
