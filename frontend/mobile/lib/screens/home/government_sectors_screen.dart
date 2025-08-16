import 'package:flutter/material.dart';
import '../../widgets/chatbot_overlay.dart';
import '../../widgets/bottom_navigation_bar.dart';

class GovernmentSectorsScreen extends StatefulWidget {
  const GovernmentSectorsScreen({super.key});

  @override
  State<GovernmentSectorsScreen> createState() =>
      _GovernmentSectorsScreenState();
}

class _GovernmentSectorsScreenState extends State<GovernmentSectorsScreen> {
  String _selectedSortOption = 'Ascending';
  final List<String> _sortOptions = [
    'Ascending',
    'Descending',
    'Last Used',
    'By Popularity',
  ];

  final List<Map<String, dynamic>> _allSectors = [
    {
      'title': 'Education',
      'description': 'Certificates, Admissions',
      'icon': 'assets/images/government_sectors/education.png',
    },
    {
      'title': 'Employment',
      'description': 'Job Portal, EPF Services',
      'icon': 'assets/images/government_sectors/public_security.png',
    },
    {
      'title': 'Public Security',
      'description': 'Police Services, Emergency',
      'icon': 'assets/images/government_sectors/public_security.png',
    },
    {
      'title': 'Finance & Planning',
      'description': 'Business Registration, Banking',
      'icon': 'assets/images/government_sectors/finance_planning.png',
    },
    {
      'title': 'Public Administration',
      'description': 'Government Services, Records',
      'icon': 'assets/images/government_sectors/public_administration.png',
    },
    {
      'title': 'Healthcare',
      'description': 'Medical Records, Appointments',
      'icon': 'assets/images/government_sectors/healthcare.png',
    },
    {
      'title': 'Health',
      'description': 'Public Health, Wellness',
      'icon': 'assets/images/government_sectors/healthcare.png',
    },
    {
      'title': 'Identity Services',
      'description': 'NIC, Passport, Birth Certificate',
      'icon': 'assets/images/government_sectors/education.png',
    },
    {
      'title': 'Justice & Integration',
      'description': 'Legal Services, Court Records',
      'icon': 'assets/images/government_sectors/justice_integration.png',
    },
    {
      'title': 'Mass Media',
      'description': 'Broadcasting, Information',
      'icon': 'assets/images/government_sectors/mass_media.png',
    },
    {
      'title': 'Foreign Affairs',
      'description': 'Embassy Services, Visa',
      'icon': 'assets/images/government_sectors/foreign_affairs.png',
    },
    {
      'title': 'Agriculture',
      'description': 'Farming Support, Land Records',
      'icon': 'assets/images/government_sectors/agriculture.png',
    },
    {
      'title': 'Women & Child Affairs',
      'description': 'Support Services, Protection',
      'icon': 'assets/images/government_sectors/women_child_affairs.png',
    },
    {
      'title': 'Labour & Employment',
      'description': 'Worker Rights, Job Training',
      'icon': 'assets/images/government_sectors/labour_employment.png',
    },
    {
      'title': 'Disaster Management',
      'description': 'Emergency Response, Safety',
      'icon': 'assets/images/government_sectors/disaster_management.png',
    },
    {
      'title': 'Housing & Urban Development',
      'description': 'Housing Projects, Urban Planning',
      'icon': 'assets/images/government_sectors/housing_urban_development.png',
    },
    {
      'title': 'Transport, Port & Aviation',
      'description': 'Transportation Services, Permits',
      'icon': 'assets/images/government_sectors/transport_port_aviation.png',
    },
  ];

  @override
  void initState() {
    super.initState();
  }

  List<Map<String, dynamic>> get _sortedSectors {
    List<Map<String, dynamic>> sectors = List.from(_allSectors);

    switch (_selectedSortOption) {
      case 'Ascending':
        sectors.sort((a, b) => a['title'].compareTo(b['title']));
        break;
      case 'Descending':
        sectors.sort((a, b) => b['title'].compareTo(a['title']));
        break;
      case 'Last Used':
        // For demo purposes, reverse the list to simulate last used
        sectors = sectors.reversed.toList();
        break;
      case 'By Popularity':
        // For demo purposes, sort by description length as a popularity metric
        sectors.sort(
          (a, b) => b['description'].length.compareTo(a['description'].length),
        );
        break;
    }

    return sectors;
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
            height: 100,
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
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios,
                          color: Color(0xFF525252),
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
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF171717),
                          ),
                        ),
                      ],
                    ),

                    // User icon with online indicator
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/profile');
                      },
                      child: Stack(
                        children: [
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
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              width: 13,
                              height: 13,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFF27D79E),
                                border: Border.all(
                                  color: Colors.white,
                                  width: 3,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Search section
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Search bar
                Container(
                  height: 41,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE3E3E3)),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 12),
                      const Text(
                        'Search here',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFADAEBC),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        width: 20,
                        height: 20,
                        margin: const EdgeInsets.only(right: 8),
                        child: const Icon(
                          Icons.search,
                          color: Color(0xFFFF5B00),
                          size: 20,
                        ),
                      ),
                      Container(
                        width: 29,
                        height: 29,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: PopupMenuButton<String>(
                          icon: const Icon(
                            Icons.tune,
                            color: Color(0xFF666666),
                            size: 18,
                          ),
                          onSelected: (String value) {
                            setState(() {
                              _selectedSortOption = value;
                            });
                          },
                          itemBuilder: (BuildContext context) {
                            return _sortOptions.map((String option) {
                              return PopupMenuItem<String>(
                                value: option,
                                child: Row(
                                  children: [
                                    Icon(
                                      _selectedSortOption == option
                                          ? Icons.check_circle
                                          : Icons.radio_button_unchecked,
                                      color:
                                          _selectedSortOption == option
                                              ? const Color(0xFFFF5B00)
                                              : const Color(0xFF666666),
                                      size: 16,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      option,
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                        color:
                                            _selectedSortOption == option
                                                ? const Color(0xFFFF5B00)
                                                : const Color(0xFF666666),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Sectors list
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 13),
              child: Column(
                children: [
                  // Build sectors in vertical list
                  for (int i = 0; i < _sortedSectors.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 17),
                      child: _buildSectorCard(_sortedSectors[i]),
                    ),

                  const SizedBox(height: 100), // Space for bottom navigation
                ],
              ),
            ),
          ),
        ],
      ),

      // Bottom Navigation
      bottomNavigationBar: const CustomBottomNavigationBar(currentPage: 'home'),

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
                  return const ChatbotOverlay(
                    currentPage: 'Government Sectors',
                  );
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

  Widget _buildSectorCard(Map<String, dynamic> sector) {
    return GestureDetector(
      onTap: () {
        // Navigate to specific ministry page based on sector title
        if (sector['title'] == 'Public Security') {
          Navigator.pushNamed(context, '/ministry_public_security');
        } else if (sector['title'] == 'Transport, Port & Aviation') {
          Navigator.pushNamed(context, '/ministry_transport');
        }
        // Add more navigation cases for other ministries as needed
      },
      child: Container(
        width: double.infinity,
        height: 90,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE5E5E5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 4,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon section
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(width: 1, color: const Color(0xFFFF5B00)),
                ),
                child: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    image: DecorationImage(
                      image: AssetImage(sector['icon']),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // Content section
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      sector['title'],
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF171717),
                        height: 1.21,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      sector['description'],
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF737373),
                        height: 1.21,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Arrow icon
              Container(
                width: 15,
                height: 15,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.43),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.keyboard_arrow_down,
                  color: Color(0xFF809FB8),
                  size: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
