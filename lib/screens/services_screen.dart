import 'package:flutter/material.dart';
import '../models/job.dart';
import '../services/job_service.dart';
import '../widgets/custom_appbar.dart';
import '../widgets/job_card.dart';
import '../services/saved_job_service.dart';
import '../widgets/job_application_modal.dart';

// --- DARK THEME CONSTANTS ---
const Color primaryDarkColor = Color(0xFF0D0D12);
const Color accentNeon = Color(0xFF00FFFF);
const Color secondaryAccent = Color(0xFF4A64FE);
const Color cardDarkColor = Color(0xFF1B1B25);
const Color textLightColor = Colors.white;

class ServicesScreen extends StatefulWidget {
  final String userId;
  const ServicesScreen({super.key, this.userId = '1'});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  bool _loading = true;

  // JOB LISTS
  List<Job> _recommendedJobs = [];
  List<Job> _filteredJobs = [];

  // FILTER STATE
  String selectedFilter = "Remote";

  @override
  void initState() {
    super.initState();
    _fetchJobs();

    JobService.fetchProfileData(widget.userId)
        .then((_) => debugPrint("Profile loaded for ServicesScreen"))
        .catchError((e) => debugPrint("Profile load failed: $e"));
  }

  Future<void> _fetchJobs() async {
    try {
      final data = await JobService.fetchHomeData(widget.userId);
      final recent = data['recent_jobs'] as List<Job>? ?? [];

      setState(() {
        _recommendedJobs = recent;
        _filteredJobs = recent; // default visible list
        _loading = false;
      });
    } catch (e) {
      debugPrint('Failed to load jobs: $e');
      setState(() {
        _recommendedJobs = [];
        _filteredJobs = [];
        _loading = false;
      });
    }
  }

  // FILTER LOGIC
  void applyFilter(String filter) {
    setState(() {
      selectedFilter = filter;

      if (filter == "Full Time") {
        _filteredJobs = _recommendedJobs
            .where((job) => job.type.contains("Full"))
            .toList();
      } else if (filter == "Part Time") {
        _filteredJobs = _recommendedJobs
            .where((job) => job.type.contains("Part"))
            .toList();
      } else if (filter == "Remote") {
        _filteredJobs = _recommendedJobs
            .where((job) => job.location.contains("Remote"))
            .toList();
      } else if (filter == "Top Salary") {
        _filteredJobs = List.from(_recommendedJobs)
          ..sort((a, b) => b.salary.compareTo(a.salary));
      } else if (filter == "Recent") {
        _filteredJobs = List.from(_recommendedJobs);
      } else {
        _filteredJobs = List.from(_recommendedJobs);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryDarkColor,
      appBar: const CustomAppBar(title: "Discover Jobs", showBackButton: false),
      body: _loading
          ? Center(child: CircularProgressIndicator(color: accentNeon))
          : SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  _buildFilterChips(),
                  _buildJobList(_filteredJobs),
                ],
              ),
            ),
    );
  }

  // HEADER
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Recommended for You",
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: textLightColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "${_recommendedJobs.length} opportunities based on your profile",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade400,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // FILTER CHIPS
  Widget _buildFilterChips() {
    final filters = [
      "Full Time",
      "Remote",
      "Part Time",
      "Recent",
      "Top Salary",
    ];

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      height: 42,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filters.length,
        itemBuilder: (context, i) {
          final isSelected = filters[i] == selectedFilter;

          return GestureDetector(
            onTap: () => applyFilter(filters[i]),
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? accentNeon.withOpacity(0.15)
                    : Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: isSelected
                      ? accentNeon
                      : Colors.white.withOpacity(0.15),
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: accentNeon.withOpacity(0.3),
                          blurRadius: 10,
                        ),
                      ]
                    : [],
              ),
              child: Text(
                filters[i],
                style: TextStyle(
                  color: isSelected ? accentNeon : Colors.white70,
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // JOB LIST
  Widget _buildJobList(List<Job> jobs) {
    if (jobs.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: Text(
            "No jobs found for selected filter.",
            style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
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
          padding: const EdgeInsets.only(bottom: 18),
          child: JobCard(
            title: job.title,
            company: job.company,
            location: job.location,
            salary: job.salary,
            type: job.type,
            logoText: job.logoText,
            experience: job.experience,
            isSaved: job.isSaved,
            onSaveTap: () async {
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
              final profile = await JobService.fetchProfileData(widget.userId);

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
        );
      },
    );
  }
}
