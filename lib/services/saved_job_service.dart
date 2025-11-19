import 'dart:convert';
import 'package:http/http.dart' as http;

const String baseUrl = "http://192.168.1.194/sdjobs/api";

class SavedJobService {
  static Future<List<dynamic>> getSavedJobs(String userId) async {
    final url = Uri.parse("$baseUrl/get_saved_jobs.php?user_id=$userId");
    final response = await http.get(url);
    return jsonDecode(response.body);
  }

  static Future<bool> removeSaved(String userId, String jobId) async {
    final url = Uri.parse("$baseUrl/remove_saved_job.php");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"user_id": userId, "job_id": jobId}),
    );

    print("REMOVE RESPONSE: ${response.body}");

    return jsonDecode(response.body)["status"] == "success";
  }

  // Add/save a job for a user
  static Future<bool> addSaved(String userId, String jobId) async {
    final url = Uri.parse("$baseUrl/add_saved_job.php");
    final response = await http.post(
      url,
      body: {"user_id": userId, "job_id": jobId},
    );

    if (response.statusCode != 200) return false;
    try {
      final data = jsonDecode(response.body);
      return data["status"] == "saved" || data["status"] == "success";
    } catch (_) {
      return false;
    }
  }

  static Future<bool> applyJob(String userId, String jobId) async {
    final url = Uri.parse("$baseUrl/apply_job.php");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"user_id": userId, "job_id": jobId}),
    );

    print("APPLY RESPONSE: ${response.body}");

    if (response.statusCode != 200) return false;

    final data = jsonDecode(response.body);
    return data["status"] == "success";
  }
}
