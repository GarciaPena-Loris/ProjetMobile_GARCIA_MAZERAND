import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditEmployerProfilePage extends StatefulWidget {
  final Map<String, dynamic> employeurData;

  EditEmployerProfilePage({required this.employeurData});

  @override
  _EditEmployerProfilePageState createState() => _EditEmployerProfilePageState();
}

class _EditEmployerProfilePageState extends State<EditEmployerProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _telephoneController;
  late TextEditingController _adresseController;
  late TextEditingController _entrepriseController;
  late TextEditingController _siteWebController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.employeurData['nom']);
    _emailController = TextEditingController(text: widget.employeurData['mail']);
    _telephoneController = TextEditingController(text: widget.employeurData['telephoneEntreprise']);
    _adresseController = TextEditingController(text: widget.employeurData['adresseEntreprise']);
    _entrepriseController = TextEditingController(text: widget.employeurData['nomEntreprise']);
    _siteWebController = TextEditingController(text: widget.employeurData['siteWebEntreprise']);
    _descriptionController = TextEditingController(text: widget.employeurData['descriptionEntreprise']);
  }

  Future<void> _updateEmployerProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('employeurs').doc(user.uid).update({
        'nom': _nameController.text,
        'mail': _emailController.text,
        'telephoneEntreprise': _telephoneController.text,
        'adresseEntreprise': _adresseController.text,
        'nomEntreprise': _entrepriseController.text,
        'siteWebEntreprise': _siteWebController.text,
        'descriptionEntreprise': _descriptionController.text,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profil mis à jour avec succès'), backgroundColor: Colors.green),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur de mise à jour du profil'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifier le profil'),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: <Widget>[
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nom',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre nom';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre email';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _telephoneController,
                decoration: const InputDecoration(
                  labelText: 'Téléphone',
                  prefixIcon: Icon(Icons.phone),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre numéro de téléphone';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _adresseController,
                decoration: const InputDecoration(
                  labelText: 'Adresse',
                  prefixIcon: Icon(Icons.location_city),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre adresse';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _entrepriseController,
                decoration: const InputDecoration(
                  labelText: 'Nom de l\'entreprise',
                  prefixIcon: Icon(Icons.business),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer le nom de l\'entreprise';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _siteWebController,
                decoration: const InputDecoration(
                  labelText: 'Site web de l\'entreprise',
                  prefixIcon: Icon(Icons.web),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer le site web de l\'entreprise';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description de l\'entreprise',
                  prefixIcon: Icon(Icons.description),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer une description de l\'entreprise';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _updateEmployerProfile();
                  }
                },
                child: const Text('Mettre à jour'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
