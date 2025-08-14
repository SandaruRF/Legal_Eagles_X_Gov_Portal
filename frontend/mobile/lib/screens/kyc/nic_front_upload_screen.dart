import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';

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

          const Text(
            'myIDcard.jpg',
            style: TextStyle(
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

          const Text(
            'myIDcard.jpg',
            style: TextStyle(
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

          // Upload ID Front view button
          Container(
            width: double.infinity,
            height: 48,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFFF5B00),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text(
                'Upload ID Front view',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontFamily: 'Proxima Nova',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _startUpload() {
    setState(() {
      currentState = UploadState.uploading;
      uploadProgress = 0.0;
    });

    // Simulate upload progress
    uploadTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        uploadProgress += 0.02;
      });

      if (uploadProgress >= 1.0) {
        timer.cancel();
        setState(() {
          currentState = UploadState.completed;
        });

        // Call the callback with a simulated image path
        widget.onUploadComplete('assets/images/nic_front_sample.jpg');
      }
    });
  }

  void _clearUpload() {
    setState(() {
      currentState = UploadState.initial;
      uploadProgress = 0.0;
    });
  }
}

enum UploadState { initial, uploading, completed }
