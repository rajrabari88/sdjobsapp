import 'package:flutter/material.dart';
// import '../widgets/custom_appbar.dart'; // Assuming CustomAppBar is adapted for dark theme

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

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // NOTE: CustomAppBar ko Dark Theme ke liye adjust kiya gaya hai.
      appBar: AppBar(
        title: const Text(
          'Notifications',
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
      body: _buildNotificationList(),
    );
  }

  Widget _buildNotificationList() {
    // Dummy list of notifications
    final notifications = [
      {
        'title': 'Interview Invitation! 🎉',
        'body':
            'You have been invited for an interview at Tech Innovators for the Senior UI/UX Designer role.',
        'icon': Icons.calendar_month,
        'color': Colors.green.shade400, // Adjusted for dark background
      },
      {
        'title': 'Application Status Update',
        'body':
            'Your application for Mobile App Developer at App Solutions Co. is now under review.',
        'icon': Icons.work,
        'color': accentNeon, // Using Neon Accent for key updates
      },
      {
        'title': 'New Job Alert',
        'body':
            '10 new Data Analyst jobs matching your preferences are available today.',
        'icon': Icons.search,
        'color': Colors.orange.shade400, // Adjusted for dark background
      },
      {
        'title': 'Rejected Application',
        'body':
            'Your application for Data Analyst at Global Data Inc. was unsuccessful. Keep trying!',
        'icon': Icons.cancel,
        'color': Colors.red.shade400, // Adjusted for dark background
      },
      {
        'title': 'Profile Complete',
        'body':
            'Your profile is 100% complete! Increase your visibility to employers.',
        'icon': Icons.person,
        'color': Colors.purple.shade400, // Adjusted for dark background
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.only(top: 10, bottom: 10),
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notif = notifications[index];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Container(
            decoration: BoxDecoration(
              color: cardDarkColor, // Dark background for the notification card
              borderRadius: BorderRadius.circular(15),
              // Subtle border matching the icon color for emphasis
              border: Border.all(color: notif['color'] as Color, width: 0.5),
              boxShadow: [
                BoxShadow(
                  color: (notif['color'] as Color).withOpacity(
                    0.15,
                  ), // Subtle color glow
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                vertical: 8,
                horizontal: 16,
              ),
              // Leading Icon in status color
              leading: Icon(
                notif['icon'] as IconData,
                color: notif['color'] as Color,
                size: 30,
              ),
              // Notification Title
              title: Text(
                notif['title'].toString(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: primaryTextColor, // White title
                ),
              ),
              // Notification Body/Message
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  notif['body'].toString(),
                  style: const TextStyle(
                    color: secondaryTextColor,
                  ), // Grey body text
                ),
              ),
              // Trailing arrow
              trailing: const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: secondaryTextColor,
              ),
              onTap: () {
                // Handle notification tap
              },
            ),
          ),
        );
      },
    );
  }
}
