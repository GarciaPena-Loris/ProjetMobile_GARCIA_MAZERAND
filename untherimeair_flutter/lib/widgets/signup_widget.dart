import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:untherimeair_flutter/screens/home_screen.dart';
import 'package:untherimeair_flutter/services/utilisateur_service.dart';

import '../models/utilisateur_modele.dart';
import 'package:file_picker/file_picker.dart';
import '../services/auth_service.dart';

class SignUpForm extends StatefulWidget {
  final AuthService authService;

  const SignUpForm({super.key, required this.authService});

  @override
  _SignUpFormState createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _formKey = GlobalKey<FormState>();
  File? _cvFile;

  // Variable pour vérifier si tous les champs obligatoires sont remplis
  bool _isFormFilled = false;

  // Variable pour stocker la date de naissance sélectionnée
  DateTime? _dateDeNaissance;

  // Variable pour stocker le message d'erreur
  String? _errorMessage;

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

  // Fonction pour vérifier si tous les champs obligatoires sont remplis
  void _checkFormFilled() {
    setState(() {
      _isFormFilled = _nomController.text.isNotEmpty &&
          _prenomController.text.isNotEmpty &&
          _mailController.text.isNotEmpty &&
          _motDePasseController.text.isNotEmpty &&
          _dateDeNaissance != null;
    });
  }

  @override
  void initState() {
    super.initState();
    // Écouteurs aux contrôleurs de texte pour les champs obligatoires
    _nomController.addListener(_checkFormFilled);
    _prenomController.addListener(_checkFormFilled);
    _mailController.addListener(_checkFormFilled);
    _motDePasseController.addListener(_checkFormFilled);
  }

