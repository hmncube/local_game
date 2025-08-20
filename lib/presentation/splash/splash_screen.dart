import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_doc_scanner/flutter_doc_scanner.dart';
import 'package:local_game/app/themes/app_text_styles.dart';

import 'package:local_game/app/themes/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  dynamic _scannedDocuments;
 Future<void> scanDocument() async {
    dynamic scannedDocuments;
    try {
      scannedDocuments = await FlutterDocScanner().getScanDocuments(page: 4) ??
          'Unknown platform documents';
    } on PlatformException {
      scannedDocuments = 'Failed to get scanned documents.';
    }
    print(scannedDocuments.toString());
    if (!mounted) return;
    setState(() {
      _scannedDocuments = scannedDocuments;
    });
  }

  Future<void> scanDocumentUri() async {
    //This Feature only supported for Android.
    dynamic scannedDocuments;
    try {
      scannedDocuments =
          await FlutterDocScanner().getScanDocumentsUri(page: 4) ??
              'Unknown platform documents';
    } on PlatformException {
      scannedDocuments = 'Failed to get scanned documents.';
    }
    print(scannedDocuments.toString());
    if (!mounted) return;
    setState(() {
      _scannedDocuments = scannedDocuments;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Document Scanner Example',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Document Scanner example app'),
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _scannedDocuments != null
                    ? Text(_scannedDocuments.toString())
                    : const Text("No Documents Scanned"),
              ],
            ),
          ),
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: ElevatedButton(
                  onPressed: () {
                    scanDocument();
                  },
                  child: const Text("Scan Documents"),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: ElevatedButton(
                  onPressed: () {
                    scanDocument();
                  },
                  child: const Text("Scan Documents As Images"),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: ElevatedButton(
                  onPressed: () {
                    scanDocument();
                  },
                  child: const Text("Scan Documents As PDF"),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: ElevatedButton(
                  onPressed: () {
                    scanDocumentUri();
                  },
                  child: const Text("Get Scan Documents URI"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
