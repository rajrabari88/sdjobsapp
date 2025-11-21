import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/job_service.dart';

import '../widgets/custom_appbar.dart';
import 'edit_profile_screen.dart';
import 'resume_screen.dart';
import 'saved_jobs_screen.dart';
import 'applications_screen.dart';
import 'help_support_screen.dart';
import 'login_screen.dart';

// COLORS
const Color primaryDarkColor = Color(0xFF0D0D12);
const Color accentNeon = Color(0xFF00FFFF);
const Color secondaryAccent = Color(0xFF4A64FE);
const Color cardDarkColor = Color(0xFF1B1B25);
const Color textLightColor = Colors.white;
const Color logoutRed = Color(0xFFE53935);

// HEADER GRADIENT
const Gradient _kHeaderGradient = LinearGradient(
  colors: [secondaryAccent, primaryDarkColor],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

class ProfileScreen extends StatefulWidget {
  final String userId;

  const ProfileScreen({super.key, required this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  bool _loading = true;
  Map<String, dynamic>? _userData;

  int savedJobs = 0;
  int appliedJobs = 0;
  int notificationsCount = 0;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final data = await JobService.fetchProfileData(widget.userId);
    setState(() {
      _userData = data["user"];
      savedJobs = data["saved_jobs_count"] ?? 0;
      appliedJobs = data["applied_jobs_count"] ?? 0;
      notificationsCount = data["notifications_count"] ?? 0;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryDarkColor,
      appBar: CustomAppBar(title: "My Profile"),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: accentNeon))
          : RefreshIndicator(
              onRefresh: _loadProfile,
              color: accentNeon,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    _buildHeaderCard(),
                    const SizedBox(height: 25),
                    _sectionHeader("Account & Documents"),
                    _menuCard([
                      _menuItem(Icons.person_rounded, "Edit Profile", () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                EditProfileScreen(userId: widget.userId),
                          ),
                        );
                        if (result == true) _loadProfile();
                      }),
                      _menuItem(
                        Icons.insert_drive_file_rounded,
                        "Resume & Documents",
                        () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ResumeScreen(userId: widget.userId),
                            ),
                          );
                          _loadProfile();
                        },
                      ),
                      _menuItem(
                        Icons.bookmark_rounded,
                        "Saved Jobs ($savedJobs)",
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SavedJobsScreen(
                                userId: widget.userId,
                                userData: _userData!,
                              ),
                            ),
                          );
                        },
                        last: true,
                      ),
                    ]),
                    const SizedBox(height: 25),
                    _sectionHeader("Activity & Support"),
                    _menuCard([
                      _menuItem(
                        Icons.work_history_rounded,
                        "My Applications ($appliedJobs)",
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ApplicationsScreen(
                                userId: int.parse(widget.userId),
                              ),
                            ),
                          );
                        },
                      ),
                      // _menuItem(
                      //   Icons.notifications_active_rounded,
                      //   "Notifications ($notificationsCount)",
                      //   () {
                      //     Navigator.push(
                      //       context,
                      //       MaterialPageRoute(
                      //         builder: (_) => const NotificationsScreen(),
                      //       ),
                      //     );
                      //   },
                      // ),
                      _menuItem(
                        Icons.support_agent_rounded,
                        "chat with us",
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const HelpSupportScreen(),
                            ),
                          );
                        },
                        last: true,
                      ),
                    ]),
                    const SizedBox(height: 25),
                    _sectionHeader("Logout"),
                    _menuCard([
                      // _menuItem(Icons.settings_rounded, "App Settings", () {
                      //   Navigator.push(
                      //     context,
                      //     MaterialPageRoute(
                      //       builder: (_) => const SettingsScreen(),
                      //     ),
                      //   );
                      // }),
                      _menuItem(
                        Icons.logout_rounded,
                        "Logout",
                        () {
                          _logout(context);
                        },
                        color: logoutRed,
                        last: true,
                      ),
                    ]),
                  ],
                ),
              ),
            ),
    );
  }

  // HEADER CARD (MODERN LOOK)
  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        gradient: _kHeaderGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: accentNeon.withOpacity(0.15),
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 45,
            backgroundImage:
                _userData?["avatar_url"] != null &&
                    _userData!["avatar_url"].toString().isNotEmpty
                ? NetworkImage(_userData!["avatar_url"])
                : null,
            child:
                (_userData?["avatar_url"] == null ||
                    _userData!["avatar_url"].toString().isEmpty)
                ? const Icon(Icons.person_rounded, size: 55, color: accentNeon)
                : null,
          ),
          const SizedBox(height: 14),
          Text(
            _userData?["name"] ?? "User",
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: textLightColor,
            ),
          ),
          Text(
            "${_userData?["designation"] ?? "Not updated"} • ${_userData?["experience"] ?? "0 Years"}",
            style: TextStyle(
              color: Colors.white.withOpacity(0.75),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 18),
          ElevatedButton(
            onPressed: () {
              final url = _userData?["resume_url"];
              if (url != null && url.toString().isNotEmpty) {
                launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: accentNeon,
              foregroundColor: primaryDarkColor,
              padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text("Download Resume"),
          ),
        ],
      ),
    );
  }

  // SECTION TITLE
  Widget _sectionHeader(String title) => Align(
    alignment: Alignment.centerLeft,
    child: Padding(
      padding: const EdgeInsets.only(left: 6, bottom: 8),
      child: Text(
        title,
        style: TextStyle(color: Colors.grey[400], fontSize: 14),
      ),
    ),
  );

  // CARD
  Widget _menuCard(List<Widget> children) => Container(
    decoration: BoxDecoration(
      color: cardDarkColor,
      borderRadius: BorderRadius.circular(15),
      boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 10),
      ],
    ),
    child: Column(children: children),
  );

  // MENU ITEM
  Widget _menuItem(
    IconData icon,
    String label,
    VoidCallback onTap, {
    Color color = textLightColor,
    bool last = false,
  }) => Column(
    children: [
      ListTile(
        leading: Icon(icon, color: color, size: 26),
        title: Text(label, style: TextStyle(color: color, fontSize: 15)),
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          size: 16,
          color: Colors.grey[500],
        ),
        onTap: onTap,
      ),
      if (!last) Divider(color: Colors.white12, indent: 18, endIndent: 18),
    ],
  );

  // LOGOUT
  void _logout(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }
}