  // Fonction pour valider et soumettre le formulaire d'inscription
  void _validerEtSoumettre() async {
    // Valider le formulaire d'inscription
    if (_formKey.currentState!.validate()) {
      // Vérifie si l'utilisateur a au moins 18 ans
      if (_dateDeNaissance!
          .isAfter(DateTime.now().subtract(const Duration(days: 18 * 365)))) {
        setState(() {
          _errorMessage =
              'Vous devez avoir au moins 18 ans pour vous inscrire.';
        });
        return;
      }
      // Récupérer les valeurs des champs du formulaire
      String mail = _mailController.text.trim();
      String motDePasse = _motDePasseController.text.trim();
      String nom = _nomController.text.trim();
      String prenom = _prenomController.text.trim();
      String telephone = _telephoneController.text.trim();
      String ville = _villeController.text.trim();
      String nationalite = _nationaliteController.text.trim();
      String commentaire = _commentaireController.text.trim();
      Timestamp dateDeNaissance = _dateDeNaissance != null
          ? Timestamp.fromDate(_dateDeNaissance!)
          : Timestamp
              .now(); // Utiliser la date actuelle si aucune date de naissance n'est sélectionnée

      // Inscrire l'utilisateur dans la base de données Firestore
      Utilisateur? utilisateur = await _utilisateurService.inscrireUtilisateur(
        mail: mail,
        motDePasse: motDePasse,
        nom: nom,
        prenom: prenom,
        telephone: telephone,
        ville: ville,
        nationalite: nationalite,
        commentaire: commentaire,
        cv: _cvFile,
        dateDeNaissance: dateDeNaissance,
      );

      if (utilisateur != null && mounted) {
        // Afficher une Snackbar pour signaler que l'inscription a réussi
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Inscription réussie!'),
            backgroundColor: Colors.green,
          ),
        );

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
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erreur : l\'inscription a échoué.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        print('Erreur : l\'inscription dans Firestore a échoué.');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur : Formulaire invalide.'),
          backgroundColor: Colors.red,
        ),
      );
      print('Erreur : Formulaire invalide.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text(
            'Inscrivez-vous pour pouvoir postuler à des missions',
            style: TextStyle(fontSize: 12.0, color: Colors.grey),
          ),
          const SizedBox(height: 16.0),

          // Champ de texte pour le nom
          TextFormField(
            controller: _nomController,
            decoration: const InputDecoration(
              labelText: 'Nom *',
              hintText: 'Votre nom de famille...',
              prefixIcon: Icon(Icons.badge),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer votre nom';
              }
              return null;
            },
          ),
          const SizedBox(height: 16.0),

          // Champ de texte pour le prénom
          TextFormField(
            controller: _prenomController,
            decoration: const InputDecoration(
                labelText: 'Prénom *',
                hintText: 'Votre prénom...',
                prefixIcon: Icon(Icons.badge)),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer votre prénom';
              }
              return null;
            },
          ),
          const SizedBox(height: 16.0),

          // Champ pour la date de naissance (sélectionnée à l'aide d'un DatePicker)
          InkWell(
            onTap: () => _choisirDateDeNaissance(context),
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Date de naissance *',
                hintText: 'Age minimum: 18 ans',
                prefixIcon: Icon(Icons.calendar_today), // Icône de calendrier
              ),
              child: _dateDeNaissance == null
                  ? const Text('')
                  : Text(DateFormat('d MMMM yyyy', 'fr_FR').format(
                      _dateDeNaissance!)), // Formattez la date de naissance en français
            ),
          ),

          // Affiche le message d'erreur sous le champ de la date de naissance
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),

          const SizedBox(height: 16.0),

          // Champ de texte pour l'adresse e-mail
          TextFormField(
            controller: _mailController,
            decoration: const InputDecoration(
                labelText: 'Adresse e-mail *',
                hintText: 'user@mail.fr',
                prefixIcon: Icon(Icons.email)),
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
          const SizedBox(height: 16.0),

          // Champ de texte pour le mot de passe
          TextFormField(
            controller: _motDePasseController,
            decoration: const InputDecoration(
                labelText: 'Mot de passe *',
                hintText: '6 caractères minimum',
                prefixIcon: Icon(Icons.lock)),
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
          const SizedBox(height: 16.0),

          // Champ de texte pour le téléphone
          TextFormField(
            controller: _telephoneController,
            decoration: const InputDecoration(
                labelText: 'Téléphone',
                hintText: '0123456789',
                prefixIcon: Icon(Icons.phone)),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16.0),

          // Champ de texte pour la ville
          TextFormField(
            controller: _villeController,
            decoration: const InputDecoration(
                labelText: 'Ville',
                hintText: 'Ville de résidence',
                prefixIcon: Icon(Icons.location_city)),
          ),
          const SizedBox(height: 16.0),

          // Champ de texte pour la nationalité
          TextFormField(
            controller: _nationaliteController,
            decoration: const InputDecoration(
                labelText: 'Nationalité',
                hintText: 'Nationalité',
                prefixIcon: Icon(Icons.flag)),
          ),
          const SizedBox(height: 16.0),

          // Champ de texte pour les informations complémentaires
          TextFormField(
            controller: _commentaireController,
            decoration: const InputDecoration(
              labelText: 'Informations complémentaires',
              hintText: '',
              prefixIcon: Icon(Icons.comment),
            ),
            maxLines: 5, // Permet au champ de texte de s'étendre sur 5 lignes
          ),

          const SizedBox(height: 16.0),

          // Champ pour le CV
          Card(
            color: _cvFile != null ? Colors.lightGreenAccent : null,
            // Change la couleur en vert si un fichier est sélectionné
            child: ListTile(
              leading: const Icon(Icons.description), // Icône 'description'
              title: Text(_cvController.text.isEmpty
                  ? 'Sélectionnez votre CV'
                  : _cvController.text), // Texte
              trailing: _cvFile !=
                      null // Si un fichier est sélectionné, affiche une icône de croix pour supprimer le fichier
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _cvFile = null;
                          _cvController.clear();
                        });
                      },
                    )
                  : null,
              onTap: () async {
                FilePickerResult? result =
                    await FilePicker.platform.pickFiles();

                if (result != null) {
                  _cvFile = File(result.files.single.path!);
                  // Utilisez la propriété 'name' pour obtenir le nom du fichier
                  setState(() {
                    _cvController.text = result.files.single.name;
                  });
                } else {
                  // User canceled the picker
                }
              },
            ),
          ),
          const SizedBox(height: 16.0),

          // Bouton de soumission du formulaire d'inscription
          ElevatedButton(
            onPressed: _isFormFilled ? _validerEtSoumettre : null,
            child: const Text('S\'inscrire'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // Supprimez les écouteurs lorsque le widget est supprimé
    _nomController.removeListener(_checkFormFilled);
    _prenomController.removeListener(_checkFormFilled);
    _mailController.removeListener(_checkFormFilled);
    _motDePasseController.removeListener(_checkFormFilled);
    super.dispose();
  }
}
