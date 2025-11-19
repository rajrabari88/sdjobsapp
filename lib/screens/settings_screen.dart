import 'package:flutter/material.dart';
import '../widgets/custom_appbar.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'App Settings', showBackButton: true),
      body: const Center(child: Text("Manage your app preferences here")),
    );
  }
}
