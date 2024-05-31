import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:untherimeair_flutter/screens/home_screen.dart';
import 'package:untherimeair_flutter/services/utilisateur_service.dart';
import 'package:untherimeair_flutter/services/employeur_service.dart';

import '../models/utilisateur_modele.dart';
import '../models/employeur_modele.dart';

import 'package:file_picker/file_picker.dart';
import '../services/auth_service.dart';

class SignUpForm extends StatefulWidget {
  final AuthService authService;

  const SignUpForm({super.key, required this.authService});

  @override
  _SignUpFormState createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  bool isEmployer = false;
  final _formKey = GlobalKey<FormState>();
  File? _cvFile;

  // Liste pour stocker les liens publics
  final List<String> _liensPublics = [];

  // Variables de contrôleurs pour les champs de texte
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _prenomController = TextEditingController();
  final TextEditingController _mailController = TextEditingController();
  final TextEditingController _motDePasseController = TextEditingController();
  final TextEditingController _telephoneController = TextEditingController();
  final TextEditingController _villeController = TextEditingController();
  final TextEditingController _nationaliteController = TextEditingController();
  final TextEditingController _commentaireController = TextEditingController();
  final TextEditingController _cvController = TextEditingController();
  final TextEditingController _nomEntrepriseController =
      TextEditingController();
  final TextEditingController _adresseEntrepriseController =
      TextEditingController();
  final TextEditingController _telephoneEntrepriseController =
      TextEditingController();

  final TextEditingController _liensPublicsController = TextEditingController();

  // Service d'utilisateur et d'employeur
  final UtilisateurService _utilisateurService = UtilisateurService();
  final EmployeurService _employeurService = EmployeurService();

