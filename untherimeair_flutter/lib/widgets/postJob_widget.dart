import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';
import 'package:intl/intl.dart';

class PostJobWidget extends StatefulWidget {
  const PostJobWidget({super.key});

  @override
  _PostJobWidgetState createState() => _PostJobWidgetState();
}

class _PostJobWidgetState extends State<PostJobWidget> {
  final _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();
  String missionTitle = '';
  String location = '';
  double salary = 0;
  double hours = 0;
  String description = '';
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();
  String googleApikey = "AIzaSyDUorwJ9WpDUzfWRafEBeuLSrxbPN6S0VY";

  @override
  void initState() {
    super.initState();
  }

  Future<void> _choisirDateDebut(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: startDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != startDate) {
      setState(() {
        startDate = picked;
      });
    }
  }

  Future<void> _choisirDateFin(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: endDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != endDate) {
      setState(() {
        endDate = picked;
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
            title: const Text('Poster une offre'),
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
                          prefixIcon: Icon(Icons.title)),
                      onChanged: (value) {
                        setState(() {
                          missionTitle = value;
                        });
                      },
                    ),
                    TextFormField(
                      decoration: const InputDecoration(
                          labelText: 'Description',
                          prefixIcon: Icon(Icons.description)),
                      onChanged: (value) {
                        setState(() {
                          description = value;
                        });
                      },
                    ),
                    TextFormField(
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Localisation',
                        prefixIcon: Icon(Icons.search),
                      ),
                      controller: TextEditingController(text: location),
                    ),
                    // Autres champs de saisie pour salary, hours, startDate, endDate, etc.
                    const SizedBox(height: 20),
                    SpinBox(
                      min: 0,
                      max: 10000,
                      value: salary,
                      onChanged: (value) => setState(() => salary = value),
                      decoration: const InputDecoration(labelText: 'Salaire'),
                    ),
                    const SizedBox(height: 20),
                    SpinBox(
                      min: 0,
                      max: 24,
                      value: hours,
                      onChanged: (value) => setState(() => hours = value),
                      decoration:
                          const InputDecoration(labelText: 'Amplitude horaire'),
                    ),
                    InkWell(
                      onTap: () => _choisirDateDebut(context),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Date de début : ${startDate.toLocal()}',
                          prefixIcon: const Icon(Icons.calendar_today),
                        ),
                        child: Text(DateFormat('d MMMM yyyy', 'fr_FR')
                            .format(startDate)),
                      ),
                    ),
                    InkWell(
                      onTap: () => _choisirDateFin(context),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Date de fin : ${endDate.toLocal()}',
                          prefixIcon: const Icon(Icons.calendar_today),
                        ),
                        child: Text(
                            DateFormat('d MMMM yyyy', 'fr_FR').format(endDate)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity, // Largeur maximale
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            // Sauvegardez les données dans la base de données
                            await _firestore.collection('jobs').add({
                              'missionTitle': missionTitle,
                              'location': location,
                              'salary': salary,
                              'hours': hours,
                              'description': description,
                              'startDate': startDate,
                              'endDate': endDate,
                              // 'locationCoordinates': {
                              //   'latitude': _locationCoordinates?.latitude,
                              //   'longitude': _locationCoordinates?.longitude,
                              // },
                            });
                          }
                        },
                        child: const Text('Poster l\'offre'),
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
