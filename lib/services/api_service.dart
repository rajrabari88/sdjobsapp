import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://192.168.1.4/sdjobs/api";
  static const String staticToken = "9313069472"; // 🔑 Static token

  // ---------------- HOME DATA ----------------
  static Future<Map<String, dynamic>> fetchHomeData(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/home_data.php?user_id=$userId'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $staticToken",
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load home data');
    }
  }

  // ---------------- SEARCH JOBS ----------------
  static Future<List<dynamic>> searchJobs(String query) async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/search_jobs.php?q=${Uri.encodeQueryComponent(query)}',
      ),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $staticToken",
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data is List) return data;
      return [];
    } else {
      throw Exception('Failed to search jobs');
    }
  }

  // ---------------- CHAT APIs ----------------
  static Future<List<dynamic>> getMessages(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/get_messages.php?user_id=$userId'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $staticToken",
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch messages');
    }
  }

  static Future<bool> sendMessage(String userId, String message) async {
    final response = await http.post(
      Uri.parse('$baseUrl/send_message.php'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $staticToken",
      },
      body: jsonEncode({"user_id": userId, "message": message}),
    );

    return response.statusCode == 200;
  }

  static Future<bool> checkUnread(String userId) async {
    final response = await http.get(
      Uri.parse("$baseUrl/check_unread.php?user_id=$userId"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $staticToken",
      },
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json['unread'] == true;
    }

    return false;
  }
}
