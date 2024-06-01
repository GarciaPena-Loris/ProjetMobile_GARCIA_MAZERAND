import 'package:flutter/material.dart';

import '../services/storage_service.dart';
import 'annonce_screen.dart';

class CandidatureDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> candidature;

  const CandidatureDetailsScreen({super.key, required this.candidature});

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
    final StorageService storageService = StorageService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails de la candidature'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<bool>(
          future: storageService.getEmployeurStatus(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Center(
                  child: Text('Erreur de chargement des données.'));
            } else {
              bool isEmployer = snapshot.data ?? false;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailItem(
                      Icons.hourglass_empty, 'État: ${candidature['etat']}'),
                  const Divider(),
                  if (!isEmployer) ...[
                    ElevatedButton(
                      onPressed: () {
                        // Action pour voir l'annonce
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AnnonceScreen(
                              idAnnonce: candidature['annonce'][
                                  'idAnnonce'], // Assurez-vous que l'annonce a un champ idAnnonce
                            ),
                          ),
                        );
                      },
                      child: const Text('Voir annonce'),
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          onPressed: () {
                            // Action pour contacter par téléphone
                          },
                          icon: const Icon(Icons.phone),
                        ),
                        IconButton(
                          onPressed: () {
                            // Action pour contacter par SMS
                          },
                          icon: const Icon(Icons.sms),
                        ),
                        IconButton(
                          onPressed: () {
                            // Action pour contacter par email
                          },
                          icon: const Icon(Icons.email),
                        ),
                      ],
                    ),
                  ],
                  if (isEmployer) ...[
                    _buildDetailItem(Icons.person,
                        'Nom: ${candidature['nomCandidat'] ?? 'Non spécifié'}'),
                    _buildDetailItem(Icons.person_outline,
                        'Prénom: ${candidature['prenomCandidat'] ?? 'Non spécifié'}'),
                    const Divider(),
                    ElevatedButton(
                      onPressed: () {
                        // Action pour voir l'annonce
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AnnonceScreen(
                              idAnnonce: candidature['annonce'][
                                  'idAnnonce'], // Assurez-vous que l'annonce a un champ idAnnonce
                            ),
                          ),
                        );
                      },
                      child: const Text('Voir annonce'),
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          onPressed: () {
                            // Action pour contacter par téléphone
                          },
                          icon: const Icon(Icons.phone),
                        ),
                        IconButton(
                          onPressed: () {
                            // Action pour contacter par SMS
                          },
                          icon: const Icon(Icons.sms),
                        ),
                        IconButton(
                          onPressed: () {
                            // Action pour contacter par email
                          },
                          icon: const Icon(Icons.email),
                        ),
                      ],
                    ),
                  ],
                  if (isEmployer) ..._buildEmployerActions(context),
                  if (!isEmployer) ..._buildCandidateActions(context),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  List<Widget> _buildEmployerActions(BuildContext context) {
    return [
      const Text('Actions:', style: TextStyle(fontWeight: FontWeight.bold)),
      if (candidature['etat'] == 'Attente') ...[
        ElevatedButton(
          onPressed: () {
            // Action pour accepter la candidature
          },
          child: const Text('Accepter'),
        ),
        ElevatedButton(
          onPressed: () {
            // Action pour refuser la candidature
          },
          child: const Text('Refuser'),
        ),
      ],
      if (candidature['etat'] == 'Acceptee') ...[
        ElevatedButton(
          onPressed: () {
            // Action pour valider la candidature
          },
          child: const Text('Valider'),
        ),
        ElevatedButton(
          onPressed: () {
            // Action pour contacter le candidat
          },
          child: const Text('Contacter le candidat'),
        ),
      ],
      if (candidature['etat'] == 'Refusee') ...[
        ElevatedButton(
          onPressed: () {
            // Action pour reconsidérer la candidature
          },
          child: const Text('Reconsidérer'),
        ),
      ],
      if (candidature['etat'] == 'Validee') ...[
        ElevatedButton(
          onPressed: () {
            // Action pour contacter le candidat
          },
          child: const Text('Contacter le candidat'),
        ),
      ],
    ];
  }

  List<Widget> _buildCandidateActions(BuildContext context) {
    return [
      const Text('Actions:', style: TextStyle(fontWeight: FontWeight.bold)),
      if (candidature['etat'] == 'Attente') ...[
        ElevatedButton(
          onPressed: () {
            // Action pour annuler la candidature
          },
          child: const Text('Annuler la candidature'),
        ),
      ],
      if (candidature['etat'] == 'Acceptee') ...[
        ElevatedButton(
          onPressed: () {
            // Action pour confirmer l'acceptation
          },
          child: const Text('Confirmer l\'acceptation'),
        ),
        ElevatedButton(
          onPressed: () {
            // Action pour contacter l'employeur
          },
          child: const Text('Contacter l\'employeur'),
        ),
      ],
      if (candidature['etat'] == 'Refusee') ...[
        ElevatedButton(
          onPressed: () {
            // Action pour reconsidérer une autre annonce
          },
          child: const Text('Reconsidérer une autre annonce'),
        ),
      ],
      if (candidature['etat'] == 'Validee') ...[
        ElevatedButton(
          onPressed: () {
            // Action pour contacter l'employeur
          },
          child: const Text('Contacter l\'employeur'),
        ),
      ],
    ];
  }
}
