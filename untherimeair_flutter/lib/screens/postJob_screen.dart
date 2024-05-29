import 'package:flutter/material.dart';

class PostJobScreen extends StatefulWidget {
  @override
  _PostJobScreenState createState() => _PostJobScreenState();
}

class _PostJobScreenState extends State<PostJobScreen> {
  final _formKey = GlobalKey<FormState>();
  String missionTitle = '';
  String location = '';
  double salary = 0.0;
  String hours = '';
  String contractType = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Poster une offre'),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(labelText: 'Intitulé de la mission'),
                onChanged: (value) {
                  setState(() {
                    missionTitle = value;
                  });
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Localisation'),
                onChanged: (value) {
                  setState(() {
                    location = value;
                  });
                },
              ),
              Slider(
                value: salary,
                min: 0,
                max: 10000,
                divisions: 100,
                label: salary.round().toString(),
                onChanged: (double value) {
                  setState(() {
                    salary = value;
                  });
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Horaires'),
                onChanged: (value) {
                  setState(() {
                    hours = value;
                  });
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Type de contrat'),
                onChanged: (value) {
                  setState(() {
                    contractType = value;
                  });
                },
              ),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Sauvegardez les données dans la base de données
                  }
                },
                child: Text('Poster l\'offre'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}