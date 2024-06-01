import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';
import 'package:intl/intl.dart';
import '../models/annonce_modele.dart';
import '../services/annonce_service.dart';
import 'package:http/http.dart' as http;

class EditAnnonceScreen extends StatefulWidget {
  final Annonce annonce;

  const EditAnnonceScreen({super.key, required this.annonce});

  @override
  _EditAnnonceScreenState createState() => _EditAnnonceScreenState();
}

class _EditAnnonceScreenState extends State<EditAnnonceScreen> {
  final _annonceService = AnnonceService();

  final _formKey = GlobalKey<FormState>();
  late TextEditingController _metierCibleController;
  late TextEditingController _descriptionController;
  late TextEditingController _villeController;

  double remuneration = 11.65;
  double amplitudeHoraire = 1;
  DateTime dateDebut = DateTime.now();
  DateTime dateFin = DateTime.now().add(const Duration(days: 1));
  double? latitude;
  double? longitude;
  String googleApikey = "AIzaSyDUorwJ9WpDUzfWRafEBeuLSrxbPN6S0VY";

  @override
  void initState() {
    super.initState();
    _metierCibleController = TextEditingController(text: widget.annonce.metierCible);
    _descriptionController = TextEditingController(text: widget.annonce.description);
    _villeController = TextEditingController(text: widget.annonce.ville);
    remuneration = widget.annonce.remuneration;
    amplitudeHoraire = widget.annonce.amplitudeHoraire;
    dateDebut = widget.annonce.dateDebut;
    dateFin = widget.annonce.dateFin;
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

  void _updateAnnonce() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Récupérer les coordonnées de la ville
      bool coordinatesFound = await _getCoordinates(_villeController.text);
      if (!coordinatesFound) {
        return;
      }

      try {
        await _annonceService.updateAnnonce(
          idAnnonce: widget.annonce.idAnnonce,
          titreMission: _metierCibleController.text,
          description: _descriptionController.text,
          localisation: _villeController.text,
          salaire: remuneration,
          emplacement: [latitude!, longitude!],
          amplitudeHoraire: amplitudeHoraire,
          dateDebut: dateDebut,
          dateFin: dateFin,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Annonce modifiée avec succès.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } catch (e) {
        // Gérer l'erreur
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifier l\'annonce'),
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
                  controller: _metierCibleController,
                  decoration: const InputDecoration(
                      labelText: 'Intitulé de la mission',
                      prefixIcon: Icon(Icons.format_quote)),
                ),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                      labelText: 'Description',
                      prefixIcon: Icon(Icons.newspaper)),
                ),
                TextFormField(
                  controller: _villeController,
                  decoration: const InputDecoration(
                    labelText: 'Localisation',
                    prefixIcon: Icon(Icons.map),
                  ),
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
                  decoration:
                      const InputDecoration(labelText: 'Salaire horaire brut'),
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
                    child: Text(
                        DateFormat('d MMMM yyyy', 'fr_FR').format(dateDebut)),
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
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _updateAnnonce,
                    child: const Text('Enregistrer les modifications'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
