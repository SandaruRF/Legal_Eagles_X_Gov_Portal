import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:async';
import '../../core/services/kyc_service.dart';

class NICFrontUploadScreen extends ConsumerStatefulWidget {
  final Function(String) onUploadComplete;

  const NICFrontUploadScreen({super.key, required this.onUploadComplete});

  @override
  ConsumerState<NICFrontUploadScreen> createState() =>
      _NICFrontUploadScreenState();
}

class _NICFrontUploadScreenState extends ConsumerState<NICFrontUploadScreen> {
  UploadState currentState = UploadState.initial;
  double uploadProgress = 0.0;
  Timer? uploadTimer;
  File? selectedImage;
  String? uploadedFileName;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    uploadTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF525252)),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 47,
              height: 47,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: const DecorationImage(
                  image: AssetImage('assets/images/main_illustration.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Gov Portal',
              style: TextStyle(
                color: Color(0xFF171717),
                fontSize: 16,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 30),

            // Title
            const Text(
              'Upload NIC front view',
              style: TextStyle(
                color: Color(0xFF000000),
                fontSize: 23,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 12),

            // Subtitle
            const Text(
              'Upload a photo of yourself holding your valid ID\nfront view for verification.',
              style: TextStyle(
                color: Color(0xFFADAEBC),
                fontSize: 14,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
                height: 1.71,
              ),
            ),

            const SizedBox(height: 48),

            // Upload Area
            _buildUploadArea(),

            const SizedBox(height: 100),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pop(context),
        backgroundColor: const Color(0xFF262626),
        elevation: 10,
        child: const Icon(Icons.arrow_forward, color: Colors.white, size: 16),
      ),
    );
  }

  Widget _buildUploadArea() {
    switch (currentState) {
      case UploadState.initial:
        return _buildInitialUploadArea();
      case UploadState.uploading:
        return _buildUploadingArea();
      case UploadState.completed:
        return _buildCompletedArea();
    }
  }

  Widget _buildInitialUploadArea() {
    return Container(
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
        mainAxisSize: MainAxisSize.min,
        children: [
          // Upload icon
          Container(
            width: 53,
            height: 53,
            decoration: BoxDecoration(
              color: const Color(0xFF8C1F28),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Icon(
                Icons.cloud_upload_outlined,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            'OR',
            style: TextStyle(
              color: Color(0xFFADAEBC),
              fontSize: 20,
              fontFamily: 'Proxima Nova',
              fontWeight: FontWeight.w400,
              height: 1.2,
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'Tap to upload a photo',
            style: TextStyle(
              color: Color(0xFF000000),
              fontSize: 16,
              fontFamily: 'Proxima Nova',
              fontWeight: FontWeight.w400,
              height: 1.3,
            ),
          ),

          const SizedBox(height: 4),

          const Text(
            'PNG , JPG of PDF (max. 800x400px)',
            style: TextStyle(
              color: Color(0xFFADAEBC),
              fontSize: 13,
              fontFamily: 'Proxima Nova',
              fontWeight: FontWeight.w400,
              height: 1.2,
            ),
          ),

          const SizedBox(height: 16),

          // Divider lines
          Row(
            children: [
              const SizedBox(width: 16),
              Expanded(
                child: Container(height: 1, color: const Color(0xFFADAEBC)),
              ),
              const SizedBox(width: 67),
              Expanded(
                child: Container(height: 1, color: const Color(0xFFADAEBC)),
              ),
              const SizedBox(width: 16),
            ],
          ),

          const SizedBox(height: 25),

          // Open camera button
          InkWell(
            onTap: _startUpload,
            child: Container(
              width: 125,
              height: 29,
              decoration: BoxDecoration(
                color: const Color(0xFF279541),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Center(
                child: Text(
                  'Open camara',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontFamily: 'Proxima Nova',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadingArea() {
    return Container(
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
        mainAxisSize: MainAxisSize.min,
        children: [
          // File icon
          Image.asset('assets/images/file_icon.png', width: 52, height: 52),

          const SizedBox(height: 12),

          Text(
            '${(uploadProgress * 100).toInt()}%',
            style: const TextStyle(
              color: Color(0xFF000000),
              fontSize: 13,
              fontFamily: 'Proxima Nova',
              fontWeight: FontWeight.w700,
              height: 1.3,
            ),
          ),

          const SizedBox(height: 16),

          const Text(
            'Uploading Document....',
            style: TextStyle(
              color: Color(0xFF000000),
              fontSize: 16,
              fontFamily: 'Proxima Nova',
              fontWeight: FontWeight.w400,
              height: 1.3,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            uploadedFileName ?? 'image.jpg',
            style: const TextStyle(
              color: Color(0xFFADAEBC),
              fontSize: 13,
              fontFamily: 'Proxima Nova',
              fontWeight: FontWeight.w400,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedArea() {
    return Container(
      width: double.infinity,
      height: 320,
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
        mainAxisSize: MainAxisSize.min,
        children: [
          // Checkmark
          Image.asset('assets/images/checkmark.png', width: 80, height: 80),

          const SizedBox(height: 16),

          const Text(
            'Upload Complete',
            style: TextStyle(
              color: Color(0xFF000000),
              fontSize: 16,
              fontFamily: 'Proxima Nova',
              fontWeight: FontWeight.w400,
              height: 1.3,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            uploadedFileName ?? 'image.jpg',
            style: const TextStyle(
              color: Color(0xFFADAEBC),
              fontSize: 13,
              fontFamily: 'Proxima Nova',
              fontWeight: FontWeight.w400,
              height: 1.2,
            ),
          ),

          const SizedBox(height: 20),

          // Clear upload button
          InkWell(
            onTap: _clearUpload,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/delete_icon.png',
                  width: 19,
                  height: 19,
                ),
                const SizedBox(width: 14),
                const Text(
                  'Clear Upload',
                  style: TextStyle(
                    color: Color(0xFF000000),
                    fontSize: 16,
                    fontFamily: 'Proxima Nova',
                    fontWeight: FontWeight.w400,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Done button to go back to KYC verification
          InkWell(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: double.infinity,
              height: 48,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFFF5B00),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text(
                  'Done',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontFamily: 'Proxima Nova',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _startUpload() async {
    try {
      // Show image picker options
      final ImageSource? source = await _showImageSourceDialog();
      if (source == null) return;

      // Pick image from selected source
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile == null) return;

      selectedImage = File(pickedFile.path);
      uploadedFileName = pickedFile.name;

      setState(() {
        currentState = UploadState.uploading;
        uploadProgress = 0.0;
      });

      // Start upload to backend
      final kycService = ref.read(kycServiceProvider);

      // Update progress while uploading
      _startProgressSimulation();

      final response = await kycService.uploadNicFront(selectedImage!);

      // Stop progress simulation
      uploadTimer?.cancel();

      if (response.success && response.data != null) {
        setState(() {
          currentState = UploadState.completed;
          uploadProgress = 1.0;
        });

        // Call the callback with the uploaded file path
        widget.onUploadComplete(selectedImage!.path);

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                response.message.isNotEmpty
                    ? response.message
                    : 'NIC front uploaded successfully!',
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        // Handle upload error
        setState(() {
          currentState = UploadState.initial;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                response.message.isNotEmpty
                    ? response.message
                    : 'Upload failed. Please try again.',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      uploadTimer?.cancel();
      setState(() {
        currentState = UploadState.initial;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<ImageSource?> _showImageSourceDialog() async {
    return showDialog<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Image Source'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () => Navigator.of(context).pop(ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () => Navigator.of(context).pop(ImageSource.gallery),
              ),
            ],
          ),
        );
      },
    );
  }

  void _startProgressSimulation() {
    uploadTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        uploadProgress += 0.02;
      });

      if (uploadProgress >= 0.95) {
        timer.cancel();
        // Don't complete here, wait for actual API response
      }
    });
  }

  void _clearUpload() {
    setState(() {
      currentState = UploadState.initial;
      uploadProgress = 0.0;
      selectedImage = null;
      uploadedFileName = null;
    });
  }
}

enum UploadState { initial, uploading, completed }
