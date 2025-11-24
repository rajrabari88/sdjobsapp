import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/application_model.dart';

class ApplicationService {
  final String baseUrl = "http://192.168.1.4/sdjobs/api";
  static const String staticToken = "9313069472"; // 🔑 Static token

  Future<List<ApplicationModel>> getApplications(int userId) async {
    final response = await http.get(
      Uri.parse("$baseUrl/get_applications.php?user_id=$userId"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $staticToken",
      },
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);

      if (jsonData['status'] == "success") {
        return (jsonData['data'] as List)
            .map((e) => ApplicationModel.fromJson(e))
            .toList();
      }
    }

    return [];
  }
}
