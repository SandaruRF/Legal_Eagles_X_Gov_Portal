import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/theme_provider.dart';

class CustomBottomNavigationBar extends ConsumerWidget {
  final String currentPage;

  const CustomBottomNavigationBar({super.key, required this.currentPage});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeProvider) == ThemeMode.dark;
    final backgroundColor =
        isDarkMode ? const Color(0xFF374151) : const Color(0xFFF2F2F2);
    final borderColor =
        isDarkMode ? const Color(0xFF4B5563) : const Color(0xFFE5E5E5);

    return Container(
      height: 82,
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border(top: BorderSide(color: borderColor, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(
            context: context,
            icon: Icons.home,
            label: 'Home',
            isSelected: currentPage == 'home',
            isDarkMode: isDarkMode,
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
            isDarkMode: isDarkMode,
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
            isDarkMode: isDarkMode,
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
            isDarkMode: isDarkMode,
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
    required bool isDarkMode,
    required VoidCallback onTap,
  }) {
    final inactiveColor =
        isDarkMode ? const Color(0xFF9CA3AF) : const Color(0xFF85A3BB);

    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 24,
            color: isSelected ? const Color(0xFFFF5B00) : inactiveColor,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isSelected ? const Color(0xFFFF5B00) : inactiveColor,
              height: 1.57,
            ),
          ),
        ],
      ),
    );
  }
}
