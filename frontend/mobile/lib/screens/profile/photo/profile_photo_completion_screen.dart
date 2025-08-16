import 'package:flutter/material.dart';
import 'dart:io';
import '../../../widgets/bottom_navigation_bar.dart';

class ProfilePhotoCompletionScreen extends StatelessWidget {
  final File? selectedImage;

  const ProfilePhotoCompletionScreen({super.key, this.selectedImage});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF525252)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Gov Portal',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF171717),
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Container(
              width: 47,
              height: 47,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: const DecorationImage(
                  image: AssetImage('assets/images/home_chatbot_avatar.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(19.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              // Profile avatar with edit button
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 122.89,
                      height: 122.89,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                      child: CircleAvatar(
                        radius: 59,
                        backgroundColor: const Color(0xFF384455),
                        backgroundImage:
                            selectedImage != null
                                ? FileImage(selectedImage!)
                                : const AssetImage(
                                      'assets/images/profile_avatar.png',
                                    )
                                    as ImageProvider,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 25,
                        height: 23,
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.75),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.edit,
                          color: Color(0xFFFF5B00),
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Center(
                child: Text(
                  'John Doe',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              const Text(
                'Personal Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 18),
              // Action buttons
              _buildActionButton(
                icon: Icons.bookmark,
                iconColor: const Color(0xFF8C1F28),
                title: 'My Booking',
                onTap: () {},
              ),
              const SizedBox(height: 12),
              _buildActionButton(
                icon: Icons.history,
                iconColor: const Color(0xFF4E6E63),
                title: 'Past Bookings',
                onTap: () {},
              ),
              const SizedBox(height: 12),
              _buildActionButton(
                icon: Icons.assignment_outlined,
                iconColor: const Color(0xFFFF5B00),
                title: 'Complete Your Incomplete Bookings',
                onTap: () {},
              ),
              const SizedBox(height: 30),
              const Text(
                'Personal Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 20),
              // Personal information form
              _buildFormField(
                label: 'Name',
                value: 'John Doe',
                isEditable: true,
              ),
              const SizedBox(height: 16),
              _buildFormField(
                label: 'NIC Number',
                value: '123456789V',
                isEditable: false,
              ),
              const SizedBox(height: 16),
              _buildFormField(
                label: 'Phone Number',
                value: '+94 77 123 4567',
                isEditable: false,
              ),
              const SizedBox(height: 16),
              _buildFormField(
                label: 'Email',
                value: 'john.doe@email.com',
                isEditable: false,
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(
        currentPage: 'settings',
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color iconColor,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E5E5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 1),
            blurRadius: 2,
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: iconColor,
            borderRadius: BorderRadius.circular(2),
          ),
          child: Icon(icon, color: Colors.white, size: 12),
        ),
        title: Text(
          title,
          style: const TextStyle(fontSize: 16, color: Color(0xFF171717)),
        ),
        trailing: const Icon(Icons.chevron_right, color: Color(0xFFA3A3A3)),
        onTap: onTap,
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
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
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
                    fontSize: 16,
                    color:
                        isEditable
                            ? const Color(0xFF1F2937)
                            : const Color(0xFF4B5563),
                  ),
                ),
              ),
              if (isEditable)
                const Icon(Icons.edit, color: Color(0xFFFF5B00), size: 16),
            ],
          ),
        ),
      ],
    );
  }
}
