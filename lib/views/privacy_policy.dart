import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import '../services/api_service.dart';
import '../models/page_model.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  final ApiService api = ApiService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Privacy Policy"),
      ),
      body: FutureBuilder<PageModel?>(
        future: api.getPrivacyPolicy(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData && snapshot.data != null) {
            final page = snapshot.data!;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    page.title,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Html(data: page.description),
                ],
              ),
            );
          }
          return const Center(child: Text("No data found"));
        },
      ),
    );
  }
}
