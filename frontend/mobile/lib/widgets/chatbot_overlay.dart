import 'package:flutter/material.dart';

class ChatbotOverlay extends StatefulWidget {
  const ChatbotOverlay({super.key});

  @override
  State<ChatbotOverlay> createState() => _ChatbotOverlayState();
}

class _ChatbotOverlayState extends State<ChatbotOverlay> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [
    ChatMessage(
      text: 'Hello! How can I assist you with your passport application today?',
      isBot: true,
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
  ];

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    final userMessage = ChatMessage(
      text: _messageController.text.trim(),
      isBot: false,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(userMessage);
    });

    _messageController.clear();

    // Simulate bot response
    Future.delayed(const Duration(milliseconds: 800), () {
      final botResponse = ChatMessage(
        text: _getBotResponse(userMessage.text),
        isBot: true,
        timestamp: DateTime.now(),
      );

      setState(() {
        _messages.add(botResponse);
      });

      _scrollToBottom();
    });

    _scrollToBottom();
  }

  String _getBotResponse(String userMessage) {
    final lowerMessage = userMessage.toLowerCase();

    if (lowerMessage.contains('passport')) {
      return 'You will need your National Identity Card (NIC), birth certificate, and any previous passports. For more details, please visit our website.';
    } else if (lowerMessage.contains('document') ||
        lowerMessage.contains('papers')) {
      return 'For passport applications, you typically need: NIC, birth certificate, previous passport (if any), and passport-sized photographs.';
    } else if (lowerMessage.contains('time') ||
        lowerMessage.contains('how long')) {
      return 'Passport processing usually takes 7-14 working days for standard applications. Express service is available for urgent cases.';
    } else if (lowerMessage.contains('fee') ||
        lowerMessage.contains('cost') ||
        lowerMessage.contains('price')) {
      return 'Passport application fees vary based on the type of passport and processing time. Please check our official website for current rates.';
    } else if (lowerMessage.contains('hello') || lowerMessage.contains('hi')) {
      return 'Hello! I\'m here to help you with government services. What can I assist you with today?';
    } else {
      return 'I understand you\'re asking about government services. Could you please be more specific about what you need help with? I can assist with passport applications, documentation, fees, and processing times.';
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        color: const Color(0xFF3C3C3C).withOpacity(0.54),
        child: Stack(
          children: [
            // Background tap to close
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.transparent,
              ),
            ),
            // Chat container
            Center(
              child: Container(
                width: 371,
                height: 648,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Column(
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Color(0xFFE2E2E2)),
                        ),
                      ),
                      child: Row(
                        children: [
                          // Chatbot avatar
                          Stack(
                            children: [
                              Container(
                                width: 48,
                                height: 49,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFFFF5B00),
                                ),
                                child: ClipOval(
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      image: DecorationImage(
                                        image: AssetImage(
                                          'assets/images/home_chatbot_avatar.png',
                                        ),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                right: -4,
                                bottom: -3,
                                child: Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: const Color(0xFFFEB600),
                                      width: 1,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 14),
                          // Title and close button
                          const Expanded(
                            child: Text(
                              'Government Assistant',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF171717),
                              ),
                            ),
                          ),
                          // Close button
                          GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: Container(
                              width: 26,
                              height: 28,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Icon(
                                Icons.close,
                                size: 16,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Messages
                    Expanded(
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final message = _messages[index];
                          return _buildMessageBubble(message);
                        },
                      ),
                    ),
                    // Input area
                    Container(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          // Input field
                          Expanded(
                            child: Container(
                              height: 37,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5F5F5),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: TextField(
                                controller: _messageController,
                                onSubmitted: (_) => _sendMessage(),
                                decoration: const InputDecoration(
                                  hintText: 'Type your message ....',
                                  hintStyle: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 13,
                                    color: Color(0xFFFF5B00),
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 9,
                                  ),
                                ),
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 13,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Send button
                          GestureDetector(
                            onTap: _sendMessage,
                            child: Container(
                              width: 48,
                              height: 38,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF5B00),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.send,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (message.isBot) ...[
            // Bot avatar
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFFF5B00),
              ),
              child: const Icon(Icons.smart_toy, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 8),
            // Bot message
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5E8E8),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  message.text,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    color: Color(0xFF1C0F0D),
                    height: 1.15,
                  ),
                ),
              ),
            ),
          ] else ...[
            // User message (right aligned)
            Expanded(
              child: Row(
                children: [
                  const Spacer(),
                  Flexible(
                    flex: 3,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF5B00),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        message.text,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          color: Colors.white,
                          height: 1.38,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // User avatar
            Container(
              width: 33,
              height: 33,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF000000),
              ),
              child: ClipOval(
                child: Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(
                        'assets/images/home_chatbot_avatar.png', // Use same avatar for now
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isBot;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isBot,
    required this.timestamp,
  });
}
