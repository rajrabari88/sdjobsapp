import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/search_screen.dart';
import 'screens/services_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

// --- DARK THEME CONSTANTS (Consistency is crucial) ---
const Color primaryDarkColor = Color(
  0xFF0D0D12,
); // Deep Navy/Near Black Background
const Color accentNeon = Color(0xFF00FFFF); // Neon Cyan/Blue for highlights
const Color textLightColor = Colors.white; // Light text
const Color cardDarkColor = Color(
  0xFF1B1B25,
); // Card Background / Navigation Bar Background

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final savedUserId = prefs.getString('userId');

  runApp(SDJobsApp(savedUserId: savedUserId));
}

class SDJobsApp extends StatelessWidget {
  final String? savedUserId;

  const SDJobsApp({super.key, this.savedUserId});
  @override
  Widget build(BuildContext context) {
    // 🎨 DESIGN CHANGE: Dark Theme Setup
    return MaterialApp(
      title: 'SDJobs',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark, // Set primary brightness to dark
        useMaterial3: true,
        scaffoldBackgroundColor: primaryDarkColor,
        // Set up the color scheme for a dark, minimalist look
        colorScheme: ColorScheme.dark(
          primary: accentNeon, // Neon color as primary accent
          secondary: accentNeon,
          background: primaryDarkColor,
          surface: cardDarkColor,
          onPrimary: primaryDarkColor, // Dark text on neon buttons
          onSurface: textLightColor, // White text on dark surfaces
        ),
        // Global Text Theme (optional, but good for consistency)
        textTheme: Theme.of(context).textTheme.apply(
          bodyColor: textLightColor,
          displayColor: textLightColor,
        ),
        // AppBar Theme
        appBarTheme: const AppBarTheme(
          backgroundColor: cardDarkColor,
          foregroundColor: textLightColor,
        ),
      ),
      home: savedUserId != null
          ? MainPage(userId: savedUserId!) // 👈 App direct home open karega
          : const LoginScreen(), // 👈 App start hone par Login page dikhega
    );
  }
}

// 👇 Ye hai main navigation wali page (AFTER login)
class MainPage extends StatefulWidget {
  final String userId; // ✅ userId pass hoga yahan
  const MainPage({super.key, required this.userId});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    // ✅ Pass userId to HomeScreen (and optionally others)
    final List<Widget> screens = [
      HomeScreen(userId: widget.userId),
      SearchScreen(userId: widget.userId),
      ServicesScreen(userId: widget.userId),
      ProfileScreen(userId: widget.userId),
    ];

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) =>
            FadeTransition(opacity: animation, child: child),
        child: screens[_currentIndex],
      ),

      // 🎨 DESIGN CHANGE: Dark/Neon NavigationBar
      bottomNavigationBar: Container(
        // Subtle glow effect container for the NavigationBar
        decoration: BoxDecoration(
          color: cardDarkColor,
          boxShadow: [
            BoxShadow(
              color: accentNeon.withOpacity(0.2),
              blurRadius: 20,
              spreadRadius: 0,
            ),
          ],
        ),
        child: NavigationBar(
          height: 70,
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) =>
              setState(() => _currentIndex = index),

          // NavigationBar Styling for Dark Theme
          backgroundColor: cardDarkColor, // Dark background
          indicatorColor: accentNeon.withOpacity(
            0.15,
          ), // Subtle neon background on select
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,

          // Text and Icon Styling
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.home_outlined, color: Colors.grey),
              selectedIcon: Icon(
                Icons.home_rounded,
                color: accentNeon,
              ), // Neon selected icon
              label: 'Home',
            ),
            NavigationDestination(
              icon: const Icon(Icons.search_outlined, color: Colors.grey),
              selectedIcon: Icon(Icons.search_rounded, color: accentNeon),
              label: 'Search',
            ),
            NavigationDestination(
              icon: const Icon(
                Icons.business_center_outlined,
                color: Colors.grey,
              ),
              selectedIcon: Icon(
                Icons.business_center_rounded,
                color: accentNeon,
              ),
              label: 'Jobs',
            ),
            NavigationDestination(
              icon: const Icon(Icons.person_outline, color: Colors.grey),
              selectedIcon: Icon(Icons.person_rounded, color: accentNeon),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
