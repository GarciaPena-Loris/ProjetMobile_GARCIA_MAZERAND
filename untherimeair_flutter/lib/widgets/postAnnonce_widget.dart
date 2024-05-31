import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:untherimeair_flutter/screens/profilEmployer_screen.dart';

import '../models/annonce_modele.dart';
import '../services/annonce_service.dart';

class PostAnnonceWidget extends StatefulWidget {
  const PostAnnonceWidget({super.key});

  @override
  _PostAnnonceWidgetState createState() => _PostAnnonceWidgetState();
}

class _PostAnnonceWidgetState extends State<PostAnnonceWidget> {
  final _annonceService = AnnonceService();
  final user = FirebaseAuth.instance.currentUser!;

  final _formKey = GlobalKey<FormState>();
  String metierCible = '';
  String ville = '';
  double remuneration = 11.65;
  double amplitudeHoraire = 1;
  String description = '';
  DateTime dateDebut = DateTime.now();
  DateTime dateFin = DateTime.now().add(const Duration(days: 1));
  double? latitude;
  double? longitude;
  String googleApikey = "AIzaSyDUorwJ9WpDUzfWRafEBeuLSrxbPN6S0VY";

  @override
  void initState() {
    super.initState();
  }

  Future<bool> _getCoordinates(String city) async {
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
          setState(() {
            latitude = location['lat'];
            longitude = location['lng'];
          });
          return true;
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
      return false;
    }
  }

  Future<void> postJob() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Récupérer les coordonnées de la ville
      bool coordinatesFound = await _getCoordinates(ville);
      if (!coordinatesFound) {
        return;
      }

      Annonce? annonce = await _annonceService.ajouterAnnonce(
        idEmployeur: user.uid,
        description: description,
        dateDebut: dateDebut,
        dateFin: dateFin,
        datePublication: DateTime.now(),
        emplacement: [latitude!, longitude!],
        metierCible: metierCible,
        remuneration: remuneration,
        ville: ville,
        amplitudeHoraire: amplitudeHoraire,
      );

      if (annonce != null) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const ProfilEmployerScreen()));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Annonce postée avec succès.'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception('Erreur lors de la création de l\'annonce.');
      }
    }
  }

  Future<void> _choisirDateDebut(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: dateDebut,
      firstDate: DateTime.now(),
      lastDate: DateTime.now()
          .add(const Duration(days: 365 * 5)), // 5 years in the future
    );
    if (picked != null && picked != dateDebut) {
      setState(() {
        dateDebut = picked;
        if (dateFin.isBefore(dateDebut)) {
          dateFin = dateDebut.add(const Duration(days: 1));
        }
      });
    }
  }

  Future<void> _choisirDateFin(BuildContext context) async {
    if (dateFin.isBefore(dateDebut)) {
      dateFin = dateDebut;
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: dateFin,
      firstDate: dateDebut.add(const Duration(days: 1)),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != dateFin) {
      setState(() {
        dateFin = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: MediaQuery.of(context)
            .size
            .height, // Set the height to the screen height
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Poster une nouvelle mission'),
          ),
          body: SingleChildScrollView(
            // Ajout de SingleChildScrollView
            child: Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      decoration: const InputDecoration(
                          labelText: 'Intitulé de la mission',
                          prefixIcon: Icon(Icons.format_quote)),
                      onChanged: (value) {
                        setState(() {
                          metierCible = value;
                        });
                      },
                    ),
                    TextFormField(
                      decoration: const InputDecoration(
                          labelText: 'Description',
                          prefixIcon: Icon(Icons.newspaper)),
                      onChanged: (value) {
                        setState(() {
                          description = value;
                        });
                      },
                    ),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Ville',
                        prefixIcon: Icon(Icons.map),
                      ),
                      onChanged: (value) {
                        setState(() {
                          ville = value;
                        });
                      },
                    ),
                    // Autres champs de saisie pour salary, hours, startDate, endDate, etc.
                    const SizedBox(height: 20),
                    SpinBox(
                      min: 9,
                      max: 1000,
                      step: 0.01,
                      decimals: 2,
                      acceleration: 2.0,
                      value: remuneration,
                      onChanged: (value) => setState(() => remuneration = value),
                      decoration: const InputDecoration(
                          labelText: 'Salaire horaire brut'),
                    ),
                    const SizedBox(height: 20),
                    SpinBox(
                      min: 1,
                      max: 12,
                      value: amplitudeHoraire,
                      onChanged: (value) =>
                          setState(() => amplitudeHoraire = value),
                      decoration:
                          const InputDecoration(labelText: 'Amplitude horaire'),
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: () => _choisirDateDebut(context),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Date de début',
                          prefixIcon: Icon(Icons.today),
                        ),
                        child: Text(DateFormat('d MMMM yyyy', 'fr_FR')
                            .format(dateDebut)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: () => _choisirDateFin(context),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Date de fin',
                          prefixIcon: Icon(Icons.event),
                        ),
                        child: Text(
                            DateFormat('d MMMM yyyy', 'fr_FR').format(dateFin)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity, // Largeur maximale
                      child: ElevatedButton(
                        onPressed: postJob,
                        child: const Text('Poster la mission'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}
