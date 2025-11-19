import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'forgot_password_screen.dart';
import 'signup_screen.dart';
import '../main.dart'; // To navigate to MainPage
import '../services/auth_service.dart';

// --- DARK THEME CONSTANTS (Consistency is crucial) ---
const Color primaryDarkColor = Color(
  0xFF0D0D12,
); // Deep Navy/Near Black Background
const Color accentNeon = Color(0xFF00FFFF); // Neon Cyan/Blue for highlights
const Color textLightColor = Colors.white; // Light text
const Color cardDarkColor = Color(
  0xFF1B1B25,
); // Card Background / Input Field Fill

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  // We are now using accentNeon as the primary action color
  final Color primaryActionColor = accentNeon;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // --- Social Button Widget (Dark/Neon Style) ---
  // Widget _socialButton(IconData icon, Color color) {
  //   return Expanded(
  //     child: InkWell(
  //       onTap: () {
  //         ScaffoldMessenger.of(
  //           context,
  //         ).showSnackBar(SnackBar(content: Text("$icon login clicked")));
  //       },
  //       borderRadius: BorderRadius.circular(16),
  //       child: Container(
  //         height: 55,
  //         padding: const EdgeInsets.symmetric(vertical: 10),
  //         decoration: BoxDecoration(
  //           color: cardDarkColor, // Dark background for the button
  //           borderRadius: BorderRadius.circular(16),
  //           border: Border.all(
  //             color: Colors.grey.shade700,
  //             width: 1,
  //           ), // Subtle dark border
  //           boxShadow: [
  //             BoxShadow(
  //               color: primaryActionColor.withOpacity(
  //                 0.05,
  //               ), // Subtle neon glow on interaction
  //               blurRadius: 10,
  //             ),
  //           ],
  //         ),
  //         child: Icon(icon, color: color, size: 30),
  //       ),
  //     ),
  //   );
  // }

  // --- Main Build ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryDarkColor, // Design Change: Dark background
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 60),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Logo & Title (Neon Style) ---
              Center(
                child: Column(
                  children: [
                    Container(
                      height: 80,
                      width: 80,
                      decoration: BoxDecoration(
                        color:
                            primaryActionColor, // Neon color as logo background
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: primaryActionColor.withOpacity(
                              0.6,
                            ), // Stronger neon glow
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          "SD",
                          style: TextStyle(
                            color:
                                primaryDarkColor, // Dark text on neon background
                            fontSize: 38,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      "Welcome Back! 👋",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: textLightColor, // Light text for title
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Log in to continue your career journey",
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 16,
                      ), // Light grey subtitle
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 50),

              // --- Email ---
              Text(
                "Email Address",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: textLightColor, // Light text for label
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(
                  color: textLightColor,
                ), // Input text is light
                decoration: InputDecoration(
                  hintText: "Enter your email",
                  hintStyle: TextStyle(color: Colors.grey.shade600),
                  prefixIcon: Icon(
                    Icons.email_outlined,
                    color: primaryActionColor, // Neon icon
                  ),
                  filled: true,
                  fillColor: cardDarkColor, // Design Change: Dark fill color
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
              const SizedBox(height: 20),

              // --- Password ---
              Text(
                "Password",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: textLightColor, // Light text for label
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                style: const TextStyle(
                  color: textLightColor,
                ), // Input text is light
                decoration: InputDecoration(
                  hintText: "Enter your password",
                  hintStyle: TextStyle(color: Colors.grey.shade600),
                  prefixIcon: Icon(
                    Icons.lock_outline,
                    color: primaryActionColor, // Neon icon
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: primaryActionColor, // Neon icon
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  filled: true,
                  fillColor: cardDarkColor, // Design Change: Dark fill color
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

              const SizedBox(height: 10),

              // --- Forgot Password ---
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ForgotPasswordScreen(),
                      ),
                    );
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    "Forgot Password?",
                    style: TextStyle(
                      color:
                          primaryActionColor, // Design Change: Neon text color
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                      decorationColor: primaryActionColor,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // --- Login Button (Neon Style) ---
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
                  onPressed: _isLoading
                      ? null
                      : () async {
                          if (_emailController.text.isEmpty ||
                              _passwordController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Please enter both email and password",
                                ),
                              ),
                            );
                            return;
                          }

                          setState(() => _isLoading = true);

                          final result = await AuthService.login(
                            _emailController.text.trim(),
                            _passwordController.text.trim(),
                          );

                          if (!mounted) return;
                          setState(() => _isLoading = false);

                          if (result['status'] == 'success') {
                            final user = result['user'];
                            final userId = user?['id']?.toString();
                            final prefs = await SharedPreferences.getInstance();

                            if (userId != null) {
                              await prefs.setString('userId', userId);
                            }

                            if (userId == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Login succeeded but user data missing',
                                  ),
                                ),
                              );
                              return;
                            }

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  result['message'] ?? "Login successful",
                                ),
                              ),
                            );

                            // ✅ Navigate to MainPage with userId
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MainPage(userId: userId),
                              ),
                            );
                          } else {
                            final errMsg =
                                result['message'] ??
                                result['body'] ??
                                "Login failed";
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(errMsg.toString())),
                            );
                          }
                        },
                  child: _isLoading
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
                          "Login Securely",
                          style: TextStyle(
                            color: primaryDarkColor, // Dark text on neon button
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 40),

              // --- Divider (Dark Theme) ---
              // Row(
              //   children: [
              //     Expanded(
              //       child: Divider(
              //         thickness: 1,
              //         color: Colors.grey.shade700,
              //       ), // Darker divider
              //     ),
              //     Padding(
              //       padding: const EdgeInsets.symmetric(horizontal: 12),
              //       child: Text(
              //         "OR CONNECT WITH",
              //         style: TextStyle(
              //           color: Colors.grey.shade500, // Light grey text
              //           fontSize: 13,
              //           fontWeight: FontWeight.w500,
              //         ),
              //       ),
              //     ),
              //     Expanded(
              //       child: Divider(thickness: 1, color: Colors.grey.shade700),
              //     ),
              //   ],
              // ),
              // const SizedBox(height: 25),

              // --- Social Buttons (Dark Theme) ---
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: [
              //     // Social icons keep their branded colors, but the container is dark/neon
              //     _socialButton(Icons.g_mobiledata, Colors.red.shade600),
              //     const SizedBox(width: 16),
              //     _socialButton(Icons.facebook, const Color(0xFF1877F2)),
              //     const SizedBox(width: 16),
              //     _socialButton(
              //       Icons.apple,
              //       textLightColor,
              //     ), // Apple icon becomes white/light
              //   ],
              // ),

              // const SizedBox(height: 60),

              // --- Signup Link (Neon Accent) ---
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Don’t have an account?",
                    style: TextStyle(
                      fontSize: 15,
                      color: textLightColor,
                    ), // Light text
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SignUpScreen(),
                        ),
                      );
                    },
                    child: Text(
                      "Sign Up",
                      style: TextStyle(
                        color: primaryActionColor, // Neon color for action link
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
