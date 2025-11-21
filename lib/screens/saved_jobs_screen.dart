import 'package:flutter/material.dart';
import '../services/saved_job_service.dart';
import '../widgets/job_card.dart';
import '../models/job.dart';
import '../widgets/job_application_modal.dart';

const Color primaryDarkColor = Color(0xFF0D0D12);
const Color accentNeon = Color(0xFF00FFFF);
const Color secondaryTextColor = Color(0xFFAAAAAA);
const Color primaryTextColor = Colors.white;

class SavedJobsScreen extends StatefulWidget {
  final String userId;
  final Map<String, dynamic> userData;

  const SavedJobsScreen({
    super.key,
    required this.userId,
    required this.userData,
  });

  @override
  State<SavedJobsScreen> createState() => _SavedJobsScreenState();
}

class _SavedJobsScreenState extends State<SavedJobsScreen> {
  late Future<List<dynamic>> _savedJobsFuture;

  @override
  void initState() {
    super.initState();
    _savedJobsFuture = SavedJobService.getSavedJobs(widget.userId);
  }

  void _refresh() {
    setState(() {
      _savedJobsFuture = SavedJobService.getSavedJobs(widget.userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Saved Jobs",
          style: TextStyle(
            color: primaryTextColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: primaryDarkColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: primaryTextColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: primaryDarkColor,
      body: FutureBuilder(
        future: _savedJobsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: accentNeon),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                "No Saved Jobs Yet",
                style: TextStyle(color: secondaryTextColor, fontSize: 16),
              ),
            );
          }

          final jobs = (snapshot.data as List)
              .map((j) => Job.fromJson(j))
              .toList();

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: jobs.length,
            itemBuilder: (context, index) {
              final job = jobs[index];

              return JobCard(
                title: job.title,
                company: job.company,
                location: job.location,
                salary: job.salary,
                type: job.type,
                logoText: job.logoText,
                experience: job.experience,
                isSaved: true,

                // ⭐ APPLY BUTTON ENABLED
                onApply: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => JobApplicationModal(
                      job: job,
                      userData: widget.userData,
                      userId: widget.userId,
                    ),
                  );
                },

                // ⭐ REMOVE SAVED JOB
                onSaveTap: () async {
                  final removed = await SavedJobService.removeSaved(
                    widget.userId,
                    job.id,
                  );
                  if (removed) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("${job.title} removed")),
                    );
                    _refresh();
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}
