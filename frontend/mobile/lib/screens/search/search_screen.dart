import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<SearchResult> _searchResults = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _searchFocusNode.requestFocus();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    // Simulate search delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _searchResults = _getSearchResults(query);
          _isSearching = false;
        });
      }
    });
  }

  void _navigateToChat(String query) {
    if (query.trim().isEmpty) return;

    // Navigate to chat interface with the search query
    Navigator.pushNamed(context, '/chat_interface', arguments: query.trim());
  }

  List<SearchResult> _getSearchResults(String query) {
    final allServices = [
      SearchResult(
        title: 'National Identity Card (NIC)',
        description: 'Apply for or renew your National Identity Card',
        category: 'Public Administration',
        route: '/immigration_emigration',
      ),
      SearchResult(
        title: 'Passport Application',
        description: 'Apply for new passport or renew existing one',
        category: 'Public Administration',
        route: '/immigration_emigration',
      ),
      SearchResult(
        title: 'Birth Certificate',
        description: 'Apply for birth certificate or obtain duplicates',
        category: 'Public Administration',
        route: '/immigration_emigration',
      ),
      SearchResult(
        title: 'Marriage Certificate',
        description: 'Register marriage or obtain marriage certificate',
        category: 'Public Administration',
        route: '/immigration_emigration',
      ),
      SearchResult(
        title: 'Driving License',
        description: 'Apply for driving license or renew existing one',
        category: 'Transport',
        route: '/ministry_transport',
      ),
      SearchResult(
        title: 'Medical Appointment',
        description: 'Book medical appointment for driving license',
        category: 'Transport',
        route: '/driving_license_medical_appointment',
      ),
      SearchResult(
        title: 'Police Report',
        description: 'File police reports or check case status',
        category: 'Public Security',
        route: '/ministry_public_security',
      ),
      SearchResult(
        title: 'Emergency Services',
        description: 'Contact emergency services and get help',
        category: 'Public Security',
        route: '/ministry_public_security',
      ),
      SearchResult(
        title: 'Business Registration',
        description: 'Register new business or update existing registration',
        category: 'Finance & Planning',
        route: '/government_sectors',
      ),
      SearchResult(
        title: 'Tax Services',
        description: 'File taxes, pay taxes, and get tax information',
        category: 'Finance & Planning',
        route: '/government_sectors',
      ),
      SearchResult(
        title: 'Hospital Appointments',
        description: 'Book appointments at government hospitals',
        category: 'Health',
        route: '/government_sectors',
      ),
      SearchResult(
        title: 'Medical Records',
        description: 'Access your medical records and health history',
        category: 'Health',
        route: '/government_sectors',
      ),
    ];

    return allServices
        .where(
          (service) =>
              service.title.toLowerCase().contains(query.toLowerCase()) ||
              service.description.toLowerCase().contains(query.toLowerCase()) ||
              service.category.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
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

          // Header with search
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Color(0xFFE5E5E5), width: 1),
              ),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.arrow_back,
                      color: Color(0xFF171717),
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    height: 40,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE5E5E5)),
                    ),
                    child: TextField(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      onChanged: _performSearch,
                      onSubmitted: _navigateToChat,
                      decoration: const InputDecoration(
                        hintText: 'Search government services...',
                        hintStyle: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF737373),
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        prefixIcon: Icon(
                          Icons.search,
                          color: Color(0xFF737373),
                          size: 20,
                        ),
                      ),
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF171717),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _navigateToChat(_searchController.text),
                  child: Container(
                    width: 40,
                    height: 40,
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

          // Search results
          Expanded(child: _buildSearchResults()),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_searchController.text.trim().isEmpty) {
      return _buildEmptySearch();
    }

    if (_isSearching) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFFF5B00)),
      );
    }

    if (_searchResults.isEmpty) {
      return _buildNoResults();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final result = _searchResults[index];
        return _buildSearchResultCard(result);
      },
    );
  }

  Widget _buildEmptySearch() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(40),
            ),
            child: const Icon(Icons.search, color: Color(0xFF737373), size: 40),
          ),
          const SizedBox(height: 16),
          const Text(
            'Search for government services',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF171717),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Type in the search box above to find services,\ndocuments, and government departments',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xFF737373),
              height: 1.43,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          const Text(
            'Or ask our AI assistant anything:',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF525252),
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => _navigateToChat('How can I apply for a passport?'),
            child: _buildQuickChatOption('How can I apply for a passport?'),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => _navigateToChat('What documents do I need for NIC?'),
            child: _buildQuickChatOption('What documents do I need for NIC?'),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => _navigateToChat('How to book medical appointment?'),
            child: _buildQuickChatOption('How to book medical appointment?'),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickChatOption(String question) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 32),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E5E5)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.chat_bubble_outline,
            color: Color(0xFFFF5B00),
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              question,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: Color(0xFF404040),
              ),
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios,
            color: Color(0xFF737373),
            size: 12,
          ),
        ],
      ),
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(40),
            ),
            child: const Icon(
              Icons.search_off,
              color: Color(0xFF737373),
              size: 40,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No results found',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF171717),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try searching for "${_searchController.text}" with different keywords',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xFF737373),
              height: 1.43,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResultCard(SearchResult result) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E5E5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  result.title,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF171717),
                    height: 1.25,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            result.description,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xFF525252),
              height: 1.43,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  result.category,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF525252),
                  ),
                ),
              ),
              const Spacer(),
              // Chat button
              GestureDetector(
                onTap: () => _navigateToChat('Tell me about ${result.title}'),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF5B00),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.chat_bubble_outline,
                        color: Colors.white,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'Ask',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Navigate button
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, result.route),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFE5E5E5)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.arrow_forward,
                        color: Color(0xFF525252),
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'Go',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF525252),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class SearchResult {
  final String title;
  final String description;
  final String category;
  final String route;

  SearchResult({
    required this.title,
    required this.description,
    required this.category,
    required this.route,
  });
}
