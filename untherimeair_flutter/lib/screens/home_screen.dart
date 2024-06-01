import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:untherimeair_flutter/screens/profilEmployer_screen.dart';
import 'package:untherimeair_flutter/screens/profilUser_screen.dart';
import 'package:untherimeair_flutter/widgets/generateAnnonce_widget.dart';
import 'package:untherimeair_flutter/widgets/postAnnonce_widget.dart';
import 'package:untherimeair_flutter/widgets/search_widget.dart';
import 'package:untherimeair_flutter/services/storage_service.dart';

import '../models/annonce_modele.dart';
import '../services/annonce_service.dart';
import '../widgets/annonce_widget.dart';
import 'package:geocoding/geocoding.dart';

import 'auth_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}
class Coordinates {
  final double latitude;
  final double longitude;

  Coordinates({required this.latitude, required this.longitude});
}


class _HomeScreenState extends State<HomeScreen> {
  List<DocumentSnapshot> _annonces = [];
  final AnnonceService _annonceService = AnnonceService();
  final StorageService _storageService = StorageService();

  Timer? _longPressTimer;

  void _startLongPressTimer(BuildContext context) {
    _longPressTimer = Timer(const Duration(seconds: 5), () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => GenerateAdsWidget()),
      );
    });
  }






  void _cancelLongPressTimer() {
    if (_longPressTimer != null) {
      _longPressTimer!.cancel();
      _longPressTimer = null;
    }
  }


  Future<bool> getEmployeurStatus() async {
    return await _storageService.getEmployeurStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onLongPressStart: (details) => _startLongPressTimer(context),
          onLongPressEnd: (details) => _cancelLongPressTimer(),
          child: const Text('Un Thé Rime Air'),
        ),
        actions: [
          StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                // Si l'utilisateur est connecté, affichez "Profil" avec une icône d'utilisateur
                return FutureBuilder<bool>(
                  future: getEmployeurStatus(),
                  builder:
                      (BuildContext context, AsyncSnapshot<bool> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Erreur: ${snapshot.error}');
                    } else {
                      if (snapshot.data == true) {
                        return TextButton.icon(
                          icon: const Icon(Icons.person),
                          // Icône d'utilisateur
                          label: const Text('Profil'),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const ProfilEmployerScreen()),
                            );
                          },
                        );
                      } else {
                        return TextButton.icon(
                          icon: const Icon(Icons.person),
                          // Icône d'utilisateur
                          label: const Text('Profil'),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const ProfilUserScreen()),
                            );
                          },
                        );
                      }
                    }
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
      body: FutureBuilder<bool>(
        future: getEmployeurStatus(),
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Erreur: ${snapshot.error}');
          } else {
            if (snapshot.data == true) {
              return const PostAnnonceWidget();
            } else {
              return Column(
                children: [
                  Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SizedBox(
                        width: double.infinity, // Largeur maximale
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.search),
                          // Icône de recherche
                          label: const Text('Rechercher'),
                          onPressed: () {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                builder: (context) => FractionallySizedBox(
                                  heightFactor: 0.7,
                                  child: Search(
                                    onSearch: (metier, ville, distance) {

                                    },
                                  ),
                                ),
                              );
                            });
                          },
                        ),
                      )),
                  Expanded(
                    child: StreamBuilder<List<Annonce>>(
                      stream: _annonceService.getAnnonces(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
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
              );
            }
          }
        },
      ),
    );
  }
}
