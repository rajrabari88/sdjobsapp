import 'package:flutter/material.dart';

// --- DARK THEME CONSTANTS (Re-used from HomeScreen for consistency) ---
const Color primaryDarkColor = Color(0xFF0D0D12); // Deep Navy/Near Black
const Color accentNeon = Color(0xFF00FFFF); // Neon Cyan/Blue
const Color secondaryAccent = Color(0xFF4A64FE); // Subtle Purple-Blue
const Color cardDarkColor = Color(0xFF1B1B25); // Card Background
const Color textLightColor = Colors.white;

class JobCard extends StatelessWidget {
  final String title;
  final String company;
  final String location;
  final String salary;
  final String type;
  final String logoText;
  final String experience;
  final String postedDate;
  final String? logoUrl;
  final VoidCallback? onTap;
  final VoidCallback? onApply;
  final bool isSaved;
  final VoidCallback? onSaveTap;

  const JobCard({
    super.key,
    required this.title,
    required this.company,
    required this.location,
    required this.salary,
    required this.type,
    required this.logoText,
    this.logoUrl,
    this.experience = '2-5 yrs',
    this.postedDate = '2 days ago',
    this.onTap,
    this.onApply,
    this.isSaved = false,
    this.onSaveTap,
  });

  @override
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    // Auto responsive sizes
    double titleSize = width < 360 ? 16 : 18;
    double subtitleSize = width < 360 ? 12 : 14;
    double smallTextSize = width < 360 ? 11 : 13;
    double logoSize = width < 360 ? 15 : 18;
    double paddingSize = width < 360 ? 14 : 18;

    Color typeColor;
    switch (type.toLowerCase()) {
      case 'full time':
        typeColor = Colors.green.shade400;
        break;
      case 'part time':
        typeColor = Colors.orange.shade400;
        break;
      case 'remote':
        typeColor = secondaryAccent;
        break;
      default:
        typeColor = Colors.blue.shade400;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: EdgeInsets.all(paddingSize),
        decoration: BoxDecoration(
          color: cardDarkColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ TOP SECTION SAFE FROM OVERFLOW
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: logoSize,
                  backgroundColor: secondaryAccent,
                  backgroundImage: (logoUrl != null && logoUrl!.isNotEmpty)
                      ? NetworkImage(logoUrl!)
                      : null,
                  child: (logoUrl == null || logoUrl!.isEmpty)
                      ? FittedBox(
                          child: Text(
                            logoText,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: textLightColor,
                              fontSize: subtitleSize,
                            ),
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),

                // ✅ TEXT WILL AUTO-SCALE SAFELY
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textScaler: const TextScaler.linear(1),
                        style: TextStyle(
                          fontSize: titleSize,
                          fontWeight: FontWeight.w700,
                          color: textLightColor,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        company,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: subtitleSize,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                ),

                GestureDetector(
                  onTap: onSaveTap,
                  child: Icon(
                    isSaved
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_border_rounded,
                    color: isSaved ? accentNeon : Colors.grey.shade600,
                    size: width < 360 ? 22 : 26,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            // ✅ CHIPS ALWAYS WRAP SAFELY
            Wrap(
              spacing: 10,
              runSpacing: 6,
              children: [
                _chip(Icons.currency_rupee, salary, accentNeon, smallTextSize),
                _chip(null, type, typeColor, smallTextSize),
              ],
            ),

            const SizedBox(height: 15),

            // ✅ BOTTOM INFO NEVER BREAKS
            Row(
              children: [
                Icon(
                  Icons.location_on_rounded,
                  size: 16,
                  color: Colors.grey.shade500,
                ),
                const SizedBox(width: 5),
                Flexible(
                  child: Text(
                    location,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: smallTextSize,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  Icons.work_history_rounded,
                  size: 16,
                  color: Colors.grey.shade500,
                ),
                const SizedBox(width: 5),
                Text(
                  experience,
                  style: TextStyle(
                    fontSize: smallTextSize,
                    color: Colors.grey.shade400,
                  ),
                ),
                Spacer(),
                Text(
                  postedDate,
                  style: TextStyle(
                    fontSize: smallTextSize - 1,
                    color: Colors.grey.shade600,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            /// APPLY BUTTON
            SizedBox(
              width: double.infinity, // ✅ Full width for symmetry
              height: 44,
              child: TextButton(
                onPressed: onApply ?? () {},
                style: TextButton.styleFrom(
                  backgroundColor: secondaryAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  "Apply Now",
                  style: TextStyle(
                    fontSize: subtitleSize,
                    fontWeight: FontWeight.w700,
                    color: textLightColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(IconData? icon, String text, Color color, double fontSize) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) Icon(icon, size: 14, color: color),
          if (icon != null) const SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
