import 'package:flutter/material.dart';
import '../../core/services/message_log_service.dart';

class GovernmentAssistantScreen extends StatefulWidget {
  const GovernmentAssistantScreen({super.key});

  @override
  State<GovernmentAssistantScreen> createState() =>
      _GovernmentAssistantScreenState();
}

class _GovernmentAssistantScreenState extends State<GovernmentAssistantScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  List<MessageLog> _recentMessages = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });
    _fetchRecentMessages();
  }

  Future<void> _fetchRecentMessages() async {
    try {
      final service = MessageLogService();
      final messages = await service.fetchLatestMessages();
      setState(() {
        _recentMessages = messages;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _sendMessage(String message) {
    if (message.trim().isEmpty) return;

    // Navigate to chat interface with the message
    Navigator.pushNamed(context, '/chat_interface', arguments: message);
  }

  void _selectQuestion(String question) {
    _sendMessage(question);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
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
            height: 104,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Color(0xFFE5E5E5), width: 1),
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Back button
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 33.5,
                        height: 33.5,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Color(0xFF171717),
                          size: 18,
                        ),
                      ),
                    ),

                    // Gov Portal logo and text
                    Row(
                      children: [
                        Container(
                          width: 47,
                          height: 47,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image: const DecorationImage(
                              image: AssetImage(
                                'assets/images/gov_portal_logo.png',
                              ),
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
                      ],
                    ),

                    // User icon with online indicator
                    Stack(
                      children: [
                        Container(
                          width: 35,
                          height: 35,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF384455),
                          ),
                          child: ClipOval(
                            child: Container(
                              decoration: const BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage(
                                    'assets/images/avatar_image-56586a.png',
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 13,
                            height: 13,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF27D79E),
                              border: Border.all(color: Colors.white, width: 3),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Search section
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(17),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE5E5E5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search input and send button
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 38,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFD4D4D4)),
                        ),
                        child: TextField(
                          controller: _searchController,
                          focusNode: _searchFocusNode,
                          decoration: const InputDecoration(
                            hintText: '',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF000000),
                            height: 1.43,
                          ),
                          onSubmitted: _sendMessage,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => _sendMessage(_searchController.text),
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
              ],
            ),
          ),

          // Search for section
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Search for',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF000000),
                      height: 1.33,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Recent questions list
                  Expanded(
                    child: _isLoading
                        ? Center(child: CircularProgressIndicator())
                        : _error != null
                            ? Center(child: Text('Error: $_error'))
                            : _recentMessages.isEmpty
                                ? Center(child: Text('No recent questions found.'))
                                : ListView.separated(
                                    itemCount: _recentMessages.length,
                                    separatorBuilder: (context, index) => Container(
                                      height: 1,
                                      margin: const EdgeInsets.symmetric(vertical: 8),
                                      color: const Color(0xFFFF5B00).withOpacity(0.26),
                                    ),
                                    itemBuilder: (context, index) {
                                      final msg = _recentMessages[index];
                                      return _buildQuestionItem(msg.message);
                                    },
                                  ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionItem(String question) {
    return GestureDetector(
      onTap: () => _selectQuestion(question),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 3),
        child: Row(
          children: [
            Expanded(
              child: Text(
                '   $question',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF404040),
                  height: 1.21,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Transform.rotate(
              angle: 0,
              child: const Icon(
                Icons.keyboard_arrow_right,
                color: Color(0xFF85A3BB),
                size: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
