import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfilePhotoCameraScreen extends StatefulWidget {
  final File? initialImage;

  const ProfilePhotoCameraScreen({super.key, this.initialImage});

  @override
  State<ProfilePhotoCameraScreen> createState() =>
      _ProfilePhotoCameraScreenState();
}

class _ProfilePhotoCameraScreenState extends State<ProfilePhotoCameraScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  bool _showUploadComplete = false;

  @override
  void initState() {
    super.initState();
    _selectedImage = widget.initialImage;
    if (_selectedImage != null) {
      _showUploadComplete = true;
    }
  }

  Future<void> _uploadLicenseFront() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
        _showUploadComplete = true;
      });
    }
  }

  void _clearUpload() {
    setState(() {
      _selectedImage = null;
      _showUploadComplete = false;
    });
  }

  void _updatePhoto() {
    if (_selectedImage != null) {
      // Navigate back to profile screen with the selected image
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
            Container(
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
              child:
                  _showUploadComplete
                      ? Stack(
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Upload Complete',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF000000),
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'mydrivinglicense.jpg',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFFADAEBC),
                                ),
                              ),
                              const SizedBox(height: 20),
                              // Checkmark icon
                              Container(
                                width: 80,
                                height: 80,
                                decoration: const BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage(
                                      'assets/images/checkmark.png',
                                    ),
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      )
                      : Column(
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
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF000000),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'PNG, JPG of PDF (max. 800x400px)',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFFADAEBC),
                            ),
                          ),
                        ],
                      ),
            ),
            if (_showUploadComplete) ...[
              const SizedBox(height: 20),
              // Clear Upload button
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: _clearUpload,
                    child: Row(
                      children: [
                        Container(
                          width: 19,
                          height: 19,
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage(
                                'assets/images/delete_icon.png',
                              ),
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Text(
                          'Clear Upload',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF000000),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 47),
            // Upload License Front view button
            SizedBox(
              width: double.infinity,
              height: 49,
              child: ElevatedButton(
                onPressed: _uploadLicenseFront,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF5B00),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Upload License Front view',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const Spacer(),
            // Update button
            if (_showUploadComplete)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(bottom: 20),
                child: Center(
                  child: GestureDetector(
                    onTap: _updatePhoto,
                    child: const Text(
                      'Update',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF000000),
                      ),
                    ),
                  ),
                ),
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
