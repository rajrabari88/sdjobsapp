import 'package:flutter/material.dart';
import '../services/job_service.dart';
import '../services/saved_job_service.dart';
import '../models/job.dart';
import '../widgets/custom_appbar.dart';
import '../widgets/search_bar.dart';
import '../widgets/job_card.dart';
import '../widgets/job_application_modal.dart';

// --- NEW DARK THEME CONSTANTS ---
const Color primaryDarkColor = Color(
  0xFF0D0D12,
); // Deep Navy/Near Black Background
const Color accentNeon = Color(0xFF00FFFF); // Neon Cyan/Blue for highlights
const Color secondaryAccent = Color(
  0xFF4A64FE,
); // A subtle purple-blue for contrast
const Color cardDarkColor = Color(
  0xFF1B1B25,
); // Slightly lighter dark background for cards
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
  List<dynamic> categories = [];
  List<Job> recentJobs = [];

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchHomeData();
  }

  Future<void> fetchHomeData() async {
    try {
      final data = await JobService.fetchHomeData(widget.userId);
      setState(() {
        userData = data['user'];
        featuredJobs = (data['featured_jobs'] as List<dynamic>)
            .map((item) => item as Job)
            .toList();
        categories = data['categories'];
        recentJobs = (data['recent_jobs'] as List<dynamic>)
            .map((item) => item as Job)
            .toList();
        loading = false;
      });
    } catch (e) {
      debugPrint("Error fetching data: $e");
      setState(() => loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load data in dark mode.')),
        );
      }
    }
  }

  void toggleSave(Job job) {
    final previous = job.isSaved;
    setState(() => job.isSaved = !job.isSaved);

    // Persist change to backend
    if (job.isSaved) {
      // try to add
      SavedJobService.addSaved(widget.userId, job.id).then((ok) {
        if (!ok) {
          // revert
          setState(() => job.isSaved = previous);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Failed to save job.')));
        }
      });
    } else {
      // try to remove
      SavedJobService.removeSaved(widget.userId, job.id).then((ok) {
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
      if (result == true) {
        // Application submitted successfully
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
        showProfile: true,
        // Assuming CustomAppBar adapts to dark theme
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            _buildWelcomeCard(),
            const SizedBox(height: 24),
            // Assuming CustomSearchBar is updated for dark theme
            CustomSearchBar(
              controller: _searchController,
              hint: 'Search jobs...',
              onFilterTap: () {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Filter opened')));
              },
            ),
            const SizedBox(height: 30),

            // --- Featured Jobs Section (Horizontal Scroll) ---
            if (featuredJobs.isNotEmpty) ...[
              _buildSectionHeader('🚀 Featured Opportunities'),
              const SizedBox(height: 15),
              SizedBox(
                height: 260,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.only(left: 16),
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
              const SizedBox(height: 30),
            ],

            // --- Job Categories Section (Chips) ---
            if (categories.isNotEmpty) ...[
              _buildSectionHeader('Explore Job Categories'),
              const SizedBox(height: 15),
              _buildCategoryChips(),
              const SizedBox(height: 30),
            ],

            // --- Recently Added Jobs Section (Vertical List) ---
            if (recentJobs.isNotEmpty) ...[
              _buildSectionHeader('Latest Listings'),
              const SizedBox(height: 15),
              _buildRecentJobsList(),
            ],

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: cardDarkColor, // Dark card background
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 1.5,
          ), // Subtle light border
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, ${userData?['name'] ?? 'Job Seeker'}!',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 22,
                color: textLightColor, // Light text color
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Your next career move is waiting.',
              style: TextStyle(color: Colors.grey.shade400, fontSize: 15),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.location_on_rounded,
                  color: accentNeon,
                  size: 20,
                ), // Neon icon
                const SizedBox(width: 8),
                Text(
                  userData?['location'] != null
                      ? 'Targeting ${userData!['location']}'
                      : 'Location preference not set',
                  style: TextStyle(color: Colors.grey.shade300, fontSize: 14),
                ),
              ],
            ),
          ],
        ),
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
          color: textLightColor, // Light text
        ),
      ),
    );
  }

  Widget _buildCategoryChips() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: ActionChip(
              // Using ActionChip for a better interactive look
              label: Text(category),
              backgroundColor: secondaryAccent.withOpacity(
                0.1,
              ), // Subtle dark background
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: secondaryAccent.withOpacity(0.5),
                ), // Neon border
              ),
              labelStyle: const TextStyle(
                color: secondaryAccent, // Primary color text
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              onPressed: () {},
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecentJobsList() {
    // Note: If JobCard is also updated to be dark, this will look great.
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

// --- Featured Job Card (Neon Dark Design) ---
class _FeaturedJobCard extends StatelessWidget {
  final Job job;
  final VoidCallback? onApply;
  final VoidCallback? onSaveTap;

  const _FeaturedJobCard({required this.job, this.onApply, this.onSaveTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        // High-contrast, futuristic look using a subtle dark gradient
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
            color: accentNeon.withOpacity(0.15), // Neon glow effect
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () {
            /* Handle job tap */
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo + Bookmark
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor:
                          secondaryAccent, // Accent color for logo background
                      child: Text(
                        job.logoText,
                        style: const TextStyle(
                          color: textLightColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: onSaveTap ?? () => {},
                      child: Icon(
                        job.isSaved
                            ? Icons.bookmark_rounded
                            : Icons.bookmark_border_rounded,
                        color: job.isSaved ? accentNeon : Colors.grey.shade600,
                        size: 28,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  job.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: textLightColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${job.company} • ${job.location}',
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      job.salary,
                      style: const TextStyle(
                        color: accentNeon, // Highlight salary in neon
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
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
