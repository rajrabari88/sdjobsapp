import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/responsive.dart';
import '../screens/support_chat_screen.dart';

const Color accentNeon = Color(0xFF00FFFF);
const Color textLightColor = Colors.white;

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool showBackButton;
  final String? title;
  final bool hasUnread; // <-- NEW

  const CustomAppBar({
    super.key,
    this.showBackButton = false,
    this.title,
    this.hasUnread = false,
  });

  // Logo
  Widget _buildLogo(BuildContext context) {
    final baseSize = Responsive.fontSize(context, 28);
    return Padding(
      padding: const EdgeInsets.only(left: 4.0),
      child: RichText(
        text: TextSpan(
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w800,
            fontSize: baseSize,
            letterSpacing: 0.8,
            height: 1.0,
          ),
          children: [
            TextSpan(
              text: 'SD',
              style: TextStyle(
                color: accentNeon,
                shadows: [
                  Shadow(color: accentNeon.withOpacity(0.5), blurRadius: 10.0),
                ],
              ),
            ),
            const TextSpan(
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
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      automaticallyImplyLeading: false,

      leading: showBackButton
          ? IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: accentNeon,
                size: Responsive.fontSize(context, 22),
              ),
              onPressed: () => Navigator.pop(context),
            )
          : null,

      title: title != null && showBackButton
          ? Text(
              title!,
              style: TextStyle(
                color: textLightColor,
                fontSize: Responsive.fontSize(context, 18),
                fontWeight: FontWeight.w600,
              ),
            )
          : _buildLogo(context),

      actions: [
        Stack(
          children: [
            IconButton(
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                prefs.setBool("hasUnreadMessages", false);

                if (context.mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SupportChatScreen(),
                    ),
                  );
                }
              },
              icon: Icon(
                Icons.chat_bubble_outline_rounded,
                color: accentNeon,
                size: 28,
              ),
            ),

            // 🔴 RED DOT
            if (hasUnread)
              Positioned(
                right: 10,
                top: 10,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.redAccent.withOpacity(0.8),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: 6),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
