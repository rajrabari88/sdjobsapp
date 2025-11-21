import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/job.dart';

class JobService {
  static const String baseUrl = "http://192.168.1.194/sdjobs/api";

  static Future<Map<String, dynamic>> fetchHomeData(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/home_data.php?user_id=$userId'),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to load home data");
    }

    final data = json.decode(response.body);

    if (data['status'] != 'success') {
      throw Exception("API returned error");
    }

    // ✅ Parse Featured Jobs List
    List<Job> featuredJobs = [];
    if (data['featured_jobs'] != null) {
      featuredJobs = (data['featured_jobs'] as List)
          .map((job) => Job.fromJson(job))
          .toList();
    }

    // ✅ Parse Recent Jobs
    List<Job> recentJobs = [];
    if (data['recent_jobs'] != null) {
      recentJobs = (data['recent_jobs'] as List)
          .map((job) => Job.fromJson(job))
          .toList();
    }

    return {
      "user": data['user'],
      "featured_jobs": featuredJobs,
      "categories": data['categories'] ?? [],
      "recent_jobs": recentJobs,
    };
  }

  // 🔍 Search Jobs
  static Future<List<Job>> searchJobs(String query, String userId) async {
    if (query.trim().isEmpty) return [];

    final url = Uri.parse(
      '$baseUrl/search_jobs.php?q=${Uri.encodeQueryComponent(query)}&user_id=$userId',
    );

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception("Search failed");
    }

    final data = json.decode(response.body);

    // API format:
    // { status: success, results: [...] }

    if (data is Map && data["results"] is List) {
      return (data["results"] as List)
          .map((item) => Job.fromJson(item))
          .toList();
    }

    return [];
  }

  static Future<Map<String, dynamic>> fetchProfileData(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/profile_data.php?user_id=$userId'),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to load profile data");
    }

    final data = json.decode(response.body);

    if (data['status'] != 'success') {
      throw Exception("API returned error");
    }

    return {
      "user": data['user'],
      "saved_jobs_count": data['saved_jobs_count'] ?? 0,
      "applied_jobs_count": data['applied_jobs_count'] ?? 0,
      "notifications_count": data['notifications_count'] ?? 0,
    };
  }

  static Future<bool> updateProfile(
    Map<String, dynamic> data,
    File? avatar,
    File? resume,
  ) async {
    try {
      final url = Uri.parse(
        "http://192.168.1.194/sdjobs/api/profile_update.php",
      );

      var request = http.MultipartRequest("POST", url);

      data.forEach((key, value) {
        request.fields[key] = value.toString();
      });

      if (avatar != null) {
        request.files.add(
          await http.MultipartFile.fromPath('avatar', avatar.path),
        );
      }

      if (resume != null) {
        request.files.add(
          await http.MultipartFile.fromPath('resume', resume.path),
        );
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      final result = json.decode(response.body);

      return result["status"] == "success";
    } catch (e) {
      print("Profile Update Error: $e");
      return false;
    }
  }

  // 💼 SUBMIT JOB APPLICATION (Send to PHP Backend)
  static Future<bool> submitJobApplication({
    required String userId,
    required String jobId,
    required String coverLetter,
    required String experience,
    required String additionalNotes,
    required String name,
    required String email,
    required String phone,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/submit_application.php'),
        body: {
          'user_id': userId.toString(),
          'job_id': jobId.toString(),
          'name': name.toString(),
          'email': email.toString(),
          'phone': phone.toString(),
          'cover_letter': coverLetter.toString(),
          'experience': experience.toString(),
          'additional_notes': additionalNotes.toString(),
        },
      );

      if (response.statusCode != 200) {
        print("API Error: ${response.statusCode}");
        return false;
      }

      final data = json.decode(response.body);
      return data['status'] == 'success';
    } catch (e) {
      print("Submit Application Error: $e");
      return false;
    }
  }
}
