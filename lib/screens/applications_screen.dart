import 'package:flutter/material.dart';
import '../services/application_service.dart';
import '../models/application_model.dart';

const Color primaryDarkColor = Color(0xFF0D0D12);
const Color accentNeon = Color(0xFF00FFFF);
const Color primaryTextColor = Colors.white;
const Color secondaryTextColor = Color(0xFF9BA1A6);
const Color cardDarkColor = Color(0xFF15151E);

class ApplicationsScreen extends StatefulWidget {
  final int userId;

  const ApplicationsScreen({super.key, required this.userId});

  @override
  State<ApplicationsScreen> createState() => _ApplicationsScreenState();
}

class _ApplicationsScreenState extends State<ApplicationsScreen> {
  late Future<List<ApplicationModel>> futureApplications;

  @override
  void initState() {
    super.initState();
    futureApplications = ApplicationService().getApplications(widget.userId);
  }

  void _showStatusPopup(String status) {
    String message = "";

    switch (status.toLowerCase()) {
      case 'approved':
        message = "🎉 Your job application has been approved!";
        break;
      case 'interview':
        message =
            "📞 Your interview has been scheduled. We will contact you soon!";
        break;
      case 'rejected':
        message = "❌ Sorry, your application was not selected.";
        break;
      default:
        message = "⌛ Your application is under review.";
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: cardDarkColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.info_outline, color: accentNeon, size: 40),
              const SizedBox(height: 12),
              Text(
                status.toUpperCase(),
                style: const TextStyle(
                  color: accentNeon,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: primaryTextColor,
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 18),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentNeon,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text("Okay"),
              ),
            ],
          ),
        );
      },
    );
  }

  // Modern status color
  LinearGradient _getStatusGradient(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
      case 'interview':
        return const LinearGradient(
          colors: [Color(0xFF00FFB2), Color(0xFF00FFA0)],
        );
      case 'rejected':
        return const LinearGradient(
          colors: [Color(0xFFFF5A5A), Color(0xFFFF3B3B)],
        );
      default:
        return const LinearGradient(colors: [accentNeon, Color(0xFF00D6D6)]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryDarkColor,
      appBar: AppBar(
        backgroundColor: primaryDarkColor,
        elevation: 0,
        title: const Text(
          "My Applications",
          style: TextStyle(
            color: primaryTextColor,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios, color: primaryTextColor),
        ),
      ),
      body: FutureBuilder<List<ApplicationModel>>(
        future: futureApplications,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: accentNeon),
            );
          }

          final apps = snapshot.data!;
          if (apps.isEmpty) {
            return const Center(
              child: Text(
                "No applications found",
                style: TextStyle(color: secondaryTextColor),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: apps.length,
            itemBuilder: (context, index) {
              final app = apps[index];
              final gradient = _getStatusGradient(app.status);

              return Container(
                margin: const EdgeInsets.only(bottom: 18),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: cardDarkColor.withOpacity(0.45),
                  border: Border.all(color: accentNeon.withOpacity(0.2)),
                  boxShadow: [
                    BoxShadow(
                      color: accentNeon.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () {
                    _showStatusPopup(app.status);
                  },

                  child: Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Row(
                      children: [
                        // Icon Box
                        Container(
                          height: 48,
                          width: 48,
                          decoration: BoxDecoration(
                            gradient: gradient,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.business_center,
                            color: Colors.black,
                            size: 26,
                          ),
                        ),

                        const SizedBox(width: 16),

                        // Job Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                app.title,
                                style: const TextStyle(
                                  color: primaryTextColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                app.company,
                                style: const TextStyle(
                                  color: secondaryTextColor,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 10),

                              // Status tag
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  gradient: gradient,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  app.status.toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const Icon(
                          Icons.arrow_forward_ios,
                          size: 18,
                          color: secondaryTextColor,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
