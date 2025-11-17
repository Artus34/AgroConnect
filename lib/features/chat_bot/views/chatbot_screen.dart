import 'package:agrolink/app/theme/app_colors.dart';
import 'package:agrolink/features/chat_bot/services/chat_bot_service.dart';
import 'package:agrolink/features/chat_bot/widgets/chat_bot_message_bubble.dart';
import 'package:flutter/material.dart';
import 'dart:ui'; // ⭐ ADDED: Import for ImageFilter

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ChatbotService _service = ChatbotService();

  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadChatHistory();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _loadChatHistory() async {
    final history = await _service.loadChatHistory();
    setState(() {
      _messages.clear();
      _messages.addAll(history);
    });
    _scrollToBottom();
  }

  Future<void> _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({'role': 'user', 'text': text});
      _textController.clear();
      _isLoading = true;
    });

    await _service.saveMessage("user", text);
    _scrollToBottom();

    final reply = await _service.sendMessage(_messages);

    setState(() {
      _messages.add({'role': 'model', 'text': reply});
      _isLoading = false;
    });

    await _service.saveMessage("model", reply);
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Ensure Scaffold background is transparent so the background image shows through
      backgroundColor: Colors.transparent, 
      appBar: AppBar(
        title: const Text("🌾 AgroBot",
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
      ),
      // ⭐ MODIFIED: Wrap Scaffold body with background and blur
      body: Container(
        // 1. Add the background image
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/doodles3.png'), // Target image
            fit: BoxFit.cover,
            repeat: ImageRepeat.repeat,
          ),
        ),
        child: BackdropFilter(
          // 2. Add the blur filter
          filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(10),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final msg = _messages[index];
                    return ChatMessageBubble(
                      text: msg['text']!,
                      isUser: msg['role'] == 'user',
                    );
                  },
                ),
              ),
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: LinearProgressIndicator(color: AppColors.primaryGreen),
                ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black12, blurRadius: 8, offset: Offset(0, -2)),
                  ],
                ),
                child: SafeArea(
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _textController,
                          decoration: InputDecoration(
                            hintText: "Ask about prices or trends...",
                            filled: true,
                            fillColor: AppColors.lightScaffoldBackground,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 14),
                          ),
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      CircleAvatar(
                        backgroundColor: AppColors.primaryGreen,
                        radius: 26,
                        child: IconButton(
                          icon: const Icon(Icons.send, color: Colors.white),
                          onPressed: _isLoading ? null : _sendMessage,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}