class ChatbotService {
  static final ChatbotService _instance = ChatbotService._internal();
  factory ChatbotService() => _instance;
  ChatbotService._internal();

  // This service is used for other chatbot functionality
  // For the chatbot overlay, use ChatbotOverlayService instead
}
