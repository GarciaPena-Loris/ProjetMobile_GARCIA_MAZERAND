import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../models/utilisateur_modele.dart';

class EditProfilePage extends StatefulWidget {
  final Utilisateur utilisateur;

  const EditProfilePage({super.key, required this.utilisateur});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _prenomController;
  late TextEditingController _emailController;
  late TextEditingController _dateNaissanceController;
  late TextEditingController _nationaliteController;
  late TextEditingController _telephoneController;
  late TextEditingController _villeController;
  late TextEditingController _commentaireController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.utilisateur.nom);
    _prenomController = TextEditingController(text: widget.utilisateur.prenom);
    _emailController = TextEditingController(text: widget.utilisateur.mail);
    _dateDeNaissance = widget.utilisateur.dateDeNaissance;
    _dateNaissanceController = TextEditingController(
        text: _dateDeNaissance != null ? DateFormat('d MMMM yyyy', 'fr_FR').format(_dateDeNaissance!) : ''
    );
    _nationaliteController = TextEditingController(text: widget.utilisateur.nationalite ?? '');
    _telephoneController = TextEditingController(text: widget.utilisateur.telephone ?? '');
    _villeController = TextEditingController(text: widget.utilisateur.ville ?? '');
    _commentaireController = TextEditingController(text: widget.utilisateur.commentaire ?? '');
  }
DateTime? _dateDeNaissance;

  Future<void> _choisirDateDeNaissance(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dateDeNaissance ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      locale: const Locale('fr', 'FR'),
    );
    if (picked != null && picked != _dateDeNaissance) {
      setState(() {
        _dateDeNaissance = picked;
        _dateNaissanceController.text = DateFormat('d MMMM yyyy', 'fr_FR').format(picked);
      });
    }
  }

  Future<void> _updateUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('utilisateurs').doc(user.uid).update({
        'nom': _nameController.text,
        'prenom': _prenomController.text,
        'mail': _emailController.text,
        'dateDeNaissance': _dateDeNaissance,
        'nationalite': _nationaliteController.text,
        'telephone': _telephoneController.text,
        'ville': _villeController.text,
        'commentaire': _commentaireController.text,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil mis à jour avec succès'), backgroundColor: Colors.green),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur de mise à jour du profil'), backgroundColor: Colors.red),
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
                controller: _prenomController,
                decoration: const InputDecoration(
                  labelText: 'Prénom',
                  prefixIcon: Icon(Icons.perm_identity),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre prénom';
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
              InkWell(
                onTap: () => _choisirDateDeNaissance(context),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date de naissance',
                    prefixIcon: Icon(Icons.calendar_today), // Icône de calendrier
                  ),
                  child: _dateNaissanceController.text.isEmpty
                      ? const Text('')
                      : Text(_dateNaissanceController.text), // Formattez la date de naissance en français
                ),
              ),
              TextFormField(
                controller: _nationaliteController,
                decoration: const InputDecoration(
                  labelText: 'Nationalité',
                  prefixIcon: Icon(Icons.flag),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre nationalité';
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
                controller: _villeController,
                decoration: const InputDecoration(
                  labelText: 'Ville',
                  prefixIcon: Icon(Icons.location_city),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre ville';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _commentaireController,
                decoration: const InputDecoration(
                  labelText: 'Commentaire',
                  prefixIcon: Icon(Icons.comment),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _updateUserProfile();
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
