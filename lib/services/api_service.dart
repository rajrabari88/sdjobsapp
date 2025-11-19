import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl =
      "http://192.168.1.194/sdjobs/api"; // apne base URL se replace karna

  // 🟢 Fetch home data for a specific user
  static Future<Map<String, dynamic>> fetchHomeData(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/home_data.php?user_id=$userId'),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load home data');
    }
  }

  /// Search jobs by query string.
  /// NOTE: Assumes a backend endpoint `search_jobs.php?q=...` that returns a JSON array of jobs.
  /// If your API uses a different route/parameter, update this accordingly.
  static Future<List<dynamic>> searchJobs(String query) async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/search_jobs.php?q=${Uri.encodeQueryComponent(query)}',
      ),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data is List) return data;
      // if API returns an object with a list under a key, adapt here
      return [];
    } else {
      throw Exception('Failed to search jobs');
    }
  }
}
