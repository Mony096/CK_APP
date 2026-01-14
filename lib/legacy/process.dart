import 'dart:convert';
import 'package:bizd_tech_service/core/network/dio_client.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';

class DocumentProcessScreen extends StatefulWidget {
  @override
  _DocumentProcessScreenState createState() => _DocumentProcessScreenState();
}

class _DocumentProcessScreenState extends State<DocumentProcessScreen> {
  List<dynamic> docEntries = ['APP1', 'APP2'];
  List<dynamic> documents = [];
  int currentIndex = 0;
  bool isLoading = true;
  bool hasAccept = false;

  @override
  void initState() {
    super.initState();
    fetchDocuments();
  }

  final DioClient dio = DioClient(); // Your custom Dio client

  Future<void> fetchDocuments() async {
    final filter = docEntries.map((e) => "Code eq '$e'").join(" or ");

    try {
      final response = await dio.get("/TL_VEHICLE?\$filter=($filter)");
      if (response.statusCode == 200) {
        print(response.data["value"]);
        final List<dynamic> data = response.data["value"];
        setState(() {
          documents = data;
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load documents");
      }
    } catch (e) {
      print(e);
      setState(() => isLoading = false);
    }
  }

  Future<void> updateDocumentStatus(dynamic docEntry, String status) async {
    try {
      final response = await dio.patch(
        "/TL_VEHICLE('$docEntry')",
        false,
        false,
        data: {"U_Status": status},
      );

      if (response.statusCode == null ||
          response.statusCode! < 200 ||
          response.statusCode! >= 300) {
        throw Exception(
            "Failed to update document. Status code: ${response.statusCode}");
      }

      print("Document $docEntry updated successfully to $status");
    } catch (e) {
      print("Error updating document: $e");
      rethrow; // to let caller handle
    }
  }

  void handleAction(String status) async {
    final currentDoc = documents[currentIndex];
    final docEntry = currentDoc["Code"];

    await updateDocumentStatus(docEntry, status);

    if (status == "Y") {
      hasAccept = true;
    }

    setState(() {
      currentIndex++;
    });

    if (currentIndex >= documents.length) {
      if (hasAccept) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => AnotherScreen()));
      } else {
        SystemNavigator.pop(); // exit app
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (currentIndex >= documents.length) {
      return Scaffold(
        body: Center(child: Text("Processing completed...")),
      );
    }

    final currentDoc = documents[currentIndex];

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Document: ${currentDoc["docEntry"]}",
                style: TextStyle(fontSize: 24)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => handleAction("Y"),
              child: Text("Accept"),
            ),
            ElevatedButton(
              onPressed: () => handleAction("N"),
              child: Text("Reject"),
            ),
          ],
        ),
      ),
    );
  }
}

class AnotherScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("Welcome to next screen!", style: TextStyle(fontSize: 24)),
      ),
    );
  }
}

