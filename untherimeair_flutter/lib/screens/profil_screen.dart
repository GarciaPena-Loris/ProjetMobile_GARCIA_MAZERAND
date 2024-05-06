import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:untherimeair_flutter/models/utilisateur_modele.dart';

class ProfilScreen extends StatelessWidget {
  const ProfilScreen({super.key});

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
            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('utilisateurs')
                  .doc(user!.uid)
                  .get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(child: Text('Erreur de chargement du profil'));
                } else if (snapshot.hasData) {
                  Utilisateur utilisateur =
                      Utilisateur.fromFirestore(snapshot.data!);
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          utilisateur.nom,
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          utilisateur.prenom,
                          style: const TextStyle(fontSize: 20),
                        ),
                        Text(
                          utilisateur.mail,
                          style: const TextStyle(fontSize: 16),
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
                child: Text('Veuillez vous connecter pour voir le profil'));
          }
        },
      ),
    );
  }
}
