import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'dart:async';
import 'package:lottie/lottie.dart'; // for animation

class SupportChatScreen extends StatefulWidget {
  const SupportChatScreen({super.key});

  @override
  State<SupportChatScreen> createState() => _SupportChatScreenState();
}

class _SupportChatScreenState extends State<SupportChatScreen> {
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List messages = [];
  String userId = ""; // dynamic user id
  Timer? refreshTimer;

  @override
  void initState() {
    super.initState();
    loadUserId();
  }

  @override
  void dispose() {
    refreshTimer?.cancel();
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> loadUserId() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      userId = prefs.getString("userId") ?? "0";
    } catch (e) {
      userId = "0";
    }

    await loadMessages();

    // Periodic refresh
    refreshTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      loadMessages();
    });

    setState(() {});
  }

  Future<void> loadMessages() async {
    if (userId.isEmpty || userId == "0") return;

    try {
      final data = await ApiService.getMessages(userId);

      bool updated = false;

      if (data.length != messages.length) {
        updated = true;
      } else if (data.isNotEmpty &&
          messages.isNotEmpty &&
          data.last['message'] != messages.last['message']) {
        updated = true;
      } else if (messages.isEmpty && data.isNotEmpty) {
        updated = true;
      }

      if (updated) {
        setState(() {
          messages = data;
        });

        try {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setBool("hasUnreadMessages", false);
        } catch (_) {}

        Future.delayed(const Duration(milliseconds: 150), () => scrollToEnd());
      }
    } catch (e) {
      debugPrint("Error loading messages: $e");
    }
  }

  void scrollToEnd() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    _scrollController.animateTo(
      position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  Future<void> sendMessage() async {
    final msg = _msgController.text.trim();
    if (msg.isEmpty) return;

    _msgController.clear();

    final success = await ApiService.sendMessage(userId, msg);

    if (success) {
      await loadMessages();
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Failed to send message")));
      }
    }
  }

  Widget _buildEmptyChat() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            'support.json', // add any Lottie JSON animation here
            width: 250,
            height: 250,
            repeat: true,
          ),
          const SizedBox(height: 20),
          const Text(
            "Happy to help you!\nSend a message and we'll reply ASAP",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map msg) {
    final isUser = msg["sender"] == "user";

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        margin: const EdgeInsets.only(bottom: 12),
        constraints: const BoxConstraints(maxWidth: 300),
        decoration: BoxDecoration(
          gradient: isUser
              ? const LinearGradient(
                  colors: [Color(0xFF00FFCC), Color(0xFF00A3CC)],
                )
              : const LinearGradient(
                  colors: [Color(0xFF2A2A3D), Color(0xFF1F1F2E)],
                ),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 0),
            bottomRight: Radius.circular(isUser ? 0 : 16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              offset: const Offset(1, 2),
              blurRadius: 4,
            ),
          ],
        ),
        child: Text(
          msg['message'] ?? '',
          style: TextStyle(
            color: isUser ? Colors.black : Colors.white,
            fontSize: 15,
          ),
        ),
      ),
    );
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
          Expanded(
            child: messages.isEmpty
                ? _buildEmptyChat()
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: messages.length,
                    itemBuilder: (context, index) =>
                        _buildMessageBubble(messages[index]),
                  ),
          ),
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
                    onSubmitted: (_) => sendMessage(),
                  ),
                ),
                const SizedBox(width: 10),
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
