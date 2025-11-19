import 'package:flutter/material.dart';
// import '../widgets/custom_appbar.dart'; // Assuming CustomAppBar supports dark theme

// --- DARK THEME CONSTANTS (Consistency) ---
const Color primaryDarkColor = Color(
  0xFF0D0D12,
); // Deep Navy/Near Black Background
const Color accentNeon = Color(0xFF00FFFF); // Neon Cyan/Blue for highlights
const Color primaryTextColor = Colors.white; // Light text for titles
const Color secondaryTextColor = Color(
  0xFFAAAAAA,
); // Light Grey text for subtitles/details
const Color cardDarkColor = Color(
  0xFF1B1B25,
); // Card Background / Input Field Fill
const Color subtleGrey = Color(0xFF424242); // Used for subtle borders

class ApplicationsScreen extends StatelessWidget {
  const ApplicationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // NOTE: CustomAppBar ko Dark Theme ke liye adjust kiya gaya hai.
      appBar: AppBar(
        title: const Text(
          'My Applications',
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
      backgroundColor: primaryDarkColor, // Deep dark background
      body: _buildApplicationList(),
    );
  }

  Widget _buildApplicationList() {
    // Dummy list of applications
    final applications = [
      {
        'title': 'Senior UI/UX Designer',
        'company': 'Tech Innovators',
        'status': 'Interview Scheduled',
        'color': Colors.green.shade400, // Adjusted for dark background
      },
      {
        'title': 'Mobile App Developer (Flutter)',
        'company': 'App Solutions Co.',
        'status': 'Application Sent',
        'color': accentNeon.withOpacity(0.8), // Using Neon Accent
      },
      {
        'title': 'Data Analyst',
        'company': 'Global Data Inc.',
        'status': 'Rejected',
        'color': Colors.red.shade400, // Adjusted for dark background
      },
      {
        'title': 'Product Manager',
        'company': 'E-Commerce Giants',
        'status': 'Under Review',
        'color': Colors.orange.shade400, // Adjusted for dark background
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: applications.length,
      itemBuilder: (context, index) {
        final app = applications[index];
        return Card(
          color: cardDarkColor, // Dark Card background
          elevation: 4,
          margin: const EdgeInsets.only(bottom: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            // Subtle neon border for emphasis
            side: BorderSide(color: app['color'] as Color, width: 0.5),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              vertical: 8,
              horizontal: 16,
            ),
            // Leading Icon for job type/status
            leading: Icon(
              Icons.business_center,
              color: app['color'] as Color,
              size: 30,
            ),

            // Job Title
            title: Text(
              app['title'].toString(),
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: primaryTextColor,
              ),
            ),

            // Company and Status
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                // Company Name
                Text(
                  app['company'].toString(),
                  style: const TextStyle(
                    color: secondaryTextColor,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 6),
                // Status Indicator
                Row(
                  children: [
                    Icon(Icons.circle, size: 8, color: app['color'] as Color),
                    const SizedBox(width: 8),
                    Text(
                      app['status'].toString(),
                      style: TextStyle(
                        color: app['color'] as Color, // Status color
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            // Trailing arrow
            trailing: const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: secondaryTextColor,
            ),
            onTap: () {
              // Handle tap to view application details
            },
          ),
        );
      },
    );
  }
}
