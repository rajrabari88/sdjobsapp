import 'package:flutter/material.dart';
import '../models/job.dart';
import '../services/job_service.dart';
import '../widgets/custom_appbar.dart';
import '../widgets/job_card.dart';
import '../services/saved_job_service.dart';
import '../widgets/job_application_modal.dart';
import 'dart:async'; // Keep this import for Timer if needed elsewhere

// --- DARK THEME CONSTANTS (Consistency is crucial) ---
const Color primaryDarkColor = Color(
  0xFF0D0D12,
); // Deep Navy/Near Black Background
const Color accentNeon = Color(0xFF00FFFF); // Neon Cyan/Blue for highlights
const Color secondaryAccent = Color(
  0xFF4A64FE,
); // Subtle Purple-Blue for contrast
const Color cardDarkColor = Color(0xFF1B1B25); // Card Background
const Color textLightColor = Colors.white; // Light text

class ServicesScreen extends StatefulWidget {
  final String userId;
  const ServicesScreen({super.key, this.userId = '1'});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  bool _loading = true;
  List<Job> _appliedJobs = [];
  List<Job> _recommendedJobs = [];

  @override
  void initState() {
    super.initState();
    _fetchJobs();
    // load profile for modal prefill
    JobService.fetchProfileData(widget.userId)
        .then((data) {
          debugPrint('Profile loaded for ServicesScreen');
          return null;
        })
        .catchError((e) {
          debugPrint('Profile load failed: $e');
          return null;
        });
  }

  Future<void> _fetchJobs() async {
    try {
      final data = await JobService.fetchHomeData(widget.userId);

      final recent = data['recent_jobs'] as List<Job>? ?? [];

      setState(() {
        // NOTE: Keeping your original logic to populate lists from API response
        _appliedJobs = [];
        _recommendedJobs = recent;
        _loading = false;
      });
    } catch (e) {
      debugPrint('Failed to load jobs for ServicesScreen: $e');
      setState(() {
        _appliedJobs = [];
        _recommendedJobs = [];
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryDarkColor, // Design change: Dark Background
      appBar: const CustomAppBar(
        title: 'My Jobs',
        showProfile: true,
        showBackButton: false,
        // Assuming CustomAppBar adapts for dark theme
      ),
      body: _loading
          // Design change: Neon loading indicator
          ? Center(child: CircularProgressIndicator(color: accentNeon))
          : SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ⭐️ APPLIED JOBS SECTION
                  _buildHeader(
                    "Applied Jobs",
                    "Keep track of your recent applications",
                  ),
                  _buildJobList(_appliedJobs, applied: true),

                  // --- Divider ---
                  const SizedBox(height: 24),
                  _buildSectionDivider(),

                  // ⭐️ RECOMMENDED JOBS SECTION
                  _buildHeader(
                    "Recommended Jobs",
                    "${_recommendedJobs.length} new opportunities for you",
                  ),
                  _buildFilterChips(),
                  _buildJobList(_recommendedJobs),
                ],
              ),
            ),
    );
  }

  // 1. 🔹 Header Text - Dark Theme Typography
  Widget _buildHeader(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: textLightColor, // Design change: Light text
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: Colors
                  .grey
                  .shade500, // Design change: Softer grey for subtitle
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // 2. 🔹 Filter Chips Row - Neon/Dark Interactive Look
  Widget _buildFilterChips() {
    final filters = [
      "Full Time",
      "Remote",
      "Part Time",
      "Recent",
      "Top Salary",
    ];
    // NOTE: Simulating selected filter for design visualization
    const selectedFilter = "Remote";

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final isSelected = filters[index] == selectedFilter;
          return Container(
            margin: const EdgeInsets.only(
              right: 10,
            ), // Increased margin slightly
            child: ActionChip(
              // Using ActionChip for better tap behavior
              label: Text(filters[index]),
              onPressed: () {
                // Add filter logic here
              },
              // Design change: Dark/Neon coloring
              backgroundColor: isSelected
                  ? secondaryAccent.withOpacity(0.2) // Subtle dark highlight
                  : cardDarkColor, // Dark background for unselected
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
                side: BorderSide(
                  // Neon border for selected, subtle grey for unselected
                  color: isSelected
                      ? accentNeon
                      : Colors.white.withOpacity(0.1),
                  width: 1.0,
                ),
              ),
              labelStyle: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                // Neon text for selected, light grey for unselected
                color: isSelected ? accentNeon : Colors.grey.shade300,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
            ),
          );
        },
      ),
    );
  }

  // 3. 🔹 Job Card List
  Widget _buildJobList(List<Job> jobs, {bool applied = false}) {
    if (jobs.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 30),
        child: Center(
          child: Text(
            applied
                ? "You haven't applied for any jobs yet."
                : "No recommended jobs right now.",
            style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: jobs.length,
      itemBuilder: (context, index) {
        final job = jobs[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Stack(
            children: [
              // JobCard already adapts to dark theme
              JobCard(
                title: job.title,
                company: job.company,
                location: job.location,
                salary: job.salary,
                type: job.type,
                logoText: job.logoText,
                experience: job.experience,
                isSaved: job.isSaved,
                onSaveTap: () async {
                  // optimistic update
                  final prev = job.isSaved;
                  setState(() => job.isSaved = !job.isSaved);
                  if (job.isSaved) {
                    final ok = await SavedJobService.addSaved(
                      widget.userId,
                      job.id,
                    );
                    if (!ok) setState(() => job.isSaved = prev);
                  } else {
                    final ok = await SavedJobService.removeSaved(
                      widget.userId,
                      job.id,
                    );
                    if (!ok) setState(() => job.isSaved = prev);
                  }
                },
                onApply: () async {
                  final profile = await JobService.fetchProfileData(
                    widget.userId,
                  );
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => JobApplicationModal(
                      job: job,
                      userData: profile['user'],
                      userId: widget.userId,
                    ),
                  );
                },
              ),
              // Status Badge for Applied Jobs - Dark/Neon Style
              if (applied)
                Positioned(
                  top: 15,
                  right: 15,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: accentNeon.withOpacity(
                        0.1,
                      ), // Neon background hint
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: accentNeon.withOpacity(
                          0.5,
                        ), // Stronger Neon border
                        width: 1.0,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          color: accentNeon, // Neon Icon
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "Applied",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: accentNeon, // Neon Text
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  // 4. 🔹 Divider Between Sections - Minimal and Subtle Dark
  Widget _buildSectionDivider() {
    return Container(
      height: 1.0,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white.withOpacity(0.1), // Design change: Subtle white line
    );
  }
}
