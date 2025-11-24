import 'package:flutter/material.dart';
import '../services/job_service.dart';
import '../services/saved_job_service.dart';
import '../models/job.dart';
import '../widgets/custom_appbar.dart';
import '../widgets/job_card.dart';
import '../widgets/job_application_modal.dart';
import '../utils/responsive.dart';
import 'dart:async'; // Timer ke liye
import 'package:shared_preferences/shared_preferences.dart'; // SharedPreferences ke liye
import '../services/api_service.dart'; // ApiService ke liye

// --- DARK THEME CONSTANTS ---
const Color primaryDarkColor = Color(0xFF0D0D12);
const Color accentNeon = Color(0xFF00FFFF);
const Color secondaryAccent = Color.fromARGB(255, 241, 128, 36);
const Color cardDarkColor = Color(0xFF1B1B25);
const Color textLightColor = Colors.white;

class HomeScreen extends StatefulWidget {
  final String userId;
  const HomeScreen({super.key, required this.userId});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool loading = true;
  Map<String, dynamic>? userData;
  List<Job> featuredJobs = [];
  List<Job> recentJobs = [];
  bool hasUnread = false;
  String userId = "0";

  Timer? _unreadTimer;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadUserId();
    fetchHomeData();
    // checkUnreadLoop(); // Uncomment if you want unread messages check
  }

  Future<void> loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getString("userId") ?? "0";
  }

  // --- OPTIONAL: Unread messages check loop ---
  void checkUnreadLoop() {
    _unreadTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (userId == "0") return;

      bool unread = await ApiService.checkUnread(userId);
      if (!mounted) return;

      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setBool("hasUnreadMessages", unread);

      setState(() {
        hasUnread = unread;
      });
    });
  }

  Future<void> fetchHomeData() async {
    try {
      final data = await JobService.fetchHomeData(widget.userId);
      if (!mounted) return;

      setState(() {
        userData = data['user'];
        featuredJobs = (data['featured_jobs'] as List<dynamic>)
            .map((item) => item as Job)
            .toList();
        recentJobs = (data['recent_jobs'] as List<dynamic>)
            .map((item) => item as Job)
            .toList();
        loading = false;
      });
    } catch (e) {
      debugPrint("Error fetching data: $e");
      if (!mounted) return;

      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load data in dark mode.')),
      );
    }
  }

  void toggleSave(Job job) {
    final previous = job.isSaved;
    setState(() => job.isSaved = !job.isSaved);

    if (job.isSaved) {
      SavedJobService.addSaved(widget.userId, job.id).then((ok) {
        if (!mounted) return;
        if (!ok) {
          setState(() => job.isSaved = previous);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Failed to save job.')));
        }
      });
    } else {
      SavedJobService.removeSaved(widget.userId, job.id).then((ok) {
        if (!mounted) return;
        if (!ok) {
          setState(() => job.isSaved = previous);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to remove saved job.')),
          );
        }
      });
    }
  }

  void _showJobApplicationModal(Job job) {
    if (userData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User data not loaded. Please try again.'),
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => JobApplicationModal(
        job: job,
        userData: userData!,
        userId: widget.userId,
      ),
    ).then((result) {
      if (!mounted) return;
      if (result == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Your application has been submitted!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _unreadTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        backgroundColor: primaryDarkColor,
        body: Center(child: CircularProgressIndicator(color: accentNeon)),
      );
    }

    return Scaffold(
      backgroundColor: primaryDarkColor,
      appBar: CustomAppBar(
        title: 'SDJobs',
        showBackButton: false,
        hasUnread: hasUnread,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: Responsive.isSmall(context) ? 16 : 24),
            _buildWelcomeCard(),
            SizedBox(height: Responsive.isSmall(context) ? 16 : 24),
            _buildStatsHeader(),
            _buildStaticStats(),
            if (featuredJobs.isNotEmpty) ...[
              _buildSectionHeader('🚀 Featured Opportunities'),
              SizedBox(height: Responsive.isSmall(context) ? 12 : 16),
              SizedBox(
                height: Responsive.featuredCardWidth(context) * 0.95,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: Responsive.contentPadding(
                    context,
                  ).copyWith(left: 16),
                  itemCount: featuredJobs.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.only(
                        right: index == featuredJobs.length - 1 ? 16 : 12,
                      ),
                      child: _FeaturedJobCard(
                        job: featuredJobs[index],
                        onApply: () =>
                            _showJobApplicationModal(featuredJobs[index]),
                        onSaveTap: () => toggleSave(featuredJobs[index]),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: Responsive.isSmall(context) ? 20 : 28),
            ],
            if (recentJobs.isNotEmpty) ...[
              _buildSectionHeader('Latest Listings'),
              SizedBox(height: Responsive.isSmall(context) ? 12 : 16),
              _buildRecentJobsList(),
            ],
            SizedBox(height: Responsive.isSmall(context) ? 20 : 30),
          ],
        ),
      ),
    );
  }

  // --- WIDGETS ---
  Widget _buildWelcomeCard() {
    final pad = Responsive.contentPadding(context);
    return Padding(
      padding: pad,
      child: Container(
        decoration: BoxDecoration(
          color: cardDarkColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.1), width: 1.5),
        ),
        padding: EdgeInsets.all(Responsive.isSmall(context) ? 16 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, ${userData?['name'] ?? 'Job Seeker'}!',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: Responsive.fontSize(context, 22),
                color: textLightColor,
              ),
            ),
            SizedBox(height: Responsive.isSmall(context) ? 6 : 8),
            Text(
              'Your next career move is waiting.',
              style: TextStyle(
                color: Colors.grey.shade400,
                fontSize: Responsive.fontSize(context, 15),
              ),
            ),
            SizedBox(height: Responsive.isSmall(context) ? 10 : 12),
            Row(
              children: [
                Icon(
                  Icons.location_on_rounded,
                  color: accentNeon,
                  size: Responsive.isSmall(context) ? 18 : 20,
                ),
                SizedBox(width: Responsive.isSmall(context) ? 6 : 8),
                Text(
                  userData?['location'] != null
                      ? 'Targeting ${userData!['location']}'
                      : 'Location preference not set',
                  style: TextStyle(
                    color: Colors.grey.shade300,
                    fontSize: Responsive.fontSize(context, 14),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStaticStats() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _statItem("1,200+", "Employers"),
          _statItem("4,500+", "Jobs"),
          _statItem("22+", "Categories"),
          _statItem("9,800+", "Hires"),
        ],
      ),
    );
  }

  Widget _buildStatsHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: accentNeon.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: accentNeon.withOpacity(0.4), width: 1),
            ),
            child: Icon(Icons.analytics_rounded, color: accentNeon, size: 16),
          ),
          const SizedBox(width: 10),
          const Text(
            "Platform Snapshot",
            style: TextStyle(
              color: textLightColor,
              fontSize: 15,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statItem(String number, String label) {
    final width = MediaQuery.of(context).size.width;
    double boxWidth = width < 360
        ? 70
        : width < 420
        ? 78
        : width < 600
        ? 85
        : 95;
    double numberSize = width < 360 ? 13 : 15;
    double labelSize = width < 360 ? 10 : 11;

    return Container(
      width: boxWidth,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
      decoration: BoxDecoration(
        color: primaryDarkColor.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accentNeon.withOpacity(0.5), width: 1),
        boxShadow: [
          BoxShadow(
            color: accentNeon.withOpacity(0.12),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            number,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: accentNeon,
              fontSize: numberSize,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade300, fontSize: labelSize),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textLightColor,
        ),
      ),
    );
  }

  Widget _buildRecentJobsList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: recentJobs.map((job) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 15),
            child: JobCard(
              title: job.title,
              company: job.company,
              location: job.location,
              salary: job.salary,
              type: job.type,
              logoText: job.logoText,
              experience: job.experience,
              isSaved: job.isSaved,
              onSaveTap: () => toggleSave(job),
              onApply: () => _showJobApplicationModal(job),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// --- FEATURED JOB CARD ---
class _FeaturedJobCard extends StatelessWidget {
  final Job job;
  final VoidCallback? onApply;
  final VoidCallback? onSaveTap;

  const _FeaturedJobCard({required this.job, this.onApply, this.onSaveTap});

  @override
  Widget build(BuildContext context) {
    final cardW = Responsive.featuredCardWidth(context);
    return Container(
      width: cardW,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            secondaryAccent.withOpacity(0.2),
            primaryDarkColor.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: secondaryAccent.withOpacity(0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: accentNeon.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onApply,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: EdgeInsets.all(Responsive.isSmall(context) ? 14 : 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CircleAvatar(
                      radius: Responsive.isSmall(context) ? 20 : 24,
                      backgroundColor: secondaryAccent,
                      child: Text(
                        job.logoText,
                        style: TextStyle(
                          color: textLightColor,
                          fontWeight: FontWeight.bold,
                          fontSize: Responsive.fontSize(context, 18),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: onSaveTap ?? () {},
                      child: Icon(
                        job.isSaved
                            ? Icons.bookmark_rounded
                            : Icons.bookmark_border_rounded,
                        color: job.isSaved ? accentNeon : Colors.grey.shade600,
                        size: Responsive.isSmall(context) ? 24 : 28,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  job.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: textLightColor,
                    fontWeight: FontWeight.w700,
                    fontSize: Responsive.fontSize(context, 20),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${job.company} • ${job.location}',
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: Responsive.fontSize(context, 13),
                  ),
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      job.salary,
                      style: TextStyle(
                        color: accentNeon,
                        fontWeight: FontWeight.w700,
                        fontSize: Responsive.fontSize(context, 15),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: secondaryAccent.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: secondaryAccent.withOpacity(0.6),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        job.type,
                        style: const TextStyle(
                          color: textLightColor,
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
