import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:untherimeair_flutter/screens/profil_screen.dart';
import 'package:untherimeair_flutter/widgets/search_widget.dart';

import '../models/annonce_modele.dart';
import '../services/annonce_service.dart';
import '../widgets/annonce_widget.dart';

import 'auth_screen.dart';

class HomeScreen extends StatelessWidget {
  final AnnonceService _annonceService = AnnonceService();

  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Un Thé Rime Air'),
        actions: [
          StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                // Si l'utilisateur est connecté, affichez "Profil" avec une icône d'utilisateur
                return TextButton.icon(
                  icon: const Icon(Icons.person), // Icône d'utilisateur
                  label: const Text('Profil'),
                  onPressed: () {
                    // Redirection vers l'écran de profil
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ProfilScreen()),
                    );
                  },
                );
              } else {
                // Si l'utilisateur n'est pas connecté, affichez "Connexion" avec une icône de connexion
                return TextButton.icon(
                  icon: const Icon(Icons.person), // Icône de connexion
                  label: const Text('Connexion'),
                  onPressed: () {
                    // Redirection vers l'écran d'authentification
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AuthScreen()),
                    );
                  },
                );
              }
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.search), // Icône de recherche
              label: const Text('Rechercher'),
              onPressed: () {
                WidgetsBinding.instance!.addPostFrameCallback((_) {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (context) => FractionallySizedBox(
                      heightFactor: 0.7,
                      child: Search(
                        onSearch: (arg1, arg2, arg3) {
                          // Ajoutez la logique de recherche ici
                        },
                      ),
                    ),
                  );
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Annonce>>(
              stream: _annonceService.getAnnonces(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(
                      child: Text('Erreur de chargement des annonces'));
                } else {
                  List<Annonce> annonces = snapshot.data ?? [];
                  return ListView.builder(
                    itemCount: annonces.length,
                    itemBuilder: (context, index) {
                      return AnnonceWidget(annonce: annonces[index]);
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
