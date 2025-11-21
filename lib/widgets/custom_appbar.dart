import 'package:flutter/material.dart';

// --- DARK THEME CONSTANTS ---
const Color accentNeon = Color(0xFF00FFFF);
const Color textLightColor = Colors.white;
const Color appBarBgColor = Colors.transparent; // Transparent for modern look

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool showBackButton;
  final String? title;

  const CustomAppBar({super.key, this.showBackButton = false, this.title});

  // SDJOBS Header - Bolder, Larger, and Modern Look
  Widget _buildLogo() {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0), // थोड़ा बाएँ पैडिंग
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight
                .w800, // Slightly less bold than w900 for a cleaner look
            fontSize: 32, // 🔥 SDJobs को बड़ा कर दिया
            letterSpacing: 0.8, // थोड़ा ज़्यादा स्पेसिंग
            height: 1.0, // Line height
          ),
          children: [
            TextSpan(
              text: 'SD',
              style: TextStyle(
                color: accentNeon,
                shadows: [
                  // Neon Glow Effect
                  Shadow(
                    color: accentNeon.withOpacity(0.5),
                    blurRadius: 10.0,
                    offset: const Offset(0, 0),
                  ),
                ],
              ),
            ),
            TextSpan(
              text: 'Jobs',
              style: TextStyle(color: textLightColor),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: appBarBgColor, // Transparent
      elevation: 0, // No shadow for a flat, modern design
      centerTitle: false, // Title aligned to the start
      automaticallyImplyLeading: false,

      leading: showBackButton
          ? IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: accentNeon, // Neon color for back button
                size: 26, // Bigger icon
              ),
              onPressed: () => Navigator.pop(context),
            )
          : null,

      title:
          title != null &&
              showBackButton // अगर title दिया है और back button दिख रहा है
          ? Text(
              // Custom title display
              title!,
              style: TextStyle(
                color: textLightColor,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            )
          : _buildLogo(), // अगर title नहीं है या back button नहीं है, तो logo दिखाएँ

      actions: const [], // No actions
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
