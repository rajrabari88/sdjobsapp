import 'package:flutter/material.dart';
// Note: Assuming LoginScreen exists to navigate back to it, though not strictly required for this file.

// --- DARK THEME CONSTANTS (Consistency is crucial) ---
const Color primaryDarkColor = Color(
  0xFF0D0D12,
); // Deep Navy/Near Black Background
const Color accentNeon = Color(0xFF00FFFF); // Neon Cyan/Blue for highlights
const Color textLightColor = Colors.white; // Light text
const Color cardDarkColor = Color(
  0xFF1B1B25,
); // Card Background / Input Field Fill

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _isSending = false;
  final Color primaryActionColor =
      accentNeon; // Using Neon for main action color

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  // --- The main Widget Build method (Updated to Dark/Neon Theme) ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryDarkColor, // Design Change: Dark background
      appBar: AppBar(
        // Clean App Bar with Dark/Neon Styling
        backgroundColor: primaryDarkColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: textLightColor), // White icon
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Reset Password",
          style: TextStyle(
            color: textLightColor,
            fontWeight: FontWeight.bold,
          ), // White title
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),

              // --- Icon Container (Neon Styled) ---
              Center(
                child: Container(
                  height: 120,
                  width: 120,
                  decoration: BoxDecoration(
                    color: primaryActionColor.withOpacity(
                      0.2,
                    ), // Subtle neon background
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: primaryActionColor.withOpacity(
                          0.3,
                        ), // Light neon glow
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.lock_reset,
                    color: primaryActionColor, // Neon icon color
                    size: 60,
                  ),
                ),
              ),

              const SizedBox(height: 35),

              // --- Title and Subtitle (Dark Theme Typography) ---
              Text(
                "Forgot Your Password? 🔑",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: textLightColor, // Light text
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Don't worry, it happens! Enter your registered email address below to receive a secure reset link.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey.shade400, // Light grey subtitle
                  fontSize: 16,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 50),

              // --- Email Label ---
              Text(
                "Email Address",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: textLightColor, // Light text for label
                ),
              ),
              const SizedBox(height: 8),

              // --- Email TextField (Dark/Neon Styled) ---
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(
                  color: textLightColor,
                ), // Input text is light
                decoration: InputDecoration(
                  hintText: "Enter your registered email",
                  hintStyle: TextStyle(color: Colors.grey.shade600),
                  prefixIcon: Icon(
                    Icons.email_outlined,
                    color: primaryActionColor, // Neon icon
                  ),
                  filled: true,
                  fillColor: cardDarkColor, // Dark fill color
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 18,
                    horizontal: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    // Neon focus border
                    borderSide: BorderSide(color: primaryActionColor, width: 2),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // --- Reset Button (Neon Style) ---
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryActionColor, // Neon Button Color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 10,
                    // Stronger neon shadow for the main action
                    shadowColor: primaryActionColor.withOpacity(0.8),
                  ),
                  onPressed: _isSending
                      ? null
                      : () async {
                          if (_emailController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Please enter your email address",
                                ),
                              ),
                            );
                            return;
                          }

                          setState(() => _isSending = true);
                          await Future.delayed(
                            const Duration(seconds: 2),
                          ); // Simulate network delay
                          if (!mounted) return;

                          setState(() => _isSending = false);

                          // Show success message and navigate back
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "✅ Password reset link sent to ${_emailController.text}!",
                              ),
                              backgroundColor: Colors.green.shade600,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          Navigator.pop(context); // Go back to login screen
                        },
                  child: _isSending
                      ? SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color:
                                primaryDarkColor, // Dark spinner on neon button
                            strokeWidth: 2.5,
                          ),
                        )
                      : Text(
                          "Send Reset Link",
                          style: TextStyle(
                            color: primaryDarkColor, // Dark text on neon button
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 30),

              // --- Back to Login Button (Subtle Neon TextButton) ---
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    "← Back to Login",
                    style: TextStyle(
                      color: primaryActionColor.withOpacity(
                        0.8,
                      ), // Subtle neon link
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