  // Variables pour vérifier si tous les champs obligatoires sont remplis
  bool _isFormFilled = false;
  DateTime? _dateDeNaissance;
  String? _errorMessage;

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
          _mailController.text.isNotEmpty &&
          _motDePasseController.text.isNotEmpty;
    });
  }

  @override
  void initState() {
    super.initState();
    _nomController.addListener(_checkFormFilled);
    _mailController.addListener(_checkFormFilled);
    _motDePasseController.addListener(_checkFormFilled);
  }

  @override
  void dispose() {
    _nomController.removeListener(_checkFormFilled);
    _mailController.removeListener(_checkFormFilled);
    _motDePasseController.removeListener(_checkFormFilled);
    super.dispose();
  }

  // Fonction pour ajouter un lien public à la liste
  void _ajouterLienPublic() {
    if (_liensPublicsController.text.isNotEmpty) {
      setState(() {
        _liensPublics.add(_liensPublicsController.text.trim());
        _liensPublicsController.clear();
      });
    }
  }

  // Fonction pour valider et soumettre le formulaire d'inscription
  void _validerEtSoumettre() async {
    if (_formKey.currentState!.validate()) {
      if (isEmployer) {
        // Inscription pour un employeur
        String mail = _mailController.text.trim();
        String motDePasse = _motDePasseController.text.trim();
        String nom = _nomController.text.trim();
        String adresseEntreprise = _adresseEntrepriseController.text.trim();
        String nomEntreprise = _nomEntrepriseController.text.trim();
        String telephoneEntreprise = _telephoneEntrepriseController.text.trim();

        Employeur? employeur = await _employeurService.inscrireEmployeur(
          mail: mail,
          motDePasse: motDePasse,
          nom: nom,
          adresseEntreprise: adresseEntreprise,
          nomEntreprise: nomEntreprise,
          telephoneEntreprise: telephoneEntreprise,
          liensPublics: _liensPublics,
        );

        if (employeur != null && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Inscription employeur réussie!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => HomeScreen(),
            ),
            (_) => false,
          );

          _nomController.clear();
          _adresseEntrepriseController.clear();
          _nomEntrepriseController.clear();
          _mailController.clear();
          _motDePasseController.clear();
          _dateDeNaissance = null;
          _telephoneController.clear();
          _telephoneEntrepriseController.clear();
          _liensPublicsController.clear();
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content:
                    Text('Erreur : l\'inscription de l\'employeur a échoué.'),
                backgroundColor: Colors.red,
              ),
            );
          }
          print(
              'Erreur : l\'inscription de l\'employeur dans Firestore a échoué.');
        }
      } else {
        if (_dateDeNaissance == null ||
            _dateDeNaissance!.isAfter(
                DateTime.now().subtract(const Duration(days: 18 * 365)))) {
          setState(() {
            _errorMessage =
                'Vous devez avoir au moins 18 ans pour vous inscrire.';
          });
          return;
        }

        // Inscription pour un utilisateur régulier
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
          cv: _cvFile,
          dateDeNaissance: dateDeNaissance,
        );

        if (utilisateur != null && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Inscription utilisateur réussie!'),
              backgroundColor: Colors.green,
            ),
          );

          // Si l'inscription réussit dans Firebase Auth et Firestore, rediriger l'utilisateur vers la page d'accueil
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => const HomeScreen(),
            ),
            (_) => false,
          );

          _nomController.clear();
          _prenomController.clear();
          _mailController.clear();
          _motDePasseController.clear();
          _telephoneController.clear();
          _villeController.clear();
          _nationaliteController.clear();
          _commentaireController.clear();
          _cvController.clear();
          _dateDeNaissance = null;
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content:
                    Text('Erreur : l\'inscription de l\'utilisateur a échoué.'),
                backgroundColor: Colors.red,
              ),
            );
          }
          print(
              'Erreur : l\'inscription de l\'utilisateur dans Firestore a échoué.');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (isEmployer) ...[
              const Text(
                'Inscrivez-vous pour poster des missions',
                style: TextStyle(fontSize: 12.0, color: Colors.grey),
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _nomController,
                decoration: const InputDecoration(
                  labelText: 'Nom *',
                  prefixIcon: Icon(Icons.perm_identity),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre nom';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _mailController,
                decoration: const InputDecoration(
                    labelText: 'Adresse e-mail *',
                    prefixIcon: Icon(Icons.email)),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre adresse e-mail';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _motDePasseController,
                decoration: const InputDecoration(
                    labelText: 'Mot de passe *', prefixIcon: Icon(Icons.lock)),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre mot de passe';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _nomEntrepriseController,
                decoration: const InputDecoration(
                    labelText: 'Nom de l\'entreprise',
                    prefixIcon: Icon(Icons.business_center)),
              ),
              TextFormField(
                controller: _adresseEntrepriseController,
                decoration: const InputDecoration(
                  labelText: 'Adresse de l\'entreprise',
                  prefixIcon: Icon(Icons.business),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer l\'adresse de l\'entreprise';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _telephoneEntrepriseController,
                decoration: const InputDecoration(
                    labelText: 'Téléphone de l\'entreprise',
                    prefixIcon: Icon(Icons.phone_enabled)),
              ),
              // Champ pour ajouter des liens publics
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _liensPublicsController,
                      decoration: const InputDecoration(
                          labelText: 'Lien public',
                          prefixIcon: Icon(Icons.link)),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add),
                    onPressed: _ajouterLienPublic,
                  ),
                ],
              ),
              // Afficher les liens publics ajoutés
              if (_liensPublics.isNotEmpty)
                Column(
                  children: _liensPublics
                      .map((lien) => ListTile(
                            title: Text(lien),
                            trailing: IconButton(
                              icon: Icon(Icons.remove),
                              onPressed: () {
                                setState(() {
                                  _liensPublics.remove(lien);
                                });
                              },
                            ),
                          ))
                      .toList(),
                ),
              // Version utilisateur
            ] else ...[
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
                  prefixIcon: Icon(Icons.perm_identity),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre nom';
                  }
                  return null;
                },
              ),
              // Champ de texte pour le prénom
              TextFormField(
                controller: _prenomController,
                decoration: const InputDecoration(
                    labelText: 'Prénom *', prefixIcon: Icon(Icons.person)),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre prénom';
                  }
                  return null;
                },
              ),
              // Champ pour la date de naissance (sélectionnée à l'aide d'un DatePicker)
              InkWell(
                onTap: () => _choisirDateDeNaissance(context),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date de naissance *',
                    hintText: 'Age minimum: 18 ans',
                    prefixIcon:
                        Icon(Icons.calendar_today), // Icône de calendrier
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
              // Champ de texte pour l'adresse e-mail
              TextFormField(
                controller: _mailController,
                decoration: const InputDecoration(
                    labelText: 'Adresse e-mail *',
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
              // Champ de texte pour la ville
              TextFormField(
                controller: _villeController,
                decoration: const InputDecoration(
                    labelText: 'Ville',
                    hintText: 'Ville de résidence',
                    prefixIcon: Icon(Icons.location_city)),
              ),
              // Champ de texte pour la nationalité
              TextFormField(
                controller: _nationaliteController,
                decoration: const InputDecoration(
                    labelText: 'Nationalité',
                    hintText: 'Nationalité',
                    prefixIcon: Icon(Icons.flag)),
              ),
              // Champ de texte pour les informations complémentaires
              TextFormField(
                controller: _commentaireController,
                decoration: const InputDecoration(
                  labelText: 'Informations complémentaires',
                  hintText: '',
                  prefixIcon: Icon(Icons.comment),
                ),
                maxLines:
                    3, // Permet au champ de texte de s'étendre sur 5 lignes
              ),

              const SizedBox(height: 16.0),
              // Champ pour le CV
              Card(
                color: _cvFile != null ? Colors.lightBlueAccent : null,
                // Change la couleur en vert si un fichier est sélectionné
                child: ListTile(
                  leading: const Icon(Icons.description),
                  // Icône 'description'
                  title: Text(_cvController.text.isEmpty
                      ? 'Sélectionnez votre CV (pdf)'
                      : _cvController.text),
                  // Texte
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
                    if (mounted) {
                      FilePickerResult? result =
                          await FilePicker.platform.pickFiles(
                        type: FileType.custom,
                        allowedExtensions: [
                          'pdf'
                        ], // Autoriser uniquement les fichiers PDF
                      );

                      if (result != null) {
                        if (result.files.single.extension == 'pdf') {
                          _cvFile = File(result.files.single.path!);
                          // Utilisez la propriété 'name' pour obtenir le nom du fichier
                          setState(() {
                            _cvController.text = result.files.single.name;
                          });
                        } else {
                          // Affichez un message d'erreur si un fichier autre que PDF est sélectionné
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  Text('Veuillez sélectionner un fichier PDF.'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    }
                  },
                ),
              ),
            ],
            ...[
              const SizedBox(height: 16.0),
              if (!isEmployer)
                const Divider(
                  color: Colors.grey,
                  height: 20,
                ),
            ],
            SwitchListTile(
              title: const Text('Je suis un employeur'),
              value: isEmployer,
              onChanged: (bool value) {
                setState(() {
                  isEmployer = value;
                });
              },
            ),
            const SizedBox(height: 16.0),

            // Bouton de soumission du formulaire d'inscription
            SizedBox(
              width: double.infinity, // Largeur maximale
              child: ElevatedButton(
                onPressed: _isFormFilled ? _validerEtSoumettre : null,
                child: const Text('S\'inscrire'),
              ),
            ),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
