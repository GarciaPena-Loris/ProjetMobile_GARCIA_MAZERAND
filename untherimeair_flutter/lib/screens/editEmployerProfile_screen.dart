import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditEmployerProfilePage extends StatefulWidget {
  final Map<String, dynamic> employeurData;

  EditEmployerProfilePage({required this.employeurData});

  @override
  _EditEmployerProfilePageState createState() =>
      _EditEmployerProfilePageState();
}

class _EditEmployerProfilePageState extends State<EditEmployerProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final List<String> _liensPublics = [];

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _telephoneController;
  late TextEditingController _adresseController;
  late TextEditingController _entrepriseController;
  final TextEditingController _liensPublicsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.employeurData['nom']);
    _emailController =
        TextEditingController(text: widget.employeurData['mail']);
    _telephoneController = TextEditingController(
        text: widget.employeurData['telephoneEntreprise']);
    _adresseController =
        TextEditingController(text: widget.employeurData['adresseEntreprise']);
    _entrepriseController =
        TextEditingController(text: widget.employeurData['nomEntreprise']);

    if (widget.employeurData['liensPublics'] != null) {
      for (var lien in widget.employeurData['liensPublics']) {
        _liensPublics.add(lien);
      }
    }
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

  // Fonction pour supprimer un lien public de la liste
  void _supprimerLienPublic(int index) {
    setState(() {
      _liensPublics.removeAt(index);
    });
  }

  Future<void> _updateEmployerProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('employeurs')
          .doc(user.uid)
          .update({
        'nom': _nameController.text,
        'mail': _emailController.text,
        'telephoneEntreprise': _telephoneController.text,
        'adresseEntreprise': _adresseController.text,
        'nomEntreprise': _entrepriseController.text,
        'liensPublics': _liensPublics,
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Profil mis à jour avec succès'),
          backgroundColor: Colors.green));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Erreur de mise à jour du profil'),
          backgroundColor: Colors.red));
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
              const SizedBox(height: 20),
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
              const SizedBox(height: 10),
              if (_liensPublics.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Liens Publics:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 5),
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: _liensPublics.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(_liensPublics[index]),
                          trailing: IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              _supprimerLienPublic(index);
                            },
                          ),
                        );
                      },
                    ),
                  ],
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
