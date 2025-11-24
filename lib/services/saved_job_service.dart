import 'dart:convert';
import 'package:http/http.dart' as http;

const String baseUrl = "http://192.168.1.4/sdjobs/api";
const String staticToken = "9313069472"; // 🔑 Static token

class SavedJobService {
  static Map<String, String> get headers => {
    "Content-Type": "application/json",
    "Authorization": "Bearer $staticToken",
  };

  // 🟢 Get saved jobs for a user
  static Future<List<dynamic>> getSavedJobs(String userId) async {
    final url = Uri.parse("$baseUrl/get_saved_jobs.php?user_id=$userId");
    final response = await http.get(url, headers: headers);

    if (response.statusCode != 200) {
      throw Exception("Failed to fetch saved jobs");
    }

    final data = jsonDecode(response.body);
    return data["jobs"] ?? []; // Assuming API returns {"jobs": [...]}
  }

  // 🗑 Remove saved job
  static Future<bool> removeSaved(String userId, String jobId) async {
    final url = Uri.parse("$baseUrl/remove_saved_job.php");

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode({"user_id": userId, "job_id": jobId}),
    );

    if (response.statusCode != 200) return false;

    final data = jsonDecode(response.body);
    return data["status"] == "success";
  }

  // ➕ Add/save a job
  static Future<bool> addSaved(String userId, String jobId) async {
    final url = Uri.parse("$baseUrl/add_saved_job.php");

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode({"user_id": userId, "job_id": jobId}),
    );

    if (response.statusCode != 200) return false;

    final data = jsonDecode(response.body);
    return data["status"] == "saved" || data["status"] == "success";
  }

  // ✅ Apply to a job
  static Future<bool> applyJob(String userId, String jobId) async {
    final url = Uri.parse("$baseUrl/apply_job.php");

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode({"user_id": userId, "job_id": jobId}),
    );

    if (response.statusCode != 200) return false;

    final data = jsonDecode(response.body);
    return data["status"] == "success";
  }
}
