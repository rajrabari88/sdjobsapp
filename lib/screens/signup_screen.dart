import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

// --- DARK THEME CONSTANTS (Consistency is crucial) ---
const Color primaryDarkColor = Color(
  0xFF0D0D12,
); // Deep Navy/Near Black Background
const Color accentNeon = Color(0xFF00FFFF); // Neon Cyan/Blue for highlights
const Color textLightColor = Colors.white; // Light text
const Color cardDarkColor = Color(
  0xFF1B1B25,
); // Card Background / Input Field Fill

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  // We are now using accentNeon as the primary action color
  final Color primaryActionColor = accentNeon;

  @override
  void dispose() {
    _nameController.dispose();
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
  //         ).showSnackBar(SnackBar(content: Text("$icon sign up clicked")));
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
  //         child: Icon(
  //           icon,
  //           color: color == Colors.black ? textLightColor : color,
  //           size: 30,
  //         ), // Apple icon needs to be white/light in dark theme
  //       ),
  //     ),
  //   );
  // }

  // --- The main Widget Build method (Updated to Dark/Neon Theme) ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryDarkColor, // Design Change: Dark background
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 60),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- App Logo / Title (Consistent Neon Styling) ---
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
                      "Start Your Journey! 🚀",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: textLightColor, // Light text for title
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Register to unlock your dream job opportunities",
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 16,
                      ), // Light grey subtitle
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 50),

              // --- Full Name Field (Dark/Neon Styled) ---
              Text(
                "Full Name",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: textLightColor, // Light text for label
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                style: const TextStyle(
                  color: textLightColor,
                ), // Input text is light
                decoration: InputDecoration(
                  hintText: "Enter your full name",
                  hintStyle: TextStyle(color: Colors.grey.shade600),
                  prefixIcon: Icon(
                    Icons.person_outline,
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
              const SizedBox(height: 20),

              // --- Email Field (Dark/Neon Styled) ---
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
                  hintText: "Enter your email address",
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
                    borderSide: BorderSide(color: primaryActionColor, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // --- Password Field (Dark/Neon Styled) ---
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
                  hintText: "Create a secure password",
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
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
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
                    borderSide: BorderSide(color: primaryActionColor, width: 2),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // --- Sign Up Button (Neon Style) ---
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
                          if (_nameController.text.isEmpty ||
                              _emailController.text.isEmpty ||
                              _passwordController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Please fill all fields"),
                              ),
                            );
                            return;
                          }

                          setState(() => _isLoading = true);

                          // NOTE: Using raw HTTP POST as in the original code, but keeping
                          // the success/failure logic based on the response.
                          final response = await http.post(
                            Uri.parse(
                              "http://192.168.1.194/sdjobs/api/register.php",
                            ),
                            body: {
                              "name": _nameController.text.trim(),
                              "email": _emailController.text.trim(),
                              "password": _passwordController.text.trim(),
                            },
                          );

                          if (!mounted) return;
                          setState(() => _isLoading = false);

                          try {
                            final data = jsonDecode(response.body);

                            if (data['status'] == "success") {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Account created successfully. Please login.",
                                  ),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              // Navigate to Login Screen after successful sign-up
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const LoginScreen(),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    data['message'] ?? 'Registration failed.',
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Error: Could not process server response. Status code: ${response.statusCode}',
                                ),
                                backgroundColor: Colors.red,
                              ),
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
                          "Create Account",
                          style: TextStyle(
                            color: primaryDarkColor, // Dark text on neon button
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 30),

              // --- Divider with text (Dark Theme) ---
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
              //         "OR SIGN UP WITH",
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

              // // --- Social Buttons (Dark Theme) ---
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: [
              //     _socialButton(Icons.g_mobiledata, Colors.red.shade600),
              //     const SizedBox(width: 16),
              //     _socialButton(Icons.facebook, const Color(0xFF1877F2)),
              //     const SizedBox(width: 16),
              //     _socialButton(
              //       Icons.apple,
              //       Colors.black,
              //     ), // Color is black, but widget converts it to white/light in dark theme
              //   ],
              // ),

              // const SizedBox(height: 50),

              // 🔹 Login Navigation (Neon Accent)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Already have an account?",
                    style: TextStyle(
                      fontSize: 15,
                      color: textLightColor,
                    ), // Light text
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    },
                    child: Text(
                      "Login",
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
