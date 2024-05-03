import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:untherimeair_flutter/services/auth_service.dart';

class SignInForm extends StatefulWidget {
  final AuthService authService;

  SignInForm({required this.authService});

  @override
  _SignInFormState createState() => _SignInFormState();
}

class _SignInFormState extends State<SignInForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'E-mail'),
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
            TextFormField(
              controller: _passwordController,
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
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  // Récupère l'e-mail et le mot de passe depuis les contrôleurs de texte
                  String email = _emailController.text.trim();
                  String password = _passwordController.text.trim();

                  // Appel de la fonction signIn du service d'authentification
                  User? user = await widget.authService.signIn(email, password);

                  if (user != null) {
                    // Si l'utilisateur est connecté, navigue vers la page d'accueil
                    Navigator.pushNamed(context, '/home');
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erreur lors de la connexion')),
                    );
                  }
                }
              },
              child: Text('Se Connecter'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Dispose les contrôleurs de texte pour éviter les fuites de mémoire
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
