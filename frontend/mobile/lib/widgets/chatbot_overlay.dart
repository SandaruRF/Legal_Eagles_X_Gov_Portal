import 'package:flutter/material.dart';
import '../core/services/chatbot_overlay_service.dart';

class ChatbotOverlay extends StatefulWidget {
  final String currentPage;

  const ChatbotOverlay({super.key, required this.currentPage});

  @override
  State<ChatbotOverlay> createState() => _ChatbotOverlayState();
}

class _ChatbotOverlayState extends State<ChatbotOverlay> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ChatbotOverlayService _chatbotService = ChatbotOverlayService();
  bool _isLoading = false;

  final List<ChatMessage> _messages = [
    ChatMessage(
      text: 'Hello! How can I assist you with your government services today?',
      isBot: true,
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
  ];

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty || _isLoading) return;

    final userMessage = ChatMessage(
      text: _messageController.text.trim(),
      isBot: false,
      timestamp: DateTime.now(),
    );

    final userMessageText = _messageController.text.trim();

    setState(() {
      _messages.add(userMessage);
      _isLoading = true;
    });

    _messageController.clear();
    _scrollToBottom();

    // Call the backend API
    _chatbotService
        .searchForHelp(
          text: userMessageText,
          page: widget.currentPage,
          limit: 5,
        )
        .then((response) {
          String botResponseText;

          if (response.success && response.data != null) {
            botResponseText = response.data!;
          } else {
            // Use fallback response on API failure
            botResponseText = _chatbotService.getFallbackResponse(
              userMessageText,
            );
          }

          final botResponse = ChatMessage(
            text: botResponseText,
            isBot: true,
            timestamp: DateTime.now(),
          );

          setState(() {
            _messages.add(botResponse);
            _isLoading = false;
          });

          _scrollToBottom();
        })
        .catchError((error) {
          // Use fallback response on error
          final botResponse = ChatMessage(
            text: _chatbotService.getFallbackResponse(userMessageText),
            isBot: true,
            timestamp: DateTime.now(),
          );

          setState(() {
            _messages.add(botResponse);
            _isLoading = false;
          });

          _scrollToBottom();
        });
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
                        itemCount: _messages.length + (_isLoading ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == _messages.length && _isLoading) {
                            // Show loading indicator
                            return _buildLoadingBubble();
                          }
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
                                  color: Colors.black,
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
            const SizedBox(width: 8),
            // Bot message
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5E8E8),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: RichText(
                  text: TextSpan(children: _parseMarkdownText(message.text)),
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
                color: Color(0xFF2E2E2E),
              ),
              child: const Icon(Icons.person, color: Colors.white, size: 20),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLoadingBubble() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bot avatar
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFFF5B00),
            ),
            child: ClipOval(
              child: Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/home_chatbot_avatar.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Loading message
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF5E8E8),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFFFF5B00),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Searching...',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    color: Color(0xFF1C0F0D),
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to parse markdown-style bold text
  List<TextSpan> _parseMarkdownText(String text) {
    final List<TextSpan> spans = [];
    final RegExp boldPattern = RegExp(r'\*\*(.*?)\*\*');

    int lastIndex = 0;
    for (final match in boldPattern.allMatches(text)) {
      // Add text before the bold section
      if (match.start > lastIndex) {
        spans.add(
          TextSpan(
            text: text.substring(lastIndex, match.start),
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              color: Color(0xFF1C0F0D),
              height: 1.6,
            ),
          ),
        );
      }

      // Add the bold text (without the ** markers)
      spans.add(
        TextSpan(
          text: match.group(1), // The text inside **
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            color: Color(0xFF1C0F0D),
            height: 1.6,
            fontWeight: FontWeight.bold,
          ),
        ),
      );

      lastIndex = match.end;
    }

    // Add any remaining text after the last bold section
    if (lastIndex < text.length) {
      spans.add(
        TextSpan(
          text: text.substring(lastIndex),
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            color: Color(0xFF1C0F0D),
            height: 1.6,
          ),
        ),
      );
    }

    return spans;
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
