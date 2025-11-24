// resume_screen.dart
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

// --- Theme Constants ---
const Color primaryDarkColor = Color(0xFF0D0D12); // Deep dark background
const Color accentNeon = Color(0xFF00FFFF); // Neon Cyan for accents
const Color primaryTextColor = Colors.white;
const Color secondaryTextColor = Color(0xFFAAAAAA); // Light Grey
const Color cardDarkColor = Color(
  0xFF1B1B25,
); // Slightly lighter card background
const Color subtleGrey = Color(0xFF424242);

// --- Service ---
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

  static Future<bool> setPrimary(String docId, String userId) async {
    final response = await http.post(
      Uri.parse("$baseUrl/set_primary.php"),
      headers: headers,
      body: jsonEncode({"id": docId, "user_id": userId}),
    );

    if (response.statusCode != 200) {
      print("Set Primary Error: ${response.statusCode} - ${response.body}");
      return false;
    }

    final result = jsonDecode(response.body);
    return result["status"] == "success";
  }
}

// --- Main Screen Widget ---
class ResumeScreen extends StatefulWidget {
  final String userId;
  const ResumeScreen({super.key, required this.userId});

  @override
  State<ResumeScreen> createState() => _ResumeScreenState();
}

class _ResumeScreenState extends State<ResumeScreen> {
  List<Map<String, dynamic>> uploadedDocs = [];
  bool loading = false;
  bool uploading = false;

  @override
  void initState() {
    super.initState();
    fetchDocuments();
  }

  Future<void> fetchDocuments() async {
    setState(() => loading = true);
    try {
      final docs = await ResumeService.getUserDocuments(widget.userId);
      uploadedDocs = List<Map<String, dynamic>>.from(docs);
      uploadedDocs.sort(
        (a, b) =>
            b["is_primary"].toString().compareTo(a["is_primary"].toString()),
      );
    } catch (e) {
      print("❌ Error fetching documents: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("❌ Failed to load documents.")),
        );
      }
    }
    setState(() => loading = false);
  }

  Future<void> uploadFile() async {
    final result = await FilePicker.platform.pickFiles(
      withData: true,
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );

    if (result == null) return;
    final file = result.files.first;
    if (file.bytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ File content not available.")),
      );
      return;
    }

    setState(() => uploading = true);
    final success = await ResumeService.uploadDocument(
      widget.userId,
      file.name,
      file.bytes!,
    );

    if (success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("✅ Upload Successful")));
      fetchDocuments();
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("❌ Upload Failed")));
    }

    setState(() => uploading = false);
  }

  Future<void> downloadAndOpen(String fileUrl, String filename) async {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Downloading...")));
    try {
      final response = await http.get(Uri.parse(fileUrl));
      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/$filename');
        await file.writeAsBytes(bytes, flush: true);
        final openResult = await OpenFilex.open(file.path);
        if (openResult.type != ResultType.done) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Could not open file: ${openResult.message}"),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Download Failed.")));
      }
    } catch (e) {
      print("❌ Download error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Download Failed. Network error.")),
      );
    }
  }

  Future<void> deleteFile(String docId) async {
    final success = await ResumeService.deleteDocument(docId);
    if (success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("🗑️ Document Deleted")));
      fetchDocuments();
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("❌ Deletion Failed")));
    }
  }

  Future<void> setPrimary(String docId) async {
    final success = await ResumeService.setPrimary(docId, widget.userId);
    if (success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("⭐ Primary Resume Set")));
      fetchDocuments();
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("❌ Failed to Set Primary")));
    }
  }

  Widget buildUploadCard() {
    return InkWell(
      onTap: uploading ? null : uploadFile,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: cardDarkColor,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: accentNeon.withOpacity(0.7), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: accentNeon.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              uploading ? Icons.hourglass_top : Icons.cloud_upload_outlined,
              size: 50,
              color: accentNeon,
            ),
            const SizedBox(height: 15),
            Text(
              "Upload New Document",
              style: TextStyle(
                color: primaryTextColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              uploading
                  ? "Uploading, please wait..."
                  : "PDF, DOCX, DOC files supported",
              style: TextStyle(color: secondaryTextColor, fontSize: 13),
            ),
            if (uploading)
              const Padding(
                padding: EdgeInsets.only(top: 10),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: accentNeon,
                    strokeWidth: 2,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget buildDocumentItem(Map<String, dynamic> doc) {
    final isPrimary = doc["is_primary"].toString() == "1";
    final fileName = doc["file_name"] as String;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Card(
        color: isPrimary ? accentNeon.withOpacity(0.1) : cardDarkColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: isPrimary
              ? BorderSide(color: accentNeon, width: 2)
              : BorderSide.none,
        ),
        elevation: 4,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          leading: Icon(
            Icons.insert_drive_file_rounded,
            color: isPrimary ? accentNeon : secondaryTextColor,
            size: 30,
          ),
          title: Text(
            fileName,
            style: TextStyle(
              color: primaryTextColor,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: isPrimary
              ? Text(
                  "PRIMARY",
                  style: TextStyle(
                    color: accentNeon,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                )
              : Text(
                  "Tap to view options",
                  style: TextStyle(color: subtleGrey),
                ),
          trailing: PopupMenuButton<int>(
            color: cardDarkColor,
            icon: Icon(
              Icons.more_vert,
              color: isPrimary ? accentNeon : secondaryTextColor,
            ),
            onSelected: (v) {
              if (v == 1) downloadAndOpen(doc["file_url"], fileName);
              if (v == 2) setPrimary(doc["id"].toString());
              if (v == 3) deleteFile(doc["id"].toString());
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
              const PopupMenuItem<int>(
                value: 1,
                child: Text(
                  "Download & View",
                  style: TextStyle(color: primaryTextColor),
                ),
              ),
              if (!isPrimary)
                const PopupMenuItem<int>(
                  value: 2,
                  child: Text(
                    "Set Primary",
                    style: TextStyle(color: accentNeon),
                  ),
                ),
              if (uploadedDocs.length > 1 || !isPrimary)
                const PopupMenuItem<int>(
                  value: 3,
                  child: Text(
                    "Delete",
                    style: TextStyle(color: Colors.redAccent),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryDarkColor,
      appBar: AppBar(
        title: const Text(
          "Resume & Documents",
          style: TextStyle(
            color: primaryTextColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: primaryDarkColor,
        elevation: 0,
        leading: const BackButton(color: primaryTextColor),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: subtleGrey.withOpacity(0.5), height: 1.0),
        ),
      ),
      body: loading
          ? Center(child: CircularProgressIndicator(color: accentNeon))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(child: buildUploadCard()),
                  const SizedBox(height: 40),
                  Text(
                    "Your Uploaded Documents (${uploadedDocs.length})",
                    style: TextStyle(
                      color: primaryTextColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 15),
                  uploadedDocs.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 40.0),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.description_outlined,
                                  size: 60,
                                  color: subtleGrey,
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  "No Resume/Documents Uploaded yet.",
                                  style: TextStyle(
                                    color: secondaryTextColor,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : Column(
                          children: uploadedDocs
                              .map(buildDocumentItem)
                              .toList(),
                        ),
                ],
              ),
            ),
    );
  }
}
