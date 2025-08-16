import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/environment_config.dart';
import '../../models/api_response.dart';

class KnowledgeBaseService {
  static const String _searchEndpoint = '/api/knowledge-base/search';

  Future<ApiResponse<List<KnowledgeBaseResult>>> searchKnowledgeBase({
    required String text,
    int limit = 5,
  }) async {
    try {
      final url = Uri.parse('${EnvironmentConfig.baseUrl}$_searchEndpoint');

      final requestBody = {'text': text, 'limit': limit};

      print('Knowledge Base Search Request: $url');
      print('Request Body: ${jsonEncode(requestBody)}');

      final response = await http
          .post(
            url,
            headers: EnvironmentConfig.headers,
            body: jsonEncode(requestBody),
          )
          .timeout(EnvironmentConfig.receiveTimeout);

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          // First try to parse as JSON
          final dynamic jsonResponse = jsonDecode(response.body);

          // Handle different response structures
          List<dynamic> resultsData;
          if (jsonResponse is Map<String, dynamic>) {
            if (jsonResponse.containsKey('results')) {
              resultsData = jsonResponse['results'] as List<dynamic>;
            } else if (jsonResponse.containsKey('data')) {
              final data = jsonResponse['data'];
              if (data is List) {
                resultsData = data;
              } else {
                resultsData = [data];
              }
            } else {
              // If response is a single object, wrap it in a list
              resultsData = [jsonResponse];
            }
          } else if (jsonResponse is List) {
            resultsData = jsonResponse;
          } else {
            resultsData = [jsonResponse];
          }

          final results =
              resultsData
                  .map(
                    (item) => KnowledgeBaseResult.fromJson(
                      item as Map<String, dynamic>,
                    ),
                  )
                  .toList();

          return ApiResponse.success(
            message: 'Search completed successfully',
            data: results,
          );
        } catch (e) {
          // If JSON parsing fails, treat response as plain text
          print('JSON parsing failed, treating as plain text: $e');

          // Create a single result from the plain text response
          final result = KnowledgeBaseResult(
            title: 'Government Services Information',
            content: response.body.replaceAll('"', ''), // Remove any quotes
            category: 'General Information',
          );

          return ApiResponse.success(
            message: 'Search completed successfully',
            data: [result],
          );
        }
      } else {
        final errorMessage = _parseErrorMessage(response.body);
        return ApiResponse.error(
          message: errorMessage,
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      print('Knowledge Base Search Error: $e');
      return ApiResponse.error(
        message: 'Failed to search knowledge base: ${e.toString()}',
      );
    }
  }

  String _parseErrorMessage(String responseBody) {
    try {
      final Map<String, dynamic> errorJson = jsonDecode(responseBody);
      return errorJson['message'] ??
          errorJson['error'] ??
          errorJson['detail'] ??
          'Search failed';
    } catch (e) {
      return 'Search failed';
    }
  }
}

class KnowledgeBaseResult {
  final String title;
  final String content;
  final String? category;
  final double? score;
  final String? id;

  KnowledgeBaseResult({
    required this.title,
    required this.content,
    this.category,
    this.score,
    this.id,
  });

  factory KnowledgeBaseResult.fromJson(Map<String, dynamic> json) {
    return KnowledgeBaseResult(
      title: json['title'] ?? json['name'] ?? 'Untitled',
      content: json['content'] ?? json['description'] ?? json['text'] ?? '',
      category: json['category'] ?? json['type'],
      score: (json['score'] ?? json['relevance'])?.toDouble(),
      id: json['id'] ?? json['_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'category': category,
      'score': score,
      'id': id,
    };
  }
}
