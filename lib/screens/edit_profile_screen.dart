import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../services/job_service.dart'; // Assuming this path is correct

// --- THEME COLORS ---
const Color primaryDarkColor = Color(0xFF0D0D12); // Deep dark background
const Color accentNeon = Color(0xFF00FFFF); // Neon accent color
const Color primaryTextColor = Colors.white; // White text for contrast
const Color cardDarkColor = Color(
  0xFF1B1B25,
); // Slightly lighter dark for input fields/cards
const Color errorColor = Color(0xFFFF4D4D); // A distinct error color

class EditProfileScreen extends StatefulWidget {
  final String userId;
  const EditProfileScreen({super.key, required this.userId});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  // Controllers
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final designationCtrl = TextEditingController();
  final experienceCtrl = TextEditingController();
  final locationCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();

  // Files
  File? avatarFile;
  File? resumeFile;

  // State flags
  bool loading = true;
  bool isSaving = false; // New: For 'Save Changes' button loading state

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  // Dispose controllers to prevent memory leaks
  @override
  void dispose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    designationCtrl.dispose();
    experienceCtrl.dispose();
    locationCtrl.dispose();
    phoneCtrl.dispose();
    super.dispose();
  }

  /// 📥 Load Profile Data
  Future<void> _loadProfile() async {
    try {
      final data = await JobService.fetchProfileData(widget.userId);
      final user = data["user"];

      // Safely populate controllers
      nameCtrl.text = user["name"] ?? "";
      emailCtrl.text = user["email"] ?? "";
      designationCtrl.text = user["designation"] ?? "";
      experienceCtrl.text = user["experience"] ?? "";
      locationCtrl.text = user["location"] ?? "";
      phoneCtrl.text = user["phone"] ?? "";
    } catch (e) {
      // Handle loading error (optional: show a message)
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Failed to load profile.")));
      }
    } finally {
      setState(() => loading = false);
    }
  }

  /// 🖼️ Pick Profile Image
  Future<void> _pickAvatar() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.single.path != null) {
      setState(() => avatarFile = File(result.files.single.path!));
    }
  }

  /// 📄 Pick Resume File
  Future<void> _pickResume() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );
    if (result != null && result.files.single.path != null) {
      setState(() => resumeFile = File(result.files.single.path!));
    }
  }

  /// 💾 Save Profile Changes
  Future<void> _save() async {
    if (isSaving) return; // Prevent multiple taps

    setState(() => isSaving = true); // Start loading

    final payload = {
      "user_id": widget.userId,
      "name": nameCtrl.text.trim(),
      "email": emailCtrl.text.trim(),
      "designation": designationCtrl.text.trim(),
      "experience": experienceCtrl.text.trim(),
      "location": locationCtrl.text.trim(),
      "phone": phoneCtrl.text.trim(),
    };

    try {
      final success = await JobService.updateProfile(
        payload,
        avatarFile,
        resumeFile,
      );

      if (success && mounted) {
        // Show success message and navigate back
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Profile Updated Successfully!"),
            backgroundColor: accentNeon,
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.pop(
          context,
          true,
        ); // Pass true to indicate a successful update
      } else if (!success && mounted) {
        // Show a generic failure message if the service returns false
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Failed to update profile. Please try again."),
            backgroundColor: errorColor,
          ),
        );
      }
    } catch (e) {
      // Show error on exception
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("An error occurred: $e"),
            backgroundColor: errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isSaving = false); // Stop loading
      }
    }
  }

  // --- WIDGET BUILDER ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryDarkColor,
      appBar: AppBar(
        title: const Text(
          "Edit Profile",
          style: TextStyle(
            color: primaryTextColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: primaryDarkColor,
        elevation: 0, // Remove shadow
        iconTheme: const IconThemeData(color: primaryTextColor),
      ),
      body: loading
          ? Center(child: CircularProgressIndicator(color: accentNeon))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- Avatar Section ---
                  _buildAvatarSection(),
                  const SizedBox(height: 30),

                  // --- Profile Inputs ---
                  _input("Full Name", nameCtrl, icon: Icons.person_outline),
                  _input(
                    "Email Address",
                    emailCtrl,
                    icon: Icons.email_outlined,
                  ),
                  _input(
                    "Phone Number",
                    phoneCtrl,
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                  ),
                  _input(
                    "Current Title",
                    designationCtrl,
                    icon: Icons.work_outline,
                  ),
                  _input(
                    "Years of Experience",
                    experienceCtrl,
                    icon: Icons.schedule_outlined,
                    keyboardType: TextInputType.number,
                  ),
                  _input(
                    "Location",
                    locationCtrl,
                    icon: Icons.location_on_outlined,
                  ),

                  const SizedBox(height: 20),

                  // --- Resume Upload Button ---
                  _buildResumeUploadButton(),

                  const SizedBox(height: 40),

                  // --- Save Button ---
                  _buildSaveButton(),
                ],
              ),
            ),
    );
  }

  // --- Helper Widgets ---

  /// 👤 Avatar Section Widget
  Widget _buildAvatarSection() {
    return Center(
      child: GestureDetector(
        onTap: _pickAvatar,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CircleAvatar(
              radius: 60, // Slightly larger
              backgroundColor: cardDarkColor,
              backgroundImage: avatarFile != null
                  ? FileImage(avatarFile!)
                  : null, // Placeholder for existing image would go here
              child: avatarFile == null
                  ? Icon(Icons.person, size: 40, color: Colors.grey[600])
                  : null,
            ),
            // Floating Camera Icon
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: accentNeon,
                  shape: BoxShape.circle,
                  border: Border.all(color: primaryDarkColor, width: 3),
                ),
                child: const Icon(
                  Icons.camera_alt,
                  size: 20,
                  color: primaryDarkColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 📄 Resume Upload Button Widget
  Widget _buildResumeUploadButton() {
    final bool isResumeSelected = resumeFile != null;
    final String buttonText = isResumeSelected
        ? "Resume Selected"
        : "Upload Resume";
    final IconData icon = isResumeSelected
        ? Icons.check_circle_outline
        : Icons.upload_file;

    return OutlinedButton.icon(
      onPressed: _pickResume,
      style: OutlinedButton.styleFrom(
        foregroundColor: isResumeSelected ? accentNeon : primaryTextColor,
        side: BorderSide(
          color: isResumeSelected ? accentNeon : Colors.grey.shade700,
          width: 1.5,
        ),
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      icon: Icon(icon, size: 24),
      label: Text(
        buttonText,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  /// 💾 Save Button Widget
  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: isSaving ? null : _save, // Disable when saving
      style: ElevatedButton.styleFrom(
        backgroundColor: accentNeon,
        foregroundColor: primaryDarkColor,
        padding: const EdgeInsets.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: isSaving ? 0 : 8, // Add a subtle lift when not disabled
        shadowColor: accentNeon.withOpacity(0.5),
      ),
      child: isSaving
          ? SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                color: primaryDarkColor,
                strokeWidth: 3,
              ),
            )
          : const Text(
              "SAVE CHANGES",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
              ),
            ),
    );
  }

  /// 🖋️ Custom Input Field Widget
  Widget _input(
    String label,
    TextEditingController controller, {
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(color: primaryTextColor),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey.shade400),
          prefixIcon: Icon(icon, color: accentNeon.withOpacity(0.7)),
          filled: true,
          fillColor: cardDarkColor,
          // Focused Border
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: accentNeon, width: 2),
          ),
          // Default Border
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade800, width: 1),
          ),
          // Error Border (optional, but good practice)
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: errorColor, width: 1),
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 15,
            horizontal: 15,
          ),
        ),
      ),
    );
  }
}
