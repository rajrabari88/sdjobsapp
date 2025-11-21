import 'dart:async';

import 'package:flutter/material.dart';
import '../models/job.dart';
import '../services/job_service.dart';
import '../services/saved_job_service.dart';
import '../widgets/job_application_modal.dart';
import '../widgets/custom_appbar.dart';
import '../widgets/search_bar.dart';
import '../widgets/job_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

// --- DARK THEME CONSTANTS (Consistency is key!) ---
const Color primaryDarkColor = Color(
  0xFF0D0D12,
); // Deep Navy/Near Black Background
const Color accentNeon = Color(0xFF00FFFF); // Neon Cyan/Blue for highlights
const Color secondaryAccent = Color(
  0xFF4A64FE,
); // Subtle Purple-Blue for contrast
const Color cardDarkColor = Color(0xFF1B1B25); // Card Background
const Color textLightColor = Colors.white;

class SearchScreen extends StatefulWidget {
  final String userId;
  const SearchScreen({super.key, required this.userId});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Job> _allJobs = [];
  Map<String, dynamic>? userData;

  final List<String> _popularCategories = const [
    'Flutter',
    'Manager',
    'Design',
    'DevOps',
    'Marketing',
    'Finance',
    'Sales',
  ];

  List<String> _recentSearches = [];

  List<Job> _filteredJobs = [];
  bool _loading = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _filteredJobs = List.from(_allJobs);
    _controller.addListener(_onSearchChanged);
    _loadRecentSearches();
    JobService.fetchProfileData(widget.userId)
        .then((data) {
          setState(() {
            userData = data['user'];
          });
        })
        .catchError((e) {
          debugPrint('Failed to load profile in SearchScreen: $e');
        });
  }

  @override
  void dispose() {
    _controller.removeListener(_onSearchChanged);
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _controller.text.trim();

    _debounce?.cancel();
    if (query.isEmpty) {
      setState(() {
        _filteredJobs = [];
        _loading = false;
      });
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 400), () {
      _performSearch(query);
    });
  }

  Future<void> _loadRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _recentSearches = prefs.getStringList('recentSearches') ?? [];
    });
  }

  Future<void> _saveRecentSearch(String query) async {
    final prefs = await SharedPreferences.getInstance();

    // Duplicate remove & latest item upar add
    _recentSearches.remove(query);
    _recentSearches.insert(0, query);

    // Sirf last 10 searches store karna
    if (_recentSearches.length > 10) {
      _recentSearches = _recentSearches.sublist(0, 10);
    }

    await prefs.setStringList('recentSearches', _recentSearches);
  }

  Future<void> _performSearch(String query) async {
    setState(() {
      _loading = true;
    });

    // 🔥 ADD THIS — Save search history dynamically
    await _saveRecentSearch(query);

    try {
      final results = await JobService.searchJobs(query, widget.userId);

      setState(() {
        _filteredJobs = results;
      });
    } catch (e) {
      debugPrint('Search error: $e');
      setState(() {
        _filteredJobs = [];
      });
    } finally {
      setState(() => _loading = false);
    }
  }

  void _handleCategoryTap(String category) {
    _controller.text = category;
    _onSearchChanged();
  }

  void _showJobApplicationModal(Job job) {
    if (userData == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('User data not loaded.')));
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => JobApplicationModal(
        job: job,
        userData: userData!,
        userId: widget.userId,
      ),
    ).then((result) {
      if (result == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Application submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    });
  }

  void _toggleSave(Job job) {
    final previous = job.isSaved;
    setState(() => job.isSaved = !job.isSaved);

    if (job.isSaved) {
      SavedJobService.addSaved(widget.userId, job.id).then((ok) {
        if (!ok) {
          setState(() => job.isSaved = previous);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Failed to save job.')));
        }
      });
    } else {
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

  // --- BUILD METHOD (DESIGN CHANGES APPLIED) ---
  @override
  Widget build(BuildContext context) {
    Widget bodyContent;
    if (_controller.text.isEmpty) {
      bodyContent = _buildInitialSearchBody();
    } else if (_loading) {
      // Dark Theme Loading
      bodyContent = Center(child: CircularProgressIndicator(color: accentNeon));
    } else {
      bodyContent = _buildSearchResultsBody();
    }

    return Scaffold(
      backgroundColor: primaryDarkColor, // Dark Background
      appBar: const CustomAppBar(
        title: 'Find Your Job',
        // Assuming CustomAppBar adapts title color to white
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: CustomSearchBar(
              controller: _controller,
              hint: 'Search jobs by title, company, or skill...',
              // Assuming CustomSearchBar is styled for dark theme
              onChanged: (_) {},
              onFilterTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  // Neon SnackBar
                  SnackBar(
                    content: Text(
                      'Opening advanced filters...',
                      style: TextStyle(color: primaryDarkColor),
                    ),
                    backgroundColor: const Color.fromARGB(255, 158, 194, 110),
                  ),
                );
              },
            ),
          ),
          Expanded(child: bodyContent),
        ],
      ),
    );
  }

  // --- INITIAL SEARCH BODY (CATEGORIES & RECENT) ---
  Widget _buildInitialSearchBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Popular Categories 🚀'),
          const SizedBox(height: 15),
          _buildCategoryChips(),
          const SizedBox(height: 30),
          _buildSectionTitle('Recent Searches'),
          _buildRecentSearchesList(),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textLightColor, // White text
      ),
    );
  }

  Widget _buildCategoryChips() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _popularCategories
          .map(
            (category) => ActionChip(
              label: Text(category),
              // Neon icon
              avatar: Icon(Icons.flash_on_rounded, size: 16, color: accentNeon),
              onPressed: () => _handleCategoryTap(category),
              // Subtle dark background with accent border
              backgroundColor: secondaryAccent.withOpacity(0.15),
              side: BorderSide(
                color: secondaryAccent.withOpacity(0.5),
                width: 1,
              ),
              labelStyle: const TextStyle(
                color: textLightColor, // Light text color
                fontWeight: FontWeight.w500,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildRecentSearchesList() {
    return Column(
      children: _recentSearches
          .map(
            (search) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Material(
                color: cardDarkColor, // Dark card material
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => _handleCategoryTap(search),
                  child: ListTile(
                    leading: Icon(Icons.history, color: Colors.grey.shade600),
                    title: Text(
                      search,
                      style: const TextStyle(
                        color: textLightColor, // Light text
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: Icon(
                      Icons.north_west_rounded, // Modern, neon icon
                      size: 20,
                      color: accentNeon,
                    ),
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  // --- SEARCH RESULTS BODY ---
  Widget _buildSearchResultsBody() {
    if (_filteredJobs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.sentiment_dissatisfied_rounded,
              size: 80,
              color: secondaryAccent.withOpacity(0.5), // Soft accent color
            ),
            const SizedBox(height: 15),
            const Text(
              'No results found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textLightColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try a different keyword or check your spelling.',
              style: TextStyle(color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      itemCount: _filteredJobs.length,
      itemBuilder: (context, index) {
        final Job job = _filteredJobs[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: JobCard(
            title: job.title,
            company: job.company,
            location: job.location,
            salary: job.salary,
            type: job.type,
            logoText: job.logoText,
            experience: job.experience,
            isSaved: job.isSaved,
            onSaveTap: () => _toggleSave(job),
            onApply: () => _showJobApplicationModal(job),
          ),
        );
      },
    );
  }
}
