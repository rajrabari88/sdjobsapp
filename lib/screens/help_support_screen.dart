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

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // NOTE: CustomAppBar ko Dark Theme ke liye adjust kiya gaya hai.
      appBar: AppBar(
        title: const Text(
          'Help & Support',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Frequently Asked Questions'),
            _buildFaqSection(),
            const SizedBox(height: 25),
            _buildSectionHeader('Contact Us'),
            _buildContactSection(context),
          ],
        ),
      ),
    );
  }

  // Helper for Section Titles
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: accentNeon, // Neon accent for section headers
        ),
      ),
    );
  }

  // --- FAQ Section (Using ExpansionTile) ---
  Widget _buildFaqSection() {
    final faqItems = [
      {
        'q': 'How do I upload my resume?',
        'a':
            'You can upload your resume in the "Resume & Documents" section under My Profile.',
      },
      {
        'q': 'How long does it take to hear back from an application?',
        'a':
            'Response times vary by employer, but you can track the status in "My Applications".',
      },
      {
        'q': 'Can I edit my job application after submitting?',
        'a':
            'Generally, applications cannot be edited after submission. Please ensure all details are correct.',
      },
    ];

    return Container(
      decoration: BoxDecoration(
        color: cardDarkColor, // Dark background for the card
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: subtleGrey, width: 0.5), // Subtle border
      ),
      child: Column(
        children: faqItems.map((item) {
          return Theme(
            data: ThemeData(
              unselectedWidgetColor:
                  secondaryTextColor, // Arrow color when collapsed
              dividerColor: subtleGrey, // Divider color inside the list
            ),
            child: ExpansionTile(
              iconColor: accentNeon, // Arrow color when expanded
              collapsedIconColor: secondaryTextColor,
              title: Text(
                item['q']!,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  color: primaryTextColor, // White question text
                ),
              ),
              childrenPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    item['a']!,
                    style: const TextStyle(
                      color: secondaryTextColor,
                    ), // Grey answer text
                  ),
                ),
                const SizedBox(height: 10), // Spacing after the answer
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // --- Contact Us Section ---
  Widget _buildContactSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardDarkColor, // Dark background for the card
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: subtleGrey, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildContactTile(Icons.email, 'Email Support', 'support@jobapp.com'),
          const Divider(color: subtleGrey), // Dark theme divider
          _buildContactTile(Icons.phone, 'Call Us', '+1 (800) 555-0199'),
          const Divider(color: subtleGrey),
          const SizedBox(height: 10),
          // Live Chat Button (Neon Accent)
          ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Opening live chat... (Dummy action)'),
                ),
              );
            },
            icon: const Icon(
              Icons.chat_bubble_outline,
              color: primaryDarkColor,
            ),
            label: const Text('Start Live Chat'),
            style: ElevatedButton.styleFrom(
              backgroundColor: accentNeon, // Neon Accent for the button
              foregroundColor:
                  primaryDarkColor, // Dark text/icon on Neon button
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              shadowColor: accentNeon.withOpacity(0.6), // Subtle glow
              elevation: 8,
            ),
          ),
        ],
      ),
    );
  }

  // Helper for Contact Tiles
  Widget _buildContactTile(IconData icon, String title, String subtitle) {
    return ListTile(
      leading: Icon(icon, color: accentNeon), // Neon icon
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          color: primaryTextColor,
        ),
      ), // White title
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: secondaryTextColor),
      ), // Grey subtitle
      onTap: () {
        // Implement action like launching email or dialer
      },
    );
  }
}
