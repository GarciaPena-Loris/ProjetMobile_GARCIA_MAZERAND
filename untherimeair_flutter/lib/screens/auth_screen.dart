import 'package:flutter/material.dart';
import 'package:untherimeair_flutter/services/auth_service.dart';
import '../widgets/signin_widget.dart';
import '../widgets/signup_widget.dart';

class AuthScreen extends StatelessWidget {
  final AuthService authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // The number of tabs
      child: Scaffold(
        appBar: AppBar(
          title: Text('Connexion/Inscription'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Connexion'),
              Tab(text: 'Inscription'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Vue de la Connexion
            SignInForm(authService: authService),
            // Vue de l'Inscription
            SignUpForm(authService: authService),
          ],
        ),
      ),
    );
  }
}