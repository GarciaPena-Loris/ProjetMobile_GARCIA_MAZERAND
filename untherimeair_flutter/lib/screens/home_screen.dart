import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:rxdart/rxdart.dart';
import 'package:untherimeair_flutter/screens/profilEmployer_screen.dart';
import 'package:untherimeair_flutter/screens/profilUser_screen.dart';
import 'package:untherimeair_flutter/widgets/generateAnnonce_widget.dart';
import 'package:untherimeair_flutter/widgets/postAnnonce_widget.dart';
import 'package:untherimeair_flutter/widgets/search_widget.dart';
import 'package:untherimeair_flutter/services/storage_service.dart';
import 'package:http/http.dart' as http;

import '../models/annonce_modele.dart';
import '../services/annonce_service.dart';
import '../widgets/annonce_widget.dart';
import 'auth_screen.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AnnonceService _annonceService = AnnonceService();
  final StorageService _storageService = StorageService();
  final BehaviorSubject<List<Annonce>> _annoncesSubject = BehaviorSubject<List<Annonce>>();

  Timer? _longPressTimer;
  String googleApikey = "AIzaSyDUorwJ9WpDUzfWRafEBeuLSrxbPN6S0VY";

  @override
  void initState() {
    super.initState();
    _getCurrentLocation().then((location) {
      onSearch('', '', 10); // Remplacez 10 par la distance maximale que vous souhaitez
    });
  }

  Future<List<double>> _getCoordinates(String city) async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://maps.googleapis.com/maps/api/geocode/json?address=$city,France&key=$googleApikey',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          print("Ville trouvée: $data");
          final location = data['results'][0]['geometry']['location'];
          double latitude = location['lat'];
          double longitude = location['lng'];
          return [latitude, longitude];
        } else {
          throw Exception('Erreur: ${data['status']}');
        }
      } else {
        throw Exception('Failed to get coordinates');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Ville non trouvée, veuillez renseigner une ville plus grande à proximité.'),
          backgroundColor: Colors.red,
        ),
      );
      return [];
    }
  }
  Future<List<double>> _getCurrentLocation() async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://www.googleapis.com/geolocation/v1/geolocate?key=$googleApikey',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        double latitude = data['location']['lat'];
        double longitude = data['location']['lng'];
        return [latitude, longitude];
      } else {
        throw Exception('Failed to get current location');
      }
    } catch (e) {
      print('Erreur lors de la récupération de la localisation : $e');
      return [];
    }
  }

  Future<void> _loadAnnonces() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _annonceService.getAnnonces(user.uid).listen((annonces) {
        _annoncesSubject.add(annonces);
      });
    } else {
      _annonceService.getAnnonces().listen((annonces) {
        _annoncesSubject.add(annonces);
      });
    }
  }

  @override
  void dispose() {
    _annoncesSubject.close();
    super.dispose();
  }

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

  void onSearch(String metier, String ville, double distance) async {
    try {
      List<QueryDocumentSnapshot> docs = [];

      if (metier.isNotEmpty) {
        // Filtrer les annonces en fonction du métier cible avec correspondance partielle
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('annonces')
            .where('metierCible', isGreaterThanOrEqualTo: metier)
            .where('metierCible', isLessThanOrEqualTo: '$metier\uf8ff')
            .get();
        docs = querySnapshot.docs;
      } else {
        // Si le métier n'est pas renseigné, récupérer toutes les annonces
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('annonces')
            .get();
        docs = querySnapshot.docs;
      }
      List<double> locations = await _getCoordinates(ville);

      if (ville.isNotEmpty) {
        // Récupérer la position de la ville
        locations = await _getCoordinates(ville);

        List<QueryDocumentSnapshot> filteredDocs = [];

        // Filtrer les annonces en fonction de la distance
        for (var doc in docs) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          GeoPoint emplacement = data['emplacement'];
          double annonceLat = emplacement.latitude;
          double annonceLong = emplacement.longitude;
          double distanceInMeters = Geolocator.distanceBetween(
              locations[0], locations[1], annonceLat, annonceLong);

          if (distanceInMeters / 1000 <= distance) {
            filteredDocs.add(doc);
          }
        }

        docs = filteredDocs;
      }

      // Convertir les documents en objets Annonce
      List<Annonce> filteredAnnonces = docs.map((doc) => Annonce.fromFirestore(doc)).toList();
      _annoncesSubject.add(filteredAnnonces);
    } catch (e) {
      print('Erreur de recherche: $e');
    }
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
                return FutureBuilder<bool>(
                  future: getEmployeurStatus(),
                  builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Erreur: ${snapshot.error}');
                    } else {
                      if (snapshot.data == true) {
                        return TextButton.icon(
                          icon: const Icon(Icons.person),
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
                return TextButton.icon(
                  icon: const Icon(Icons.person),
                  label: const Text('Connexion'),
                  onPressed: () {
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
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          } else {
            if (snapshot.data == true) {
              return const PostAnnonceWidget();
            } else {
              return Column(
                children: [
                  Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.search),
                          label: const Text('Rechercher'),
                          onPressed: () {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                builder: (context) => FractionallySizedBox(
                                  heightFactor: 0.7,
                                  child: Search(
                                    onSearch: onSearch,
                                  ),
                                ),
                              );
                            });
                          },
                        ),
                      )),
                  Expanded(
                    child: StreamBuilder<List<Annonce>>(
                      stream: _annoncesSubject.stream,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return const Center(child: Text('Erreur de chargement des annonces'));
                        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Center(child: Text('Aucune annonce trouvée'));
                        } else {
                          List<Annonce> annonces = snapshot.data!;
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
