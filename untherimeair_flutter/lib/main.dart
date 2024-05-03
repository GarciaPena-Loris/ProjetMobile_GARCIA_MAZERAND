import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:untherimeair_flutter/screens/annonces_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Un Thé Rime Air',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: AnnoncesScreen(), // Remplace MyHomePage par AnnoncesScreen
    );
  }
}
