import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:async';
import '../../core/services/kyc_service.dart';
import 'selfie_success_screen.dart';

class SelfieUploadScreen extends ConsumerStatefulWidget {
  final Function(String)? onUploadComplete;

  const SelfieUploadScreen({super.key, this.onUploadComplete});

  @override
  ConsumerState<SelfieUploadScreen> createState() => _SelfieUploadScreenState();
}

enum UploadState { initial, uploading, completed }

class _SelfieUploadScreenState extends ConsumerState<SelfieUploadScreen> {
  UploadState _currentState = UploadState.initial;
  double _uploadProgress = 0.0;
  Timer? _progressTimer;
  File? selectedImage;
  String? uploadedFileName;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _progressTimer?.cancel();
    super.dispose();
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
        _currentState = UploadState.uploading;
        _uploadProgress = 0.0;
      });

      // Start upload to backend
      final kycService = ref.read(kycServiceProvider);

      // Update progress while uploading
      _startProgressSimulation();

      final response = await kycService.uploadSelfie(selectedImage!);

      // Stop progress simulation
      _progressTimer?.cancel();

      if (response.success && response.data != null) {
        setState(() {
          _uploadProgress = 1.0;
          _currentState = UploadState.completed;
        });

        // Call the callback with the uploaded file path
        if (widget.onUploadComplete != null) {
          widget.onUploadComplete!(selectedImage!.path);
        }

        // Show success message and navigate to success screen
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Selfie uploaded successfully!'),
              backgroundColor: Colors.green,
            ),
          );

          // Navigate to success screen after a short delay
          Future.delayed(const Duration(milliseconds: 1500), () {
            if (mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => SelfieSuccessScreen(
                        onUploadComplete: widget.onUploadComplete,
                      ),
                ),
              );
            }
          });
        }
      } else {
        // Handle upload error
        setState(() {
          _currentState = UploadState.initial;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Upload failed: ${response.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      _progressTimer?.cancel();
      setState(() {
        _currentState = UploadState.initial;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Upload failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _deleteUpload() {
    setState(() {
      _currentState = UploadState.initial;
      _uploadProgress = 0.0;
      selectedImage = null;
      uploadedFileName = null;
    });
    _progressTimer?.cancel();
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
    _progressTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        _uploadProgress += 0.02;
      });

      if (_uploadProgress >= 0.95) {
        timer.cancel();
        // Don't complete here, wait for actual API response
      }
    });
  }

  Widget _buildUploadArea() {
    switch (_currentState) {
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
      height: 400,
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color(0xFFE0E0E0),
          width: 2,
          style: BorderStyle.solid,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
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
            child: const Center(
              child: Icon(Icons.person, size: 40, color: Color(0xFF666666)),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Take a selfie or upload from gallery',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Please ensure your face is clearly visible\nMax file size: 10MB',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xFF666666),
            ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _startUpload,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFEB600),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.camera_alt, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'Take Selfie',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              OutlinedButton(
                onPressed: _startUpload,
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFFEB600),
                  side: const BorderSide(color: Color(0xFFFEB600)),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.upload, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'Upload',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUploadingArea() {
    return Container(
      width: double.infinity,
      height: 400,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE0E0E0), width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(60),
            ),
            child: Stack(
              children: [
                const Center(
                  child: Icon(Icons.person, size: 60, color: Color(0xFF666666)),
                ),
                Positioned(
                  bottom: 8,
                  left: 8,
                  right: 8,
                  child: LinearProgressIndicator(
                    value: _uploadProgress,
                    backgroundColor: const Color(0xFFE0E0E0),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFFFEB600),
                    ),
                    minHeight: 4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Uploading Selfie...',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${(_uploadProgress * 100).toInt()}% uploaded',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xFF666666),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedArea() {
    return Container(
      width: double.infinity,
      height: 400,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF4CAF50), width: 2),
        borderRadius: BorderRadius.circular(12),
        color: const Color(0xFFF8FFF8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(60),
              border: Border.all(color: const Color(0xFFE0E0E0)),
            ),
            child: Stack(
              children: [
                const Center(
                  child: Icon(Icons.person, size: 60, color: Color(0xFF666666)),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      color: Color(0xFF4CAF50),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Image.asset(
                        'assets/images/checkmark.png',
                        width: 12,
                        height: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Selfie uploaded successfully!',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF4CAF50),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'File size: 1.8 MB',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xFF666666),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _deleteUpload,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE57373),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/delete_icon.png',
                  width: 16,
                  height: 16,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Delete',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Gov Portal',
          style: TextStyle(
            fontFamily: 'Lexend',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Upload Selfie',
              style: TextStyle(
                fontFamily: 'Lexend',
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Please take a clear selfie or upload a photo where your face is clearly visible',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Color(0xFF666666),
              ),
            ),
            const SizedBox(height: 32),
            _buildUploadArea(),
            const Spacer(),
            if (_currentState == UploadState.completed)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFEB600),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
