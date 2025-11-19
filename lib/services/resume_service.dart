import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class ResumeService {
  static const String baseUrl = "http://192.168.1.194/sdjobs/api";

  static Future<List> getUserDocuments(String userId) async {
    final response = await http.get(
      Uri.parse("$baseUrl/get_documents.php?user_id=$userId"),
    );
    return jsonDecode(response.body)["documents"];
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
    request.fields["user_id"] = userId;
    request.files.add(
      http.MultipartFile.fromBytes("file", fileBytes, filename: fileName),
    );
    return (await request.send()).statusCode == 200;
  }

  static Future<bool> deleteDocument(String docId) async {
    final response = await http.post(
      Uri.parse("$baseUrl/delete_document.php"),
      body: {"doc_id": docId},
    );
    return response.statusCode == 200;
  }
}
