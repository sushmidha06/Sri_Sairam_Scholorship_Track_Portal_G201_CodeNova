import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:scholarship/theme/app_colors.dart';
import 'package:scholarship/models/chat_message.dart';
import 'package:scholarship/widgets/chat_bubble.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _userPhotoUrl;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _addWelcomeMessage();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (mounted) {
        setState(() {
          _userPhotoUrl = doc.data()?['photoURL'] ?? user.photoURL;
        });
      }
    }
  }

  void _addWelcomeMessage() {
    _addMessage(
      "Hello! I'm your scholarship assistant. I can help you find information about scholarships, eligibility criteria, and application processes. How can I assist you today?",
      isUser: false,
    );
  }

  void _handleSubmitted(String text) {
    if (text.trim().isEmpty) return;

    _addMessage(text, isUser: true);
    _messageController.clear();
    _simulateBotResponse(text);
    _scrollToBottom();
  }

  void _simulateBotResponse(String userMessage) {
    // Simulate typing indicator
    final typingId = DateTime.now().millisecondsSinceEpoch;
    _addMessage("typing...", isUser: false, isTyping: true, typingId: typingId);
    _scrollToBottom();

    // Simulate API call delay
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;

      // Remove typing indicator
      _messages.removeWhere((msg) => msg.typingId == typingId);

      // Add bot response
      String response = _getBotResponse(userMessage);
      _addMessage(response, isUser: false);
      _scrollToBottom();
    });
  }

  String _getBotResponse(String userMessage) {
    // Simple response logic - in a real app, this would call an API
    userMessage = userMessage.toLowerCase();

    if (userMessage.contains('scholarship') && userMessage.contains('eligibility')) {
      return "Eligibility criteria vary by scholarship. Common requirements include academic performance, financial need, and specific qualifications. Could you specify which scholarship you're interested in?";
    } else if (userMessage.contains('apply') || userMessage.contains('application')) {
      return "To apply for scholarships, you'll typically need to submit an application form, academic transcripts, recommendation letters, and sometimes an essay. Would you like me to guide you through the application process for a specific scholarship?";
    } else if (userMessage.contains('deadline')) {
      return "Scholarship deadlines vary. Most scholarships have deadlines between September and April for the following academic year. Would you like me to check the deadline for a specific scholarship?";
    } else if (userMessage.contains('thank') || userMessage.contains('thanks')) {
      return "You're welcome! Is there anything else I can help you with regarding scholarships?";
    } else {
      return "I'm here to help with all your scholarship questions. You can ask me about eligibility criteria, application processes, deadlines, or any other scholarship-related information. What would you like to know?";
    }
  }

  void _addMessage(String text, {required bool isUser, bool isTyping = false, int? typingId}) {
    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isUser: isUser,
        isTyping: isTyping,
        typingId: typingId,
      ));
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: const Text(
          'Scholarship Assistant',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        backgroundColor: AppColors.primaryTeal,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.only(top: 20, bottom: 16, left: 16, right: 16),
                  itemCount: _messages.length,
                  itemBuilder: (context, i) => ChatMessageWidget(
                    message: _messages[i],
                    userPhotoUrl: _userPhotoUrl,
                  ),
                ),
              ),
            ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        focusNode: _focusNode,
                        onSubmitted: _handleSubmitted,
                        style: const TextStyle(fontSize: 16),
                        decoration: InputDecoration(
                          hintText: 'Type your message...',
                          hintStyle: TextStyle(color: Colors.grey[600]),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        maxLines: null,
                        textInputAction: TextInputAction.send,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                color: AppColors.primaryTeal,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white),
                onPressed: () => _handleSubmitted(_messageController.text),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
