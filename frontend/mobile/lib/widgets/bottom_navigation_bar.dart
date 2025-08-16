import 'package:flutter/material.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final String currentPage;

  const CustomBottomNavigationBar({super.key, required this.currentPage});

  @override
  Widget build(BuildContext context) {
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
            context: context,
            icon: Icons.home,
            label: 'Home',
            isSelected: currentPage == 'home',
            onTap: () {
              if (currentPage != 'home') {
                Navigator.pushReplacementNamed(context, '/home_signed_in');
              }
            },
          ),
          _buildNavItem(
            context: context,
            icon: Icons.search,
            label: 'Search',
            isSelected: currentPage == 'search',
            onTap: () {
              if (currentPage != 'search') {
                Navigator.pushNamed(context, '/navigation_search');
              }
            },
          ),
          _buildNavItem(
            context: context,
            icon: Icons.notifications,
            label: 'Notification',
            isSelected: currentPage == 'notifications',
            onTap: () {
              if (currentPage != 'notifications') {
                Navigator.pushNamed(context, '/notifications');
              }
            },
          ),
          _buildNavItem(
            context: context,
            icon: Icons.settings,
            label: 'Settings',
            isSelected: currentPage == 'settings',
            onTap: () {
              if (currentPage != 'settings') {
                Navigator.pushNamed(context, '/settings');
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
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
