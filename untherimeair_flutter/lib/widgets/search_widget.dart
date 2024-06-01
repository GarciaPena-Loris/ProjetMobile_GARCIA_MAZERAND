import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Search extends StatefulWidget {
  final Function(String, String, double) onSearch;

  const Search({super.key, required this.onSearch});

  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  double _distance = 0.0;
  String _metier = '';
  String _ville = '';
  final _iconLocationCity = const Icon(Icons.location_city);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recherche de missions',
            style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 18.0),
          const Text(
            'Sélectionnez vos critères de recherche :',
            style: TextStyle(fontSize: 12.0, color: Colors.grey),
          ),
          _buildSearchFormField(const Icon(Icons.work), 'Métier cible', (value) {
            setState(() {
              _metier = value;
            });
          }),
          _buildSearchFormField(_iconLocationCity, 'Ville', (value) {
            setState(() {
              _ville = value;
            });
          }),
          const SizedBox(height: 16.0),
          Row(
            children: [
              const Icon(Icons.location_on),
              const SizedBox(width: 8.0),
              Expanded(
                child: Slider(
                  value: _distance,
                  min: 0.0,
                  max: 100.0,
                  divisions: 100,
                  label: 'Distance: ${_distance.round()} km',
                  onChanged: (value) {
                    setState(() {
                      _distance = value;
                    });
                  },
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Fermer'),
              ),
              ElevatedButton(
                onPressed: () {
                  widget.onSearch(_metier, _ville, _distance);
                  Navigator.pop(context);
                },
                child: const Text('Rechercher'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchFormField(Icon icon, String labelText, Function(String) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          icon,
          const SizedBox(width: 8.0),
          Expanded(
            child: TextFormField(
              decoration: InputDecoration(
                labelText: labelText,
              ),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
