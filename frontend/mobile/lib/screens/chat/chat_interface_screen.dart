import 'package:flutter/material.dart';
import '../../widgets/chatbot_overlay.dart';

class ChatInterfaceScreen extends StatefulWidget {
  final String? initialMessage;

  const ChatInterfaceScreen({super.key, this.initialMessage});

  @override
  State<ChatInterfaceScreen> createState() => _ChatInterfaceScreenState();
}

class _ChatInterfaceScreenState extends State<ChatInterfaceScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<ChatMessage> messages = [];

  @override
  void initState() {
    super.initState();
    if (widget.initialMessage != null && widget.initialMessage!.isNotEmpty) {
      messages.add(
        ChatMessage(
          text: widget.initialMessage!,
          isUser: true,
          timestamp: DateTime.now(),
        ),
      );

      // Simulate chatbot response
      Future.delayed(const Duration(milliseconds: 1500), () {
        _addBotResponse(widget.initialMessage!);
      });
    }
  }

  void _addBotResponse(String userMessage) {
    String botResponse = _generateBotResponse(userMessage);

    setState(() {
      messages.add(
        ChatMessage(
          text: botResponse,
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
    });

    _scrollToBottom();
  }

  String _generateBotResponse(String userMessage) {
    String lowerMessage = userMessage.toLowerCase();

    // Passport application response
    if (lowerMessage.contains('passport')) {
      return """**Passport Application Process in Sri Lanka**

To apply for a new passport in Sri Lanka, follow these steps:

**Required Documents:**
• Completed passport application form
• Original birth certificate
• National Identity Card (NIC)
• Two recent passport-size photographs
• Previous passport (if renewing)

**Application Process:**
1. **Online Application**: Visit the Department of Immigration & Emigration website
2. **Document Submission**: Submit required documents at any regional passport office
3. **Biometric Data**: Provide fingerprints and digital photograph
4. **Payment**: Pay the applicable fees (varies by passport type)
5. **Collection**: Collect your passport after processing (7-10 working days)

**Fees:**
• Standard passport: Rs. 3,500
• Express service: Rs. 7,500

Would you like information about specific passport offices or online application procedures?""";
    }

    // Birth certificate response
    if (lowerMessage.contains('birth certificate')) {
      return """**Birth Certificate Application Requirements**

To obtain a birth certificate in Sri Lanka, you need:

**Required Documents:**
• Completed application form (available at Registrar General's Department)
• Original hospital discharge summary or midwife certificate
• Parents' National Identity Cards
• Marriage certificate of parents (if applicable)
• Two witnesses with NIC copies

**Application Process:**
1. **Visit Registrar's Office**: Go to the divisional registrar where birth occurred
2. **Submit Application**: Complete form with required documents
3. **Verification**: Officers verify the submitted documents
4. **Payment**: Pay the prescribed fees
5. **Collection**: Certificate issued immediately or within 1-2 days

**Fees:**
• Birth certificate: Rs. 100
• Certified copy: Rs. 25

**Online Services:**
You can also apply online through the Registrar General's Department website for faster processing.

Need help with a specific situation or location?""";
    }

    // Driving license response
    if (lowerMessage.contains('driving license')) {
      return """**Driving License Renewal - Online Process**

You can renew your Sri Lankan driving license online through the Department of Motor Traffic (DMT):

**Online Renewal Requirements:**
• Valid NIC or passport
• Current driving license number
• Medical certificate (if over 55 years)
• Recent passport-size photograph
• Payment method (credit/debit card or bank transfer)

**Step-by-Step Process:**
1. **Visit DMT Website**: Go to www.transport.gov.lk
2. **Create Account**: Register with your NIC details
3. **Upload Documents**: Submit required documents digitally
4. **Medical Test**: Schedule or upload medical certificate
5. **Payment**: Pay renewal fees online
6. **Home Delivery**: New license delivered to your address

**Renewal Fees:**
• Motor car license: Rs. 2,000
• Motorcycle license: Rs. 1,000
• Heavy vehicle license: Rs. 3,000

**Processing Time:**
• Online: 3-5 working days
• Home delivery: Additional 2-3 days

You can also visit any DMT office for in-person renewal. Would you like details about DMT office locations?""";
    }

    // Visa processing response (existing)
    if (lowerMessage.contains('visa') || lowerMessage.contains('form')) {
      return """**Sri Lankan Visa Application Forms**

Sri Lanka offers several types of visas, each with its own set of application forms depending on the purpose and duration of stay.

**1. Visit Visa**
Sri Lanka provides visit visa forms for tourists, business travelers, and short-term visitors. These can be applied for using the Tourist Visa, Business Visa, or Short-Term Visit Visa forms via the ETA system or embassies.

**2. Residence Visas**
Residence visa forms are used for long-term stays such as family reunification, religious work, or NGO involvement. Applicants may also need visa extension forms or ministry recommendation letters depending on their purpose.

**3. Student & Work Visas**
Students and foreign employees must use the Student Visa or Employment Visa forms, often requiring sponsorship or institutional support. Special forms also exist for internships and research-based visits.

If you need to access a form mention the name or to access Immigration and Emigration related reports click the below button.""";
    }

    return "Thank you for your question. How can I assist you with government services today?";
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

    // Simulate bot response delay
    Future.delayed(const Duration(milliseconds: 1500), () {
      _addBotResponse(userMessage);
    });
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
              itemCount:
                  messages.length +
                  (messages.isNotEmpty ? 1 : 0), // +1 for additional sections
              itemBuilder: (context, index) {
                if (index < messages.length) {
                  return _buildMessageBubble(messages[index]);
                } else {
                  // Additional sections (buttons, feedback, etc.)
                  return _buildAdditionalSections();
                }
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

      // Floating Action Button
      floatingActionButton: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFF262626),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: () {
              showDialog(
                context: context,
                barrierDismissible: true,
                barrierColor: Colors.transparent,
                builder: (BuildContext context) {
                  return const ChatbotOverlay();
                },
              );
            },
            child: const Center(
              child: Icon(
                Icons.chat_bubble_outline,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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
                  children: [
                    Text(
                      message.text,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF1F2937),
                        height: 1.64,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalSections() {
    if (messages.isEmpty || !messages.any((m) => !m.isUser)) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        // Action buttons section
        Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              // Feedback section
              const Text(
                'Was this response helpful?',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF374151),
                ),
              ),

              const SizedBox(height: 16),

              // Yes/No buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildFeedbackButton('Yes', true),
                  const SizedBox(width: 12),
                  _buildFeedbackButton('No', false),
                ],
              ),

              const SizedBox(height: 16),

              // Helpful count
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.thumb_up,
                    size: 14,
                    color: Color(0xFF6B7280),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    '180 users found this helpful',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF6B7280),
                      height: 1.43,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Quick action buttons
        _buildQuickActionButtons(),

        const SizedBox(height: 24),

        // Immigration department button
        _buildImmigrationDepartmentButton(),

        const SizedBox(height: 24),

        // People also ask section
        _buildPeopleAlsoAskSection(),

        const SizedBox(height: 100), // Space for bottom navigation
      ],
    );
  }

  Widget _buildFeedbackButton(String text, bool isPositive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPositive ? Icons.thumb_up : Icons.thumb_down,
            size: 14,
            color:
                isPositive ? const Color(0xFF22C55E) : const Color(0xFFEF4444),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xFF4B5563),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButtons() {
    final buttons = [
      'Tourist Visa Form',
      'Business Visa Form',
      'Visa Extension Form',
      'More',
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children:
          buttons
              .map(
                (text) => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF5B00),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Text(
                    text,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.55,
                    ),
                  ),
                ),
              )
              .toList(),
    );
  }

  Widget _buildImmigrationDepartmentButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFF5B00),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        children: [
          Expanded(
            child: Text(
              'Immigration and\nEmigration Department',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                height: 1.55,
              ),
            ),
          ),
          Text(
            '→',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 0.71,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeopleAlsoAskSection() {
    final questions = [
      'How can I apply for a Sri Lankan visa online?',
      'What documents are required for a residence visa in Sri Lanka?',
      'What are the latest mobile app trends?',
      'How to test mobile apps effectively?',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'People also ask',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2937),
            height: 1.56,
          ),
        ),

        const SizedBox(height: 16),

        ...questions
            .map(
              (question) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        question,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF1F2937),
                          height: 1.43,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.keyboard_arrow_down,
                      size: 12,
                      color: Color(0xFF9CA3AF),
                    ),
                  ],
                ),
              ),
            )
            ,
      ],
    );
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
            onTap: () {},
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
