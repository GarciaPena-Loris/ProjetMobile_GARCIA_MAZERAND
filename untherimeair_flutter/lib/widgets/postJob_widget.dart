import 'package:flutter/material.dart';

class PostJobWidget extends StatefulWidget {
  const PostJobWidget({super.key});

  @override
  _PostJobWidgetState createState() => _PostJobWidgetState();
}

class _PostJobWidgetState extends State<PostJobWidget> {
  final _formKey = GlobalKey<FormState>();
  String missionTitle = '';
  String location = '';
  int salary = 0;
  int hours = 0;
  String contractType = '';
  String description = '';
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();

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
                          labelText: 'Intitulé de la mission'),
                      onChanged: (value) {
                        setState(() {
                          missionTitle = value;
                        });
                      },
                    ),
                    TextFormField(
                      decoration:
                      const InputDecoration(labelText: 'Localisation'),
                      onChanged: (value) {
                        setState(() {
                          location = value;
                        });
                      },
                    ),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Description'),
                      onChanged: (value) {
                        setState(() {
                          description = value;
                        });
                      },
                    ),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Salaire'),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        setState(() {
                          salary = int.parse(value);
                        });
                      },
                    ),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Amplitude horaire'),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        setState(() {
                          hours = int.parse(value);
                        });
                      },
                    ),
                    TextFormField(
                      decoration:
                      const InputDecoration(labelText: 'Type de contrat'),
                      onChanged: (value) {
                        setState(() {
                          contractType = value;
                        });
                      },
                    ),
                    ElevatedButton(
                      onPressed: () {
                        showDatePicker(
                          context: context,
                          initialDate: startDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        ).then((pickedDate) {
                          if (pickedDate == null) {
                            return;
                          }
                          setState(() {
                            startDate = pickedDate;
                          });
                        });
                      },
                      child: Text('Date de début : ${startDate.toLocal()}'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        showDatePicker(
                          context: context,
                          initialDate: endDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        ).then((pickedDate) {
                          if (pickedDate == null) {
                            return;
                          }
                          setState(() {
                            endDate = pickedDate;
                          });
                        });
                      },
                      child: Text('Date de fin : ${endDate.toLocal()}'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          // Sauvegardez les données dans la base de données
                        }
                      },
                      child: const Text('Poster l\'offre'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}