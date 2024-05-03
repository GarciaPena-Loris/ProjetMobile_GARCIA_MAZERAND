import 'package:flutter/material.dart';
import 'package:untherimeair_flutter/models/annonce.dart';
import 'package:untherimeair_flutter/services/annonce_service.dart';
import 'package:untherimeair_flutter/widgets/annonce_widget.dart';

class AnnoncesScreen extends StatelessWidget {
  final AnnonceService _annonceService = AnnonceService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Liste des annonces'),
      ),
      body: StreamBuilder<List<Annonce>>(
        stream: _annonceService.getAnnonces(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur de chargement des annonces'));
          } else {
            List<Annonce> annonces = snapshot.data ?? [];
            return ListView.builder(
              itemCount: annonces.length,
              itemBuilder: (context, index) {
                return AnnonceWidget(annonce: annonces[index]);
              },
            );
          }
        },
      ),
    );
  }
}