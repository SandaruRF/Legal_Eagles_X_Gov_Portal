import 'package:flutter/material.dart';
import 'dart:async';
import 'selfie_success_screen.dart';

class SelfieUploadProgressScreen extends StatefulWidget {
  final Function(String)? onUploadComplete;

  const SelfieUploadProgressScreen({super.key, this.onUploadComplete});

  @override
  State<SelfieUploadProgressScreen> createState() =>
      _SelfieUploadProgressScreenState();
}

class _SelfieUploadProgressScreenState extends State<SelfieUploadProgressScreen>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;
  late Timer _timer;
  int _progress = 0;

  @override
  void initState() {
    super.initState();

    _progressController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.linear),
    );

    // Start the progress animation
    _progressController.forward();

    // Update progress percentage
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        _progress = (_progressAnimation.value * 100).round();
      });

      if (_progress >= 100) {
        timer.cancel();
        // Navigate to success screen after completion
        Future.delayed(const Duration(milliseconds: 500), () {
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
    });
  }

  @override
  void dispose() {
    _progressController.dispose();
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

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
            width: screenWidth,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Color(0xFFE5E5E5), width: 1),
              ),
            ),
            child: Row(
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
          ),

          // Main content
          Expanded(
            child: Column(
              children: [
                const SizedBox(height: 25),

                // Title
                const Text(
                  'Uploading encrypted 3D\nface scan data',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 23,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF000000),
                    height: 1.04,
                  ),
                ),

                const SizedBox(height: 48),

                // Don't move text
                const Text(
                  'Don\'t move',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFFADAEBC),
                    height: 1.71,
                  ),
                ),

                const SizedBox(height: 54),

                // Progress circle and percentage
                Expanded(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Background circle
                      Container(
                        width: 295,
                        height: 295,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFE0E0E0),
                            width: 3,
                          ),
                        ),
                      ),

                      // Progress circle
                      SizedBox(
                        width: 295,
                        height: 295,
                        child: AnimatedBuilder(
                          animation: _progressAnimation,
                          builder: (context, child) {
                            return CustomPaint(
                              painter: ProgressCirclePainter(
                                progress: _progressAnimation.value,
                                progressColor: const Color(0xFFFF5B00),
                                strokeWidth: 6,
                              ),
                            );
                          },
                        ),
                      ),

                      // Progress percentage
                      Text(
                        '$_progress%',
                        style: const TextStyle(
                          fontFamily: 'Proxima Nova',
                          fontSize: 60,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFFF5B00),
                          height: 1.22,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 100), // Space for floating button
              ],
            ),
          ),
        ],
      ),

      // Chatbot floating action button
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
              // TODO: Open chatbot
              print('Chatbot tapped');
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
}

class ProgressCirclePainter extends CustomPainter {
  final double progress;
  final Color progressColor;
  final double strokeWidth;

  ProgressCirclePainter({
    required this.progress,
    required this.progressColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final progressPaint =
        Paint()
          ..color = progressColor
          ..strokeWidth = strokeWidth
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;

    // Draw progress arc
    const startAngle = -1.57; // Start from top
    final sweepAngle = 2 * 3.14159 * progress; // Progress amount

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(ProgressCirclePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
