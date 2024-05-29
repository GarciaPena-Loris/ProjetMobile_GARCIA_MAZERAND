import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class PdfViewPage extends StatefulWidget {
  final String url;

  PdfViewPage({required this.url});

  @override
  _PdfViewPageState createState() => _PdfViewPageState();
}

class _PdfViewPageState extends State<PdfViewPage> {
  String? localPath;

  @override
  void initState() {
    super.initState();
    _downloadAndSavePdf(widget.url).then((path) {
      setState(() {
        localPath = path;
      });
    });
  }

  Future<String> _downloadAndSavePdf(String url) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final String path = '${directory.path}/cv_temp.pdf';
    final File file = File(path);

    final http.Response response = await http.get(Uri.parse(url));
    await file.writeAsBytes(response.bodyBytes);
    return path;
  }

  @override
  void dispose() {
    if (localPath != null) {
      File(localPath!).delete();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Prévisualiser le CV'),
      ),
      body: localPath != null
          ? PDFView(
              filePath: localPath!,
            )
          : Center(child: CircularProgressIndicator()),
    );
  }
}
