import 'package:flutter/material.dart';
import '../../core/services/knowledge_base_service.dart';

class ChatInterfaceScreen extends StatefulWidget {
  final String? initialMessage;

  const ChatInterfaceScreen({super.key, this.initialMessage});

  @override
  State<ChatInterfaceScreen> createState() => _ChatInterfaceScreenState();
}

class _ChatInterfaceScreenState extends State<ChatInterfaceScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final KnowledgeBaseService _knowledgeBaseService = KnowledgeBaseService();

  List<ChatMessage> messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialMessage != null && widget.initialMessage!.isNotEmpty) {
      // Add user's search query
      String userQuery = widget.initialMessage!;

      // If the initial message contains formatted results, extract the original query
      if (userQuery.startsWith("Based on your search for '")) {
        final queryMatch = RegExp(
          r"Based on your search for '([^']+)'",
        ).firstMatch(userQuery);
        if (queryMatch != null) {
          final originalQuery = queryMatch.group(1) ?? userQuery;
          messages.add(
            ChatMessage(
              text: originalQuery,
              isUser: true,
              timestamp: DateTime.now(),
            ),
          );

          // Add bot response with search results
          messages.add(
            ChatMessage(
              text: userQuery,
              isUser: false,
              timestamp: DateTime.now(),
            ),
          );
        } else {
          messages.add(
            ChatMessage(
              text: userQuery,
              isUser: false,
              timestamp: DateTime.now(),
            ),
          );
        }
      } else {
        messages.add(
          ChatMessage(text: userQuery, isUser: true, timestamp: DateTime.now()),
        );

        // Get response from knowledge base API
        _getKnowledgeBaseResponse(userQuery);
      }
    }
  }

  Future<void> _getKnowledgeBaseResponse(String userMessage) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _knowledgeBaseService.searchKnowledgeBase(
        text: userMessage,
        limit: 5,
      );

      String botResponse;
      if (response.success &&
          response.data != null &&
          response.data!.isNotEmpty) {
        // Use the content directly from the first result (which contains the formatted response)
        botResponse = response.data!.first.content;
      } else {
        // Fallback response
        botResponse =
            "I'm sorry, I couldn't find specific information about that. However, I'm here to help with government services in Sri Lanka. You can ask me about:\n\n• Passport applications\n• Birth certificates\n• Driving licenses\n• Visa processes\n• Other government services\n\nPlease feel free to ask about any specific service you need help with.";
      }

      setState(() {
        messages.add(
          ChatMessage(
            text: botResponse,
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
        _isLoading = false;
      });

      _scrollToBottom();
    } catch (e) {
      setState(() {
        messages.add(
          ChatMessage(
            text:
                "I'm experiencing some technical difficulties right now. Please try again in a moment, or feel free to ask about government services like passport applications, driving licenses, or birth certificates.",
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    setState(() {
      messages.add(
        ChatMessage(
          text: _messageController.text.trim(),
          isUser: true,
          timestamp: DateTime.now(),
        ),
      );
    });

    String userMessage = _messageController.text.trim();
    _messageController.clear();

    _scrollToBottom();

    // Get response from knowledge base API
    _getKnowledgeBaseResponse(userMessage);
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Status bar area
          Container(
            height: MediaQuery.of(context).padding.top,
            color: Colors.white,
          ),

          // Header
          Container(
            width: double.infinity,
            height: 62,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Color(0xFFF3F4F6), width: 1),
              ),
            ),
            child: Row(
              children: [
                // Back button
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(color: Colors.transparent),
                    child: const Icon(
                      Icons.arrow_back,
                      color: Color(0xFF374151),
                      size: 18,
                    ),
                  ),
                ),

                const Spacer(),

                // Gov Portal logo and text
                Container(
                  width: 47,
                  height: 47,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: const DecorationImage(
                      image: AssetImage('assets/images/gov_portal_logo.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Gov Portal',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF171717),
                  ),
                ),

                const Spacer(),

                // Profile avatar
                Container(
                  width: 35,
                  height: 35,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF809FB8),
                  ),
                  child: const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),

          // Chat messages area
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == messages.length && _isLoading) {
                  // Show loading indicator
                  return Container(
                    margin: const EdgeInsets.only(top: 8, bottom: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF809FB8),
                          ),
                          child: const Icon(
                            Icons.support_agent,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(18),
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
                                    Color(0xFF809FB8),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Typing...',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return _buildMessageBubble(messages[index]);
              },
            ),
          ),

          // Message input area
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Color(0xFFE5E7EB), width: 1),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: 'Type your message...',
                        hintStyle: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF9CA3AF),
                        ),
                        border: InputBorder.none,
                      ),
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF1F2937),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFF5B00),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.send,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom navigation
          _buildBottomNavigation(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    if (message.isUser) {
      return _buildUserMessage(message);
    } else {
      return _buildBotMessage(message);
    }
  }

  Widget _buildUserMessage(ChatMessage message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFF5B00), Color(0xFFFEB600)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Text(
          message.text,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.white,
            height: 1.625,
          ),
        ),
      ),
    );
  }

  Widget _buildBotMessage(ChatMessage message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Divider
          Container(
            height: 1,
            color: const Color(0xFFE5E7EB),
            margin: const EdgeInsets.only(bottom: 24),
          ),

          // Bot avatar and response
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bot avatar
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: Color(0xFFFF5B00),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.support_agent,
                  color: Colors.white,
                  size: 16,
                ),
              ),

              const SizedBox(width: 12),

              // Response content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [_buildFormattedText(message.text)],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFormattedText(String text) {
    // Split text by \n for line breaks
    final lines = text.split('\\n');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          lines.map((line) {
            if (line.trim().isEmpty) {
              // Empty line - add spacing
              return const SizedBox(height: 8);
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: _buildFormattedLine(line),
            );
          }).toList(),
    );
  }

  Widget _buildFormattedLine(String line) {
    final List<TextSpan> spans = [];
    final RegExp boldPattern = RegExp(r'\*\*(.*?)\*\*');

    int lastIndex = 0;
    for (final match in boldPattern.allMatches(line)) {
      // Add normal text before bold text
      if (match.start > lastIndex) {
        spans.add(
          TextSpan(
            text: line.substring(lastIndex, match.start),
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xFF1F2937),
              height: 1.64,
            ),
          ),
        );
      }

      // Add bold text
      spans.add(
        TextSpan(
          text: match.group(1),
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2937),
            height: 1.64,
          ),
        ),
      );

      lastIndex = match.end;
    }

    // Add remaining normal text
    if (lastIndex < line.length) {
      spans.add(
        TextSpan(
          text: line.substring(lastIndex),
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Color(0xFF1F2937),
            height: 1.64,
          ),
        ),
      );
    }

    // If no bold text found, return simple text
    if (spans.isEmpty) {
      spans.add(
        TextSpan(
          text: line,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Color(0xFF1F2937),
            height: 1.64,
          ),
        ),
      );
    }

    return RichText(text: TextSpan(children: spans));
  }

  Widget _buildBottomNavigation() {
    return Container(
      height: 82,
      decoration: const BoxDecoration(
        color: Color(0xFFF2F2F2),
        border: Border(top: BorderSide(color: Color(0xFFE5E5E5), width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(
            icon: Icons.home,
            label: 'Home',
            isSelected: false,
            onTap:
                () => Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/home_signed_in',
                  (route) => false,
                ),
          ),
          _buildNavItem(
            icon: Icons.search,
            label: 'Search',
            isSelected: false,
            onTap: () => Navigator.pop(context),
          ),
          _buildNavItem(
            icon: Icons.notifications,
            label: 'Notification',
            isSelected: true,
            onTap: () {},
          ),
          _buildNavItem(
            icon: Icons.settings,
            label: 'Settings',
            isSelected: false,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 24,
            color:
                isSelected ? const Color(0xFFFF5B00) : const Color(0xFF85A3BB),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color:
                  isSelected
                      ? const Color(0xFFFF5B00)
                      : const Color(0xFF85A3BB),
              height: 1.57,
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}
