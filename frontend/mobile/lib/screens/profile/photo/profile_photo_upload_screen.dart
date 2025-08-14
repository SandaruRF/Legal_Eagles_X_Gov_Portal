import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfilePhotoUploadScreen extends StatefulWidget {
  const ProfilePhotoUploadScreen({super.key});

  @override
  State<ProfilePhotoUploadScreen> createState() =>
      _ProfilePhotoUploadScreenState();
}

class _ProfilePhotoUploadScreenState extends State<ProfilePhotoUploadScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;

  Future<void> _pickFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
      // Navigate directly back to profile screen with the selected image
      Navigator.of(
        context,
      ).popUntil((route) => route.settings.name == '/profile');
      Navigator.pushReplacementNamed(
        context,
        '/profile',
        arguments: _selectedImage,
      );
    }
  }

  Future<void> _openCamera() async {
    Navigator.pushNamed(context, '/profile_photo_camera');
  }

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
      body: Padding(
        padding: const EdgeInsets.all(22.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 30),
            const Text(
              'Upload Your  Profile Photo ',
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
                color: Color(0xFF000000),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Upload a photo of yourself holding your valid driving\nlicense view for verification.',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFFADAEBC),
                height: 1.7,
              ),
            ),
            const SizedBox(height: 42),
            // Upload area with dashed border
            GestureDetector(
              onTap: _pickFromGallery,
              child: Container(
                width: double.infinity,
                height: 286,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(19),
                  border: Border.all(
                    color: const Color(0xFFCBD0DC),
                    width: 3,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.photo_camera_outlined,
                      size: 48,
                      color: Color(0xFFADAEBC),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Tap to upload a photo',
                      style: TextStyle(fontSize: 16, color: Color(0xFF000000)),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'PNG, JPG of PDF (max. 800x400px)',
                      style: TextStyle(fontSize: 13, color: Color(0xFFADAEBC)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 47),
            // Open camera button
            SizedBox(
              width: double.infinity,
              height: 49,
              child: ElevatedButton(
                onPressed: _openCamera,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF5B00),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Open camera',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 28),
            // OR divider
            Row(
              children: [
                Expanded(
                  child: Container(height: 1, color: const Color(0xFFE5E7EB)),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'OR',
                    style: TextStyle(fontSize: 14, color: Color(0xFFADAEBC)),
                  ),
                ),
                Expanded(
                  child: Container(height: 1, color: const Color(0xFFE5E7EB)),
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFF262626),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              offset: const Offset(0, 10),
              blurRadius: 15,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              offset: const Offset(0, 4),
              blurRadius: 6,
            ),
          ],
        ),
        child: const Icon(Icons.chat, color: Colors.white, size: 24),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
