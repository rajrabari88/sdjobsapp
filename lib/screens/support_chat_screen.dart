import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'dart:async';

class SupportChatScreen extends StatefulWidget {
  const SupportChatScreen({super.key});

  @override
  State<SupportChatScreen> createState() => _SupportChatScreenState();
}

class _SupportChatScreenState extends State<SupportChatScreen> {
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List messages = [];
  final String userId = "1"; // logged-in user id
  Timer? refreshTimer;

  // Load messages
  Future loadMessages() async {
    try {
      final data = await ApiService.getMessages(userId);

      setState(() {
        messages = data;
      });

      // Auto scroll to bottom
      Future.delayed(const Duration(milliseconds: 200), () {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        }
      });
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  // Send message
  Future sendMessage() async {
    final msg = _msgController.text.trim();
    if (msg.isEmpty) return;

    await ApiService.sendMessage(userId, msg);
    _msgController.clear();
    loadMessages();
  }

  @override
  void initState() {
    super.initState();

    loadMessages();

    // AUTO REFRESH EVERY 2 SECONDS
    refreshTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      loadMessages();
    });
  }

  @override
  void dispose() {
    refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D12),

      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0D12),
        elevation: 0,
        title: const Text(
          "Support Chat",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),

      body: Column(
        children: [
          // Chat Messages
          Expanded(
            child: messages.isEmpty
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.cyanAccent),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      final isUser = msg["sender"] == "user";

                      return Align(
                        alignment: isUser
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            gradient: isUser
                                ? const LinearGradient(
                                    colors: [
                                      Color(0xFF00FFFF),
                                      Color(0xFF00A3CC),
                                    ],
                                  )
                                : const LinearGradient(
                                    colors: [
                                      Color(0xFF1F1F2E),
                                      Color(0xFF2A2A3D),
                                    ],
                                  ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            msg['message'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // Input Box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            color: const Color(0xFF15151E),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _msgController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFF1D1D29),
                      hintText: "Write a message...",
                      hintStyle: const TextStyle(color: Colors.white54),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                // Send Button
                CircleAvatar(
                  radius: 26,
                  backgroundColor: Colors.cyanAccent,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.black),
                    onPressed: sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
