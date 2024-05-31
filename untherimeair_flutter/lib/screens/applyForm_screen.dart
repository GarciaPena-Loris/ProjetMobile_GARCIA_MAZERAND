import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';

import '../widgets/pdfView_widget.dart';

class ApplyFormPage extends StatefulWidget {
  @override
  _ApplyFormPageState createState() => _ApplyFormPageState();
}

class UserData {
  final String firstName;
  final String lastName;
  final DateTime dateOfBirth;
  final String nationality;
  final String cv;
  final String coverLetter;

  UserData({
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
    required this.nationality,
    required this.cv,
    this.coverLetter = '',
  });
}

class _ApplyFormPageState extends State<ApplyFormPage> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _cvDeposed = false;
  final _storage = FirebaseStorage.instance;
  File? _lmFile;
  UserData? _userData;

  final TextEditingController _lmController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance.collection('utilisateurs').doc(user.uid).get();
      if (userDoc.exists) {
        setState(() {
          _userData = UserData(
            firstName: userDoc.get('prenom'),
            lastName: userDoc.get('nom'),
            dateOfBirth: (userDoc.get('dateDeNaissance') as Timestamp).toDate(),
            nationality: userDoc.get('nationalite'),
            cv: userDoc.get('cv')
          );
        });
      } else {
        // Gérer l'absence de document utilisateur
        setState(() {
          _userData = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Aucune donnée utilisateur trouvée.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Postuler à l\'annonce'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _userData == null
            ? const Center(child: CircularProgressIndicator())
            : FormBuilder(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              FormBuilderTextField(
                name: 'firstName',
                decoration: const InputDecoration(labelText: 'Prénom'),
                initialValue: _userData!.firstName,
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                  FormBuilderValidators.maxLength(70),
                ]),
              ),
              FormBuilderTextField(
                name: 'lastName',
                decoration: const InputDecoration(labelText: 'Nom'),
                initialValue: _userData!.lastName,
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                  FormBuilderValidators.maxLength(70),
                ]),
              ),
              FormBuilderDateTimePicker(
                name: 'dateOfBirth',
                inputType: InputType.date,
                format: DateFormat('d MMMM yyyy', 'fr_FR'),
                decoration: const InputDecoration(labelText: 'Date de naissance'),
                initialValue: _userData!.dateOfBirth,
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                ]),
              ),
              FormBuilderTextField(
                name: 'nationality',
                decoration: const InputDecoration(labelText: 'Nationalité'),
                initialValue: _userData!.nationality,
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                  FormBuilderValidators.maxLength(70),
                ]),
              ),
              const SizedBox(height: 16.0),
              Card(
                color: _cvDeposed ? Colors.lightBlueAccent : null,
                child: ListTile(
                  leading: const Icon(Icons.description),
                  title: Text(_cvDeposed
                      ? 'CV déjà déposé'
                      : 'Déposé votre CV (pdf)'),
                  trailing: _cvDeposed
                      ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.visibility),
                        onPressed: () async {
                          try {
                            final ref = FirebaseStorage.instance
                                .ref(
                                'cvs/${FirebaseAuth.instance.currentUser!.uid}.pdf');
                            final url =
                            await ref.getDownloadURL();

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    PdfViewPage(url: url),
                              ),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(
                              SnackBar(
                                  content: Text(
                                      'Erreur de chargement du CV: $e')),
                            );
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _cvDeposed = false;
                          });
                          // Supprimer le CV de Firebase Storage
                          _storage
                              .ref(
                              'cvs/${FirebaseAuth.instance.currentUser!.uid}.pdf')
                              .delete();
                          // Supprimer le lien du CV de la base de données
                          FirebaseFirestore.instance
                              .collection('utilisateurs')
                              .doc(FirebaseAuth
                              .instance.currentUser!.uid)
                              .update({'cv': ''});

                          const SnackBar(
                            content: Text('Cv supprimé'),
                            backgroundColor: Colors.red,
                          );
                        },
                      ),
                    ],
                  )
                      : null,
                  onTap: () async {
                    if (!_cvDeposed) {
                      FilePickerResult? result =
                      await FilePicker.platform.pickFiles(
                        type: FileType.custom,
                        allowedExtensions: ['pdf'],
                      );

                      if (result != null) {
                        if (result.files.single.extension == 'pdf') {
                          // Upload to Firebase Storage
                          try {
                            TaskSnapshot snapshot = await _storage
                                .ref(
                                'cvs/${FirebaseAuth.instance.currentUser!.uid}.pdf')
                                .putFile(
                                File(result.files.single.path!));

                            // Get the download URL
                            String downloadURL =
                            await snapshot.ref.getDownloadURL();

                            // Update the CV link in the database
                            await FirebaseFirestore.instance
                                .collection('utilisateurs')
                                .doc(FirebaseAuth
                                .instance.currentUser!.uid)
                                .update({'cv': downloadURL});

                            setState(() {
                              _cvDeposed = true;
                            });

                            if (mounted) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(
                                const SnackBar(
                                  content: Text('CV déposé.'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Failed to upload CV. Error: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Veuillez sélectionner un fichier PDF.'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    }
                  },
                ),
              ),
              const SizedBox(height: 16.0),
              // Champ pour la lettre de motiviation
              Card(
                color: _lmFile != null ? Colors.deepPurpleAccent : null,
                // Change la couleur en vert si un fichier est sélectionné
                child: ListTile(
                  leading: const Icon(Icons.description),
                  // Icône 'description'
                  title: Text(_lmController.text.isEmpty
                      ? 'Sélectionnez votre Lettre de Motivation (pdf)'
                      : _lmController.text),
                  // Texte
                  trailing: _lmFile !=
                      null // Si un fichier est sélectionné, affiche une icône de croix pour supprimer le fichier
                      ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      setState(() {
                        _lmFile = null;
                        _lmController.clear();
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
                          _lmFile = File(result.files.single.path!);
                          // Utilisez la propriété 'name' pour obtenir le nom du fichier
                          setState(() {
                            _lmController.text = result.files.single.name;
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
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.saveAndValidate()) {
                    print(_formKey.currentState!.value);
                    // Ici, vous pouvez gérer l'envoi des données du formulaire
                  }
                },
                child: const Text('Soumettre'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
