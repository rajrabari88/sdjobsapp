// resume_screen.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

// --- Theme Constants ---
const String baseUrl = 'http://192.168.1.194/sdjobs/api/';
const Color primaryDarkColor = Color(0xFF0D0D12); // Deep dark background
const Color accentNeon = Color(0xFF00FFFF); // Neon Cyan for accents
const Color primaryTextColor = Colors.white;
const Color secondaryTextColor = Color(
  0xFFAAAAAA,
); // Light Grey for subtle text
const Color cardDarkColor = Color(
  0xFF1B1B25,
); // Slightly lighter card background
const Color subtleGrey = Color(0xFF424242);
const Color fileIconColor = Color(
  0xFFE53935,
); // Not used in new design, replaced with accentNeon

// --- Main Screen Widget ---
class ResumeScreen extends StatefulWidget {
  final String userId;
  const ResumeScreen({super.key, required this.userId});

  @override
  State<ResumeScreen> createState() => _ResumeScreenState();
}

class _ResumeScreenState extends State<ResumeScreen> {
  // List to hold uploaded documents. Structure: [{"id": 1, "file_name": "...", "file_url": "...", "is_primary": "1"}, ...]
  List<Map<String, dynamic>> uploadedDocs = [];
  bool loading = false;
  bool uploading = false;

  @override
  void initState() {
    super.initState();
    fetchDocuments();
  }

  // --- API Calls & Logic ---

  Future<void> fetchDocuments() async {
    setState(() => loading = true);
    uploadedDocs.clear(); // Clear existing list before fetching

    try {
      final uri = Uri.parse(
        '$baseUrl/get_documents.php?user_id=${widget.userId}',
      );
      final resp = await http.get(uri);

      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);

        if (data != null && data["documents"] is List) {
          // Sort documents: Primary document comes first
          List<Map<String, dynamic>> fetchedList =
              List<Map<String, dynamic>>.from(data["documents"]);

          fetchedList.sort((a, b) {
            // "1" (primary) should be before "0" (not primary)
            return b["is_primary"].toString().compareTo(
              a["is_primary"].toString(),
            );
          });

          uploadedDocs = fetchedList;
        }
      }
    } catch (e) {
      print("❌ Error fetching documents: $e");
      // Show error to user
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
      allowedExtensions: ['pdf', 'doc', 'docx'], // Restrict file types
    );

    if (result == null) return;

    final file = result.files.first;
    final fileName = file.name;
    final fileBytes = file.bytes;

    if (fileBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ File content not available.")),
      );
      return;
    }

    setState(() => uploading = true);

    var request = http.MultipartRequest(
      "POST",
      Uri.parse("${baseUrl}upload_document.php"),
    );

    request.fields["user_id"] = widget.userId;
    request.files.add(
      http.MultipartFile.fromBytes("file", fileBytes, filename: fileName),
    );

    try {
      var response = await request.send();
      if (response.statusCode == 200) {
        // Read response body for success message/error details if needed
        final respBody = await response.stream.bytesToString();
        final respData = jsonDecode(respBody);

        if (respData['status'] == 'success') {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("✅ Upload Successful")));
          fetchDocuments();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "❌ Upload Failed: ${respData['message'] ?? 'Unknown error'}",
              ),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "❌ Upload Failed. Server returned code ${response.statusCode}",
            ),
          ),
        );
      }
    } catch (e) {
      print("❌ Upload error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Upload Failed. Check connection.")),
      );
    } finally {
      setState(() => uploading = false);
    }
  }

  Future<void> downloadAndOpen(String fileUrl, String filename) async {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Downloading...")));
    try {
      final response = await http.get(Uri.parse(fileUrl));
      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;

        // Use getApplicationDocumentsDirectory for persistent storage if needed,
        // but getTemporaryDirectory is fine for quick view.
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Download Failed. File not found.")),
        );
      }
    } catch (e) {
      print("❌ Download error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Download Failed. Network error.")),
      );
    }
  }

  Future<void> deleteFile(String id, String fileUrl) async {
    final resp = await http.post(
      Uri.parse("${baseUrl}delete_document.php"),
      body: {"id": id, "file_url": fileUrl},
    );
    if (resp.statusCode == 200) {
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

  Future<void> setPrimary(String id) async {
    final resp = await http.post(
      Uri.parse("${baseUrl}set_primary.php"),
      body: {"id": id, "user_id": widget.userId},
    );
    if (resp.statusCode == 200) {
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

  // --- UI Components ---

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
              if (v == 3) deleteFile(doc["id"].toString(), doc["file_url"]);
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
              const PopupMenuItem<int>(
                value: 1,
                child: Text(
                  "Download & View",
                  style: TextStyle(color: primaryTextColor),
                ),
              ),
              if (!isPrimary) // Option to set primary only if it's not already primary
                const PopupMenuItem<int>(
                  value: 2,
                  child: Text(
                    "Set Primary",
                    style: TextStyle(color: accentNeon),
                  ),
                ),
              if (uploadedDocs.length > 1 ||
                  !isPrimary) // Prevent deleting the last primary document if only one exists (Optional guardrail)
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
        // Adding a subtle border at the bottom of the AppBar for definition
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
                crossAxisAlignment: CrossAxisAlignment
                    .start, // Keep this as start for text alignment
                children: [
                  // --- Upload Card Section (Now Centered) ---
                  Center(child: buildUploadCard()),
                  const SizedBox(height: 40),

                  // --- Documents List Section ---
                  Text(
                    "Your Uploaded Documents (${uploadedDocs.length})",
                    style: TextStyle(
                      color: primaryTextColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 15),

                  // --- Documents List ---
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
