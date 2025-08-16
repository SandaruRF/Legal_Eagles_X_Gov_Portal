import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/environment_config.dart';
import '../../models/api_response.dart';

class MessageLog {
  final String message;
  final String response;

  MessageLog({required this.message, required this.response});

  factory MessageLog.fromJson(Map<String, dynamic> json) {
    return MessageLog(
      message: json['message'] ?? '',
      response: json['response'] ?? '',
    );
  }
}

class MessageLogService {
  static const String _latestMessagesEndpoint = '/api/knowledge-base/latest-messages';

  Future<List<MessageLog>> fetchLatestMessages() async {
    final url = Uri.parse('${EnvironmentConfig.baseUrl}$_latestMessagesEndpoint');
    final response = await http.get(url, headers: EnvironmentConfig.headers);
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => MessageLog.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load latest messages');
    }
  }
}
