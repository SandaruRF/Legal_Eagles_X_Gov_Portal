import '../../models/api_response.dart';
import 'http_client_service.dart';

class ChatbotOverlayService {
  static final ChatbotOverlayService _instance =
      ChatbotOverlayService._internal();
  factory ChatbotOverlayService() => _instance;
  ChatbotOverlayService._internal();

  final HttpClientService _httpClient = HttpClientService();

  /// Search for help using the knowledge base
  Future<ApiResponse<String>> searchForHelp({
    required String text,
    required String page,
    int limit = 5,
  }) async {
    try {
      // Convert page name to lowercase as required by backend
      final lowercasePage = page.toLowerCase();
      print('Searching knowledge base for: $text on page: $lowercasePage');

      final response = await _httpClient.post(
        '/api/knowledge-base/search_for_help',
        body: {'text': text, 'page': lowercasePage, 'limit': limit},
      );

      print('Knowledge base search response: ${response.data}');
      print('Response success: ${response.success}');
      print('Response data type: ${response.data.runtimeType}');

      if (response.success && response.data != null) {
        // Clean up the response text
        String responseText = response.data.toString();

        // Remove surrounding quotes if present
        if (responseText.startsWith('"') && responseText.endsWith('"')) {
          responseText = responseText.substring(1, responseText.length - 1);
        }

        // Convert \n to actual line breaks and clean up
        responseText = responseText.replaceAll('\\n', '\n').trim();

        return ApiResponse<String>.success(
          data: responseText,
          message: 'Help information retrieved successfully',
        );
      } else {
        return ApiResponse<String>.error(
          message:
              response.message.isNotEmpty
                  ? response.message
                  : 'Failed to get help information',
        );
      }
    } catch (e) {
      print('Error searching knowledge base: $e');
      return ApiResponse<String>.error(
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  /// Get a fallback response when API is not available
  String getFallbackResponse(String userMessage) {
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
}
