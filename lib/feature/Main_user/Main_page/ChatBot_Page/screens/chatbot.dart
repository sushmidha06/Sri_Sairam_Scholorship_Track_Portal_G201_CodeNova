import 'package:flutter/material.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({Key? key}) : super(key: key);

  @override
  _ChatbotScreenState createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];

  void _handleSubmitted(String text) {
    if (text.trim().isEmpty) return;
    
    // Add user message
    _messages.add(ChatMessage(
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    ));
    
    // Clear the input field
    _messageController.clear();
    
    // Simulate bot response
    _simulateBotResponse(text);
    
    // Update the UI
    setState(() {});
  }

  void _simulateBotResponse(String userMessage) {
    String response = _getBotResponse(userMessage);
    
    // Simulate typing delay
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _messages.add(ChatMessage(
          text: response,
          isUser: false,
          timestamp: DateTime.now(),
        ));
      });
    });
  }

  String _getBotResponse(String message) {
    final lowerMessage = message.toLowerCase();
    
    if (lowerMessage.contains('hello') || lowerMessage.contains('hi') || lowerMessage.contains('hey')) {
      return 'Hello! How can I help you with scholarships today?';
    } else if (lowerMessage.contains('scholarship') && lowerMessage.contains('eligibility')) {
      return 'Scholarship eligibility varies by program. Could you specify which scholarship you\'re interested in?';
    } else if (lowerMessage.contains('deadline')) {
      return 'Deadlines vary by scholarship. You can check the specific scholarship details for exact dates.';
    } else if (lowerMessage.contains('thank')) {
      return 'You\'re welcome! Let me know if you have any other questions.';
    } else {
      return 'I\'m here to help with scholarship information. You can ask me about eligibility, deadlines, or application processes.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scholarship Assistant'),
        backgroundColor: Colors.teal,
        elevation: 0,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) => _messages[index],
            ),
          ),
          _buildTextComposer(),
        ],
      ),
    );
  }

  Widget _buildTextComposer() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      child: Row(
        children: <Widget>[
          Flexible(
            child: TextField(
              controller: _messageController,
              onSubmitted: _handleSubmitted,
              decoration: const InputDecoration.collapsed(
                hintText: 'Send a message',
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () => _handleSubmitted(_messageController.text),
          ),
        ],
      ),
    );
  }
}

class ChatMessage extends StatelessWidget {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  const ChatMessage({
    Key? key,
    required this.text,
    required this.isUser,
    required this.timestamp,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(right: 8.0),
            child: CircleAvatar(
              backgroundColor: isUser ? Colors.teal : Colors.grey,
              child: Icon(
                isUser ? Icons.person : Icons.school,
                color: Colors.white,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  isUser ? 'You' : 'Scholarship Bot',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 5.0),
                  child: Text(text),
                ),
                Text(
                  '${timestamp.hour}:${timestamp.minute} ${timestamp.hour >= 12 ? 'PM' : 'AM'}' ,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 10.0,
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