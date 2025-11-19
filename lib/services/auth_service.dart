import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static const String baseUrl = "http://192.168.1.194/sdjobs/api";

  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    final url = Uri.parse("$baseUrl/login.php");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email.trim(), "password": password.trim()}),
      );

      print("[AuthService.login] Response Status: ${response.statusCode}");
      print("[AuthService.login] Response Body: ${response.body}");

      return jsonDecode(response.body);
    } catch (e) {
      print("[AuthService.login] Exception: $e");
      return {"status": "error", "message": e.toString()};
    }
  }
}
