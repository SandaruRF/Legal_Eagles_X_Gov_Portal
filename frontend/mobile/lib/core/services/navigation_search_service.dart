import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/environment_config.dart';
import '../../models/api_response.dart';

class NavigationSearchResult {
  final String name;
  final String route;

  NavigationSearchResult({required this.name, required this.route});

  factory NavigationSearchResult.fromJson(Map<String, dynamic> json) {
    return NavigationSearchResult(
      name: json['name'] ?? '',
      route: json['route'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'route': route};
  }
}

class NavigationSearchService {
  static const String _searchEndpoint = '/api/search/search-bar';

  Future<ApiResponse<List<NavigationSearchResult>>> searchNavigation({
    required String query,
  }) async {
    if (query.trim().isEmpty) {
      return ApiResponse.success(message: 'Empty query', data: []);
    }

    try {
      final url = Uri.parse('${EnvironmentConfig.baseUrl}$_searchEndpoint');

      final requestBody = {'q': query.trim()};

      print('Navigation Search Request: $url');
      print('Request Body: ${jsonEncode(requestBody)}');

      final response = await http
          .get(
            url.replace(queryParameters: {'q': query.trim()}),
            headers: EnvironmentConfig.headers,
          )
          .timeout(EnvironmentConfig.receiveTimeout);

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final List<dynamic> jsonResponse = jsonDecode(response.body);

          final results =
              jsonResponse
                  .map(
                    (item) => NavigationSearchResult.fromJson(
                      item as Map<String, dynamic>,
                    ),
                  )
                  .toList();

          return ApiResponse.success(
            message: 'Search completed successfully',
            data: results,
          );
        } catch (e) {
          print('JSON parsing failed for navigation search: $e');
          return ApiResponse.error(
            message: 'Failed to parse search results: $e',
          );
        }
      } else {
        return ApiResponse.error(
          message: 'Search failed with status: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      print('Navigation Search Error: $e');

      // Return local fallback results
      return ApiResponse.success(
        message: 'Using local search results',
        data: _getLocalFallbackResults(query),
      );
    }
  }

  List<NavigationSearchResult> _getLocalFallbackResults(String query) {
    final allRoutes = [
      NavigationSearchResult(
        name: 'Public Security Ministry',
        route: '/ministry_public_security',
      ),
      NavigationSearchResult(
        name: 'Transport Ministry',
        route: '/ministry_transport',
      ),
      NavigationSearchResult(
        name: 'National Transport Medical Institute',
        route: '/national_transport_medical_institute',
      ),
      NavigationSearchResult(
        name: 'Driving License Medical',
        route: '/driving_license_medical_appointment',
      ),
      NavigationSearchResult(
        name: 'Immigration Emigration Ministry',
        route: '/immigration_emigration',
      ),
      NavigationSearchResult(name: 'Notifications', route: '/notifications'),
      NavigationSearchResult(name: 'Digital Vault', route: '/digital_vault'),
      NavigationSearchResult(name: 'My Bookings', route: '/my_bookings'),
      NavigationSearchResult(name: 'Past Bookings', route: '/past_bookings'),
      NavigationSearchResult(
        name: 'Change Password',
        route: '/change_password',
      ),
      NavigationSearchResult(
        name: 'Language Settings',
        route: '/language_settings',
      ),
      NavigationSearchResult(name: 'Chat bot', route: '/chat_interface'),
    ];

    final queryLower = query.toLowerCase();
    return allRoutes
        .where(
          (result) =>
              result.name.toLowerCase().contains(queryLower) ||
              result.route.toLowerCase().contains(queryLower),
        )
        .toList();
  }
}
