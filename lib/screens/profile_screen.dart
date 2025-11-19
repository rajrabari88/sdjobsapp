import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/job_service.dart';
import '../widgets/custom_appbar.dart';
import 'edit_profile_screen.dart';
import 'resume_screen.dart';
import 'saved_jobs_screen.dart';
import 'applications_screen.dart';
import 'notifications_screen.dart';
import 'help_support_screen.dart';
import 'settings_screen.dart';
import 'login_screen.dart';

const Color primaryDarkColor = Color(0xFF0D0D12);
const Color accentNeon = Color(0xFF00FFFF);
const Color secondaryAccent = Color(0xFF4A64FE);
const Color cardDarkColor = Color(0xFF1B1B25);
const Color textLightColor = Colors.white;
const Color logoutRed = Color(0xFFE53935);

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

class _ProfileScreenState extends State<ProfileScreen> {
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
      appBar: const CustomAppBar(title: 'My Profile'),
      body: _loading
          ? Center(child: CircularProgressIndicator(color: accentNeon))
          : RefreshIndicator(
              onRefresh: _loadProfile,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 30),

                    _section("Account & Documents", [
                      _item(Icons.person_rounded, 'Edit Profile', () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                EditProfileScreen(userId: widget.userId),
                          ),
                        );
                        if (result == true) _loadProfile();
                      }),
                      _item(
                        Icons.article_rounded,
                        'Resume & Documents',
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
                      _item(
                        Icons.bookmark_rounded,
                        'Saved Jobs ($savedJobs)',
                        () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  SavedJobsScreen(userId: widget.userId),
                            ),
                          );
                          // Refresh counts after returning
                          _loadProfile();
                        },
                        last: true,
                      ),
                    ]),

                    const SizedBox(height: 25),

                    _section("Activity & Support", [
                      _item(
                        Icons.work_history_rounded,
                        'My Applications ($appliedJobs)',
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ApplicationsScreen(),
                            ),
                          );
                        },
                      ),
                      _item(
                        Icons.notifications_active_rounded,
                        'Notifications ($notificationsCount)',
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const NotificationsScreen(),
                            ),
                          );
                        },
                      ),
                      _item(Icons.support_agent_rounded, 'Help & Support', () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const HelpSupportScreen(),
                          ),
                        );
                      }, last: true),
                    ]),

                    const SizedBox(height: 25),

                    _section("General", [
                      _item(Icons.settings_rounded, 'App Settings', () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SettingsScreen(),
                          ),
                        );
                      }),
                      _item(
                        Icons.logout_rounded,
                        'Logout',
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

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: _kHeaderGradient,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 48,
            backgroundImage:
                _userData?["avatar_url"] != null &&
                    _userData!["avatar_url"] != ""
                ? NetworkImage(_userData!["avatar_url"])
                : null,
            child:
                (_userData?["avatar_url"] == null ||
                    _userData!["avatar_url"] == "")
                ? Icon(Icons.person_rounded, size: 55, color: accentNeon)
                : null,
          ),
          const SizedBox(height: 16),
          Text(
            _userData?["name"] ?? "User",
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: textLightColor,
            ),
          ),
          Text(
            '${_userData?["designation"] ?? "Not updated"} • ${_userData?["experience"] ?? "0 Years"}',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),
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
            ),
            child: const Text("Download Resume"),
          ),
        ],
      ),
    );
  }

  Widget _section(String title, List<Widget> items) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(left: 8, bottom: 8),
        child: Text(title, style: TextStyle(color: Colors.grey)),
      ),
      Container(
        decoration: BoxDecoration(
          color: cardDarkColor,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(children: items),
      ),
    ],
  );

  Widget _item(
    IconData icon,
    String label,
    VoidCallback onTap, {
    Color color = textLightColor,
    bool last = false,
  }) => Column(
    children: [
      ListTile(
        leading: Icon(icon, color: color),
        title: Text(label, style: TextStyle(color: color)),
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          size: 16,
          color: Colors.grey.shade600,
        ),
        onTap: onTap,
      ),
      if (!last) Divider(color: Colors.white12, endIndent: 16, indent: 16),
    ],
  );

  _logout(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }
}
