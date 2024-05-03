import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:untherimeair_flutter/models/utilisateur_modele.dart';

class ProfilScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profil'),
      ),
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur de chargement du profil'));
          } else if (snapshot.hasData) {
            User? user = snapshot.data;
            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('utilisateurs')
                  .doc(user!.uid)
                  .get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Erreur de chargement du profil'));
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
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          utilisateur.prenom,
                          style: TextStyle(fontSize: 20),
                        ),
                        Text(
                          utilisateur.mail,
                          style: TextStyle(fontSize: 16),
                        ),
                        // Ajoutez ici d'autres informations que vous souhaitez afficher
                      ],
                    ),
                  );
                } else {
                  return Center(child: Text('Aucun profil trouvé'));
                }
              },
            );
          } else {
            return Center(
                child: Text('Veuillez vous connecter pour voir le profil'));
          }
        },
      ),
    );
  }
}
