import 'package:flutter/material.dart';
import 'package:untherimeair_flutter/widgets/search_dialog_widget.dart';

class SearchWidget extends StatefulWidget {
  final Function(String, String, double) onSearch;

  const SearchWidget({Key? key, required this.onSearch}) : super(key: key);

  @override
  _SearchWidgetState createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  double _distance = 0.0;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        _showSearchDialog(context);
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          color: Colors.grey[200],
        ),
        child: const Row(
          children: [
            Icon(Icons.search),
            SizedBox(width: 8.0),
            Text('Rechercher...'),
          ],
        ),
      ),
    );
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => SearchDialog(onSearch: widget.onSearch),
    );
  }

  Widget _buildSearchFormField(IconData icon, String labelText) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon),
          SizedBox(width: 8.0),
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
