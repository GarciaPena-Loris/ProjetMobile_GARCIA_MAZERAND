import 'package:flutter/material.dart';


class SearchDialog extends StatefulWidget {
  final Function(String, String, double) onSearch;

  const SearchDialog({Key? key, required this.onSearch}) : super(key: key);

  @override
  _SearchDialogState createState() => _SearchDialogState();
}

class _SearchDialogState extends State<SearchDialog> {
  double _distance = 0.0;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      title: const Text('Rechercher'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Sélectionnez vos critères de recherche :',
          style: TextStyle(fontSize: 12.0, color:Colors.grey),
          ),
          _buildSearchFormField(Icons.work, 'Métier cible'),
          _buildSearchFormField(Icons.location_city, 'Ville'),
          const  SizedBox(height: 14.0),
          Row(
            children: [
              const Icon(Icons.location_on),
              const SizedBox(width: 8.0),
              Expanded(
                child: Slider(
                  value: _distance,
                  min: 0.0,
                  max: 100.0,
                  divisions: 150,
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
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Fermer'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onSearch('métier', 'ville', _distance);
            Navigator.pop(context);
          },
          child: const Text('Rechercher'),
        ),
      ],
    );
  }

  Widget _buildSearchFormField(IconData icon, String labelText) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon),
          const SizedBox(width: 8.0),
          Expanded(
            child: TextFormField(
              decoration: InputDecoration(
                labelText: labelText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}