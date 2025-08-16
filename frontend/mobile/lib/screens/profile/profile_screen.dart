import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import '../../providers/user_provider.dart';
import '../../widgets/bottom_navigation_bar.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  final File? profileImage;

  const ProfileScreen({super.key, this.profileImage});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch user profile when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(userProvider.notifier).fetchUserProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userProvider);
    final user = userState.user;
    final isLoading = userState.isLoading;
    final error = userState.error;

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
            height: 104,
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
                  children: [
                    // Back button
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(
                        Icons.arrow_back_ios,
                        color: Color(0xFF525252),
                        size: 18,
                      ),
                    ),

                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Gov Portal logo
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
                    ),

                    const SizedBox(width: 24), // Balance the back button
                  ],
                ),
              ],
            ),
          ),

          // Main content
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await ref.read(userProvider.notifier).fetchUserProfile();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    const SizedBox(height: 24),

                    // Profile avatar and name
                    Column(
                      children: [
                        // Avatar with edit button
                        Stack(
                          children: [
                            Container(
                              width: 122.89,
                              height: 122.89,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 3,
                                ),
                              ),
                              child: ClipOval(
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF384455),
                                  ),
                                  child:
                                      widget.profileImage != null
                                          ? Image.file(
                                            widget.profileImage!,
                                            fit: BoxFit.cover,
                                            width: 122.89,
                                            height: 122.89,
                                          )
                                          : const Icon(
                                            Icons.person,
                                            size: 68,
                                            color: Color(0xFF809FB8),
                                          ),
                                ),
                              ),
                            ),
                            Positioned(
                              right: 10,
                              bottom: 10,
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    '/profile_photo_upload',
                                  );
                                },
                                child: Container(
                                  width: 25,
                                  height: 23,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.withOpacity(0.75),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.edit,
                                    size: 15,
                                    color: Color(0xFFFF5B00),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 15),

                        // User name
                        Text(
                          isLoading
                              ? 'Loading...'
                              : (user?.fullName ?? 'Unknown User'),
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1F2937),
                            height: 1.17,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),

                    // Show error if any
                    if (error != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: Colors.red.shade600,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Error loading profile',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.red.shade800,
                                      ),
                                    ),
                                    Text(
                                      error,
                                      style: TextStyle(
                                        color: Colors.red.shade700,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  ref
                                      .read(userProvider.notifier)
                                      .fetchUserProfile();
                                },
                                icon: Icon(
                                  Icons.refresh,
                                  color: Colors.red.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    if (error != null) const SizedBox(height: 24),

                    // Personal Information title
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 19),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Personal Information',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1F2937),
                            height: 1.56,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Action buttons section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          _buildActionButton(
                            icon: Icons.bookmark,
                            iconColor: const Color(0xFF8C1F28),
                            title: 'My Booking',
                            onTap: () {
                              Navigator.pushNamed(context, '/my_bookings');
                            },
                          ),
                          const SizedBox(height: 12),
                          _buildActionButton(
                            icon: Icons.history,
                            iconColor: const Color(0xFF4E6E63),
                            title: 'Past Bookings',
                            onTap: () {
                              Navigator.pushNamed(context, '/past_bookings');
                            },
                          ),
                          const SizedBox(height: 12),
                          _buildActionButton(
                            icon: Icons.assignment,
                            iconColor: const Color(0xFFFF5B00),
                            title: 'Complete Your Incomplete Bookings',
                            onTap: () {
                              Navigator.pushNamed(context, '/my_bookings');
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Personal Information section
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 19),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Personal Information',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1F2937),
                            height: 1.56,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Form fields
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          _buildFormField(
                            label: 'Name',
                            value:
                                isLoading
                                    ? 'Loading...'
                                    : (user?.fullName ?? 'Not available'),
                            isEditable: true,
                          ),
                          const SizedBox(height: 16),
                          _buildFormField(
                            label: 'NIC Number',
                            value:
                                isLoading
                                    ? 'Loading...'
                                    : (user?.nicNo ?? 'Not available'),
                            isEditable: false,
                          ),
                          const SizedBox(height: 16),
                          _buildFormField(
                            label: 'Phone Number',
                            value:
                                isLoading
                                    ? 'Loading...'
                                    : (user?.phoneNo ?? 'Not available'),
                            isEditable: false,
                          ),
                          const SizedBox(height: 16),
                          _buildFormField(
                            label: 'Email',
                            value:
                                isLoading
                                    ? 'Loading...'
                                    : (user?.email ?? 'Not available'),
                            isEditable: false,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 100), // Space for bottom navigation
                  ],
                ),
              ),
            ),
          ),
        ],
      ),

      // Bottom Navigation
      bottomNavigationBar: const CustomBottomNavigationBar(currentPage: 'home'),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color iconColor,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 58,
        padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 17),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE5E5E5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: iconColor),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF171717),
                  height: 1.5,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: Color(0xFFA3A3A3),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required String value,
    required bool isEditable,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF374151),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 8),
        // Input field
        Container(
          width: double.infinity,
          height: isEditable ? 50 : 48,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: isEditable ? Colors.white : const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isEditable ? const Color(0xFFD1D5DB) : Colors.transparent,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color:
                        isEditable
                            ? const Color(0xFF1F2937)
                            : const Color(0xFF4B5563),
                    height: 1.5,
                  ),
                ),
              ),
              if (isEditable)
                const Icon(Icons.edit, size: 16, color: Color(0xFFFF5B00)),
            ],
          ),
        ),
      ],
    );
  }
}
