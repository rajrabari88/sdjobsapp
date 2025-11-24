import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/job.dart';
import '../services/job_service.dart';
import '../services/saved_job_service.dart';
import '../widgets/job_application_modal.dart';
import '../widgets/custom_appbar.dart';
import '../widgets/search_bar.dart';
import '../widgets/job_card.dart';
import '../utils/responsive.dart';

// --- DARK THEME CONSTANTS ---
const Color primaryDarkColor = Color(0xFF0D0D12);
const Color accentNeon = Color(0xFF00FFFF);
const Color secondaryAccent = Color(0xFF4A64FE);
const Color cardDarkColor = Color(0xFF1B1B25);
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
  List<String> _popularCategories = const [
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

    JobService.fetchProfileData(widget.userId).then((data) {
      setState(() => userData = data['user']);
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

    _debounce = Timer(const Duration(milliseconds: 350), () {
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
    _recentSearches.remove(query);
    _recentSearches.insert(0, query);

    if (_recentSearches.length > 10) {
      _recentSearches = _recentSearches.sublist(0, 10);
    }

    await prefs.setStringList('recentSearches', _recentSearches);
  }

  Future<void> _performSearch(String query) async {
    setState(() => _loading = true);
    await _saveRecentSearch(query);

    try {
      final results = await JobService.searchJobs(query, widget.userId);
      setState(() => _filteredJobs = results);
    } catch (e) {
      setState(() => _filteredJobs = []);
    } finally {
      setState(() => _loading = false);
    }
  }

  void _handleCategoryTap(String category) {
    _controller.text = category;
    _onSearchChanged();
  }

  void _showJobApplicationModal(Job job) {
    if (userData == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => JobApplicationModal(
        job: job,
        userData: userData!,
        userId: widget.userId,
      ),
    );
  }

  void _toggleSave(Job job) {
    final prev = job.isSaved;
    setState(() => job.isSaved = !job.isSaved);

    if (job.isSaved) {
      SavedJobService.addSaved(widget.userId, job.id).then((ok) {
        if (!ok) setState(() => job.isSaved = prev);
      });
    } else {
      SavedJobService.removeSaved(widget.userId, job.id).then((ok) {
        if (!ok) setState(() => job.isSaved = prev);
      });
    }
  }

  // ---------------- UI ----------------

  @override
  Widget build(BuildContext context) {
    final isWide = Responsive.isLarge(context);
    final padding = Responsive.contentPadding(context);

    Widget bodyContent;
    if (_controller.text.isEmpty) {
      bodyContent = _buildInitialUI();
    } else if (_loading) {
      bodyContent = Center(child: CircularProgressIndicator(color: accentNeon));
    } else {
      bodyContent = _buildSearchResults();
    }

    return Scaffold(
      backgroundColor: primaryDarkColor,
      appBar: const CustomAppBar(title: "Find Your Job"),
      body: Padding(
        padding: padding,
        child: Column(
          children: [
            SizedBox(height: 12),
            CustomSearchBar(
              controller: _controller,
              hint: "Search jobs, company, skills...",
              onChanged: (_) {},
              onFilterTap: () {},
            ),
            const SizedBox(height: 10),

            // FOLDABLE SUPPORT: 2-COLUMN LAYOUT
            Expanded(
              child: isWide
                  ? AdaptiveTwoColumn(
                      left: bodyContent,
                      right: _buildSuggestionsSidebar(),
                    )
                  : bodyContent,
            ),
          ],
        ),
      ),
    );
  }

  // LEFT SIDE for foldable (main content)
  Widget _buildInitialUI() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle("Popular Categories 🚀"),
          const SizedBox(height: 10),
          _buildCategoryChips(),
          const SizedBox(height: 30),
          _buildSectionTitle("Recent Searches"),
          _buildRecentSearchesList(),
        ],
      ),
    );
  }

  // RIGHT SIDE for foldable (extra suggestions)
  Widget _buildSuggestionsSidebar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Top Picks For You"),
        const SizedBox(height: 12),
        _filteredJobs.isNotEmpty
            ? Text(
                "Showing ${_filteredJobs.length} matches",
                style: TextStyle(color: Colors.grey.shade400),
              )
            : const Text(
                "Try searching for a role...",
                style: TextStyle(color: Colors.grey),
              ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: Responsive.fontSize(context, 18),
        color: textLightColor,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildCategoryChips() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _popularCategories.map((category) {
        return ActionChip(
          label: Text(
            category,
            style: TextStyle(
              fontSize: Responsive.fontSize(context, 14),
              color: textLightColor,
            ),
          ),
          avatar: Icon(
            Icons.flash_on_rounded,
            size: Responsive.isLarge(context) ? 20 : 16,
            color: accentNeon,
          ),
          onPressed: () => _handleCategoryTap(category),
          backgroundColor: secondaryAccent.withOpacity(0.15),
          side: BorderSide(color: secondaryAccent.withOpacity(0.5), width: 1),
        );
      }).toList(),
    );
  }

  Widget _buildRecentSearchesList() {
    return Column(
      children: _recentSearches.map((search) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Material(
            color: cardDarkColor,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => _handleCategoryTap(search),
              child: ListTile(
                leading: Icon(
                  Icons.history,
                  color: Colors.grey.shade500,
                  size: Responsive.isLarge(context) ? 26 : 22,
                ),
                title: Text(
                  search,
                  style: TextStyle(
                    fontSize: Responsive.fontSize(context, 14),
                    color: textLightColor,
                  ),
                ),
                trailing: Icon(
                  Icons.north_west_rounded,
                  color: accentNeon,
                  size: Responsive.isLarge(context) ? 24 : 20,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSearchResults() {
    if (_filteredJobs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.sentiment_dissatisfied,
              size: Responsive.isLarge(context) ? 120 : 80,
              color: secondaryAccent.withOpacity(0.4),
            ),
            const SizedBox(height: 10),
            Text(
              "No results found",
              style: TextStyle(
                fontSize: Responsive.fontSize(context, 20),
                color: textLightColor,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _filteredJobs.length,
      padding: const EdgeInsets.only(bottom: 10),
      itemBuilder: (context, index) {
        final job = _filteredJobs[index];

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
