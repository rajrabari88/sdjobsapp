import 'package:flutter/material.dart';

// --- DARK THEME CONSTANTS (Global Consistency) ---
// Note: These constants are globally available in this file.
const Color primaryDarkColor = Color(
  0xFF0D0D12,
); // Deep Navy/Near Black Background
const Color accentNeon = Color(0xFF00FFFF); // Neon Cyan/Blue for highlights
const Color textLightColor = Colors.white; // Light text
const Color appBarDarkColor = Color(
  0xFF1B1B25,
); // AppBar Background, slightly lighter than main background
const Color logoSecondaryColor = Color(
  0xFF4A64FE,
); // Subtle secondary purple-blue accent

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final bool showProfile;
  final bool showBackButton;
  final bool showLogoOnlyRight;
  final List<Widget>? actions;
  final String? avatarUrl;
  final int? notificationCount;
  final VoidCallback? onProfileTap;
  final bool showNotifications;

  const CustomAppBar({
    super.key,
    this.title,
    this.showProfile = true,
    this.showBackButton = false,
    this.showLogoOnlyRight = false,
    this.actions,
    this.avatarUrl,
    this.notificationCount,
    this.onProfileTap,
    this.showNotifications = false,
  });

  // Dark Theme Logo
  Widget _buildLogo(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.business_center_rounded,
          color: accentNeon, // Using global constant
          size: 26,
        ),
        const SizedBox(width: 6),
        RichText(
          text: TextSpan(
            style: const TextStyle(
              fontFamily: 'Poppins', // modern rounded font
              fontWeight: FontWeight.w900,
              fontSize: 24,
              letterSpacing: 0.5,
            ),
            children: [
              TextSpan(
                text: 'SD',
                style: TextStyle(
                  color: accentNeon, // Using global constant
                ),
              ),
              TextSpan(
                text: 'Jobs',
                style: TextStyle(
                  color: textLightColor, // Using global constant
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Small logo on right side (Dark/Neon)
  Widget _buildRightLogo() {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: CircleAvatar(
        radius: 18,
        backgroundColor: logoSecondaryColor, // Using global constant
        child: const Icon(
          Icons.business_center_rounded,
          color: primaryDarkColor, // Using global constant
          size: 20,
        ),
      ),
    );
  }

  Widget _buildNotificationButton(BuildContext context) {
    final int count = notificationCount ?? 0;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          IconButton(
            icon: Icon(Icons.notifications_none, color: Colors.grey.shade400),
            onPressed: () {
              // default: open notifications screen
            },
          ),
          if (count > 0)
            Positioned(
              right: 6,
              top: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color:
                      Colors.redAccent, // Red remains standard for unread count
                  borderRadius: BorderRadius.circular(12),
                  // Small neon ring for extra pop
                  border: Border.all(
                    color: accentNeon.withOpacity(0.5),
                    width: 1,
                  ), // Using global constant
                ),
                child: Text(
                  count > 99 ? '99+' : '$count',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProfileAvatar() {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: GestureDetector(
        onTap: onProfileTap ?? () {},
        child: CircleAvatar(
          radius: 18,
          // FIX: Accessing global constant directly
          backgroundColor: logoSecondaryColor, // Used secondary accent
          backgroundImage: avatarUrl != null && avatarUrl!.isNotEmpty
              ? NetworkImage(avatarUrl!) as ImageProvider
              : null,
          child: avatarUrl == null || avatarUrl!.isEmpty
              ? const Icon(
                  Icons.person,
                  color: textLightColor,
                  size: 20,
                ) // Using global constant
              : null,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: appBarDarkColor, // Using global constant
      elevation: 5, // Increased elevation for depth
      shadowColor: Colors.black.withOpacity(0.5), // Dark shadow
      centerTitle: false,
      automaticallyImplyLeading: false,

      // Back button (Dark/Neon)
      leading: showBackButton
          ? IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: accentNeon, // Using global constant
                size: 22,
              ),
              onPressed: () => Navigator.pop(context),
            )
          : null,

      // Title or Logo
      title: (!showLogoOnlyRight && !showBackButton)
          ? _buildLogo(context) // Neon Logo
          : (title != null && (showBackButton || title!.isNotEmpty))
          ? Text(
              title!,
              style: const TextStyle(
                color: textLightColor, // Using global constant
                fontWeight: FontWeight.w700,
                fontSize: 22,
                letterSpacing: 0.3,
              ),
            )
          : null,

      titleSpacing: showBackButton
          ? 0.0
          : 16.0, // Adjust spacing if back button is present
      // Right-side icons
      actions:
          actions ??
          [
            if (showLogoOnlyRight)
              _buildRightLogo()
            else ...[
              if (showNotifications) _buildNotificationButton(context),
              if (showProfile) _buildProfileAvatar(),
            ],
          ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
