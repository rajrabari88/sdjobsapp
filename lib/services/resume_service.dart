import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class ResumeService {
  static const String baseUrl = "http://192.168.1.4/sdjobs/api";
  static const String staticToken = "9313069472"; // 🔑 Static token

  static Map<String, String> get headers => {
    "Content-Type": "application/json",
    "Authorization": "Bearer $staticToken",
  };

  static Future<List> getUserDocuments(String userId) async {
    final response = await http.get(
      Uri.parse("$baseUrl/get_documents.php?user_id=$userId"),
      headers: headers,
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to fetch documents");
    }

    final data = jsonDecode(response.body);
    return data["documents"] ?? [];
  }

  static Future<bool> uploadDocument(
    String userId,
    String fileName,
    Uint8List fileBytes,
  ) async {
    var request = http.MultipartRequest(
      "POST",
      Uri.parse("$baseUrl/upload_document.php"),
    );

    request.headers["Authorization"] = "Bearer $staticToken";
    request.fields["user_id"] = userId;
    request.files.add(
      http.MultipartFile.fromBytes("file", fileBytes, filename: fileName),
    );

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200) {
      print("Upload Document Error: ${response.statusCode} - ${response.body}");
      return false;
    }

    final result = jsonDecode(response.body);
    return result["status"] == "success";
  }

  static Future<bool> deleteDocument(String docId) async {
    final response = await http.post(
      Uri.parse("$baseUrl/delete_document.php"),
      headers: headers,
      body: jsonEncode({"doc_id": docId}),
    );

    if (response.statusCode != 200) {
      print("Delete Document Error: ${response.statusCode} - ${response.body}");
      return false;
    }

    final result = jsonDecode(response.body);
    return result["status"] == "success";
  }
}
