class EditProfilePage extends StatefulWidget {
  final Utilisateur utilisateur;

  EditProfilePage({required this.utilisateur});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  // Ajoutez d'autres contrôleurs pour les autres champs

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.utilisateur.nom);
    _emailController = TextEditingController(text: widget.utilisateur.mail);
    // Initialisez les autres contrôleurs avec les valeurs de l'utilisateur
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
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nom',
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                ),
              ),
              // Ajoutez d'autres champs de formulaire pour les autres informations de l'utilisateur
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Mettez à jour les informations de l'utilisateur dans la base de données
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