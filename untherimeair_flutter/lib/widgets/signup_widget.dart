import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:untherimeair_flutter/screens/home_screen.dart';
import 'package:untherimeair_flutter/services/utilisateur_service.dart';

import '../models/utilisateur_modele.dart';
import '../services/auth_service.dart';

class SignUpForm extends StatefulWidget {
  final AuthService authService;

  SignUpForm({required this.authService});

  @override
  _SignUpFormState createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _formKey = GlobalKey<FormState>();

  // Les contrôleurs pour les champs de texte
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _prenomController = TextEditingController();
  final TextEditingController _mailController = TextEditingController();
  final TextEditingController _motDePasseController = TextEditingController();
  final TextEditingController _telephoneController = TextEditingController();
  final TextEditingController _villeController = TextEditingController();
  final TextEditingController _nationaliteController = TextEditingController();
  final TextEditingController _commentaireController = TextEditingController();
  final TextEditingController _cvController = TextEditingController();

  // Variable pour stocker la date de naissance sélectionnée
  DateTime? _dateDeNaissance;

  // Service d'authentification utilisateur
  final UtilisateurService _utilisateurService = UtilisateurService();

  // Fonction pour afficher un DatePicker pour sélectionner la date de naissance
  Future<void> _choisirDateDeNaissance(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _dateDeNaissance) {
      setState(() {
        _dateDeNaissance = picked;
      });
    }
  }

  // Fonction pour valider et soumettre le formulaire d'inscription
  void _validerEtSoumettre() async {
    // Valider le formulaire d'inscription
    if (_formKey.currentState!.validate()) {
      // Récupérer les valeurs des champs du formulaire
      String mail = _mailController.text.trim();
      String motDePasse = _motDePasseController.text.trim();
      String nom = _nomController.text.trim();
      String prenom = _prenomController.text.trim();
      String telephone = _telephoneController.text.trim();
      String ville = _villeController.text.trim();
      String nationalite = _nationaliteController.text.trim();
      String commentaire = _commentaireController.text.trim();
      String cv = _cvController.text.trim();
      Timestamp dateDeNaissance = _dateDeNaissance != null
          ? Timestamp.fromDate(_dateDeNaissance!)
          : Timestamp
              .now(); // Utiliser la date actuelle si aucune date de naissance n'est sélectionnée

      // Inscrire l'utilisateur avec Firebase Auth
      User? user = await widget.authService.signUp(mail, motDePasse);

      if (user != null) {
        // Inscrire l'utilisateur dans la base de données Firestore
        Utilisateur? utilisateur =
            await _utilisateurService.inscrireUtilisateur(
          mail: mail,
          motDePasse: motDePasse,
          nom: nom,
          prenom: prenom,
          telephone: telephone,
          ville: ville,
          nationalite: nationalite,
          commentaire: commentaire,
          cv: cv,
          dateDeNaissance: dateDeNaissance,
        );

        if (utilisateur != null) {
          // Si l'inscription réussit dans Firebase Auth et Firestore, rediriger l'utilisateur vers la page d'accueil
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => HomeScreen(),
            ),
            (_) => false,
          );

          // Effacer les champs du formulaire après l'inscription réussie
          _nomController.clear();
          _prenomController.clear();
          _mailController.clear();
          _motDePasseController.clear();
          _telephoneController.clear();
          _villeController.clear();
          _nationaliteController.clear();
          _commentaireController.clear();
          _cvController.clear();
          _dateDeNaissance =
              null; // Réinitialiser la date de naissance sélectionnée
        } else {
          // Gérer le cas où l'inscription dans Firestore échoue
          // Afficher un message d'erreur ou effectuer une autre action appropriée
          print('Erreur : l\'inscription dans Firestore a échoué.');
        }
      } else {
        // Gérer le cas où l'inscription avec Firebase Auth échoue
        // Afficher un message d'erreur ou effectuer une autre action appropriée
        print('Erreur : l\'inscription avec Firebase Auth a échoué.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          // Champ de texte pour le nom
          TextFormField(
            controller: _nomController,
            decoration: InputDecoration(labelText: 'Nom'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer votre nom';
              }
              return null;
            },
          ),
          SizedBox(height: 16.0),

          // Champ de texte pour le prénom
          TextFormField(
            controller: _prenomController,
            decoration: InputDecoration(labelText: 'Prénom'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer votre prénom';
              }
              return null;
            },
          ),
          SizedBox(height: 16.0),

          // Champ de texte pour l'adresse e-mail
          TextFormField(
            controller: _mailController,
            decoration: InputDecoration(labelText: 'Adresse e-mail'),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer votre adresse e-mail';
              }
              // Vérifie si l'adresse e-mail est valide
              if (!RegExp(r'\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}\b',
                      caseSensitive: false)
                  .hasMatch(value)) {
                return 'Veuillez entrer une adresse e-mail valide';
              }
              return null;
            },
          ),
          SizedBox(height: 16.0),

          // Champ de texte pour le mot de passe
          TextFormField(
            controller: _motDePasseController,
            decoration: InputDecoration(labelText: 'Mot de passe'),
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer votre mot de passe';
              }
              // Vérifie si le mot de passe a au moins 6 caractères
              if (value.length < 6) {
                return 'Le mot de passe doit comporter au moins 6 caractères';
              }
              return null;
            },
          ),
          SizedBox(height: 16.0),

          // Champ de texte pour le téléphone
          TextFormField(
            controller: _telephoneController,
            decoration: InputDecoration(labelText: 'Téléphone'),
            keyboardType: TextInputType.phone,
          ),
          SizedBox(height: 16.0),

          // Champ de texte pour la ville
          TextFormField(
            controller: _villeController,
            decoration: InputDecoration(labelText: 'Ville'),
          ),
          SizedBox(height: 16.0),

          // Champ de texte pour la nationalité
          TextFormField(
            controller: _nationaliteController,
            decoration: InputDecoration(labelText: 'Nationalité'),
          ),
          SizedBox(height: 16.0),

          // Champ de texte pour le commentaire
          TextFormField(
            controller: _commentaireController,
            decoration: InputDecoration(labelText: 'Commentaire'),
          ),
          SizedBox(height: 16.0),

          // Champ de texte pour le CV
          TextFormField(
            controller: _cvController,
            decoration: InputDecoration(labelText: 'Chemin vers le CV'),
          ),
          SizedBox(height: 16.0),

          // Champ pour la date de naissance (sélectionnée à l'aide d'un DatePicker)
          InkWell(
            onTap: () => _choisirDateDeNaissance(context),
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: 'Date de naissance',
                hintText: 'Sélectionnez votre date de naissance',
              ),
              child: _dateDeNaissance == null
                  ? Text('')
                  : Text(
                      '${_dateDeNaissance!.day}/${_dateDeNaissance!.month}/${_dateDeNaissance!.year}'),
            ),
          ),
          SizedBox(height: 16.0),

          // Bouton de soumission du formulaire d'inscription
          ElevatedButton(
            onPressed: _validerEtSoumettre,
            child: Text('S\'inscrire'),
          ),
        ],
      ),
    );
  }
}
