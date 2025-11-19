import 'package:flutter/material.dart';

// --- DARK THEME CONSTANTS (Global Consistency) ---
const Color primaryDarkColor = Color(
  0xFF0D0D12,
); // Deep Navy/Near Black Background
const Color accentNeon = Color(0xFF00FFFF); // Neon Cyan/Blue for highlights
const Color textLightColor = Colors.white; // Light text
const Color searchBarDarkFill = Color(
  0xFF1B1B25,
); // Dark Fill Color for Search Bar
const Color secondaryAccent = Color(
  0xFF4A64FE,
); // Subtle Purple-Blue for filter button

class CustomSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final VoidCallback? onFilterTap;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool showClearButton;
  final VoidCallback? onClear;
  final bool autofocus;
  final Widget? prefixIcon;

  const CustomSearchBar({
    super.key,
    required this.controller,
    this.hint = 'Search...',
    this.onFilterTap,
    this.onChanged,
    this.onSubmitted,
    this.showClearButton = true,
    this.onClear,
    this.autofocus = false,
    this.prefixIcon,
  });

  // Dark Theme Clear Button
  Widget _buildClearButton() {
    return GestureDetector(
      onTap: () {
        controller.clear();
        if (onChanged != null) onChanged!('');
        if (onClear != null) onClear!();
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        // Design Change: Light gray icon for subtle contrast
        child: Icon(Icons.clear, color: Colors.grey.shade400, size: 20),
      ),
    );
  }

  // Dark Theme Filter Button (Neon Accent)
  Widget _buildFilterButton() {
    return GestureDetector(
      onTap: onFilterTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        padding: const EdgeInsets.all(
          6,
        ), // Padding to make the icon container visible
        decoration: BoxDecoration(
          color:
              secondaryAccent, // Secondary accent color for the filter button
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: secondaryAccent.withOpacity(0.4),
              blurRadius: 10,
              offset: const Offset(0, 0),
            ),
          ],
        ),
        child: const Icon(
          Icons.filter_list_rounded, // Slightly more modern icon
          color: textLightColor, // Light icon color
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Compose suffix icons
    Widget? suffix;
    final hasFilter = onFilterTap != null;

    // Use ValueListenableBuilder to re-build suffix only when text changes,
    // making the clear button appear dynamically without setState.
    final clearButtonWidget = ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, child) {
        if (showClearButton && value.text.isNotEmpty) {
          return _buildClearButton();
        }
        return const SizedBox.shrink();
      },
    );

    if (hasFilter) {
      // If we have a filter, put the clear button/spacer and the filter button
      suffix = Row(
        mainAxisSize: MainAxisSize.min,
        children: [clearButtonWidget, _buildFilterButton()],
      );
    } else {
      // If no filter, suffix is just the dynamic clear button
      suffix = clearButtonWidget;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
      child: TextField(
        controller: controller,
        autofocus: autofocus,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        // Design Change: Text Style for input
        style: const TextStyle(color: textLightColor),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: Colors.grey.shade600,
          ), // Dark background par subtle hint
          // Design Change: Search Icon (Neon Accent)
          prefixIcon:
              prefixIcon ?? Icon(Icons.search_rounded, color: accentNeon),
          suffixIcon: suffix,
          filled: true,
          fillColor: searchBarDarkFill, // Dark Fill Color
          // Design Change: Border, slightly softer look
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18), // Slightly more rounded
            borderSide: BorderSide.none,
          ),
          // Add subtle glow effect for focus (optional, but enhances neon look)
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(
              color: accentNeon.withOpacity(0.5),
              width: 1.0,
            ),
          ),
        ),
      ),
    );
  }
}
