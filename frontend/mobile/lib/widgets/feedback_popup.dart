import 'package:flutter/material.dart';

class FeedbackPopup extends StatefulWidget {
  final String appointmentId;
  final String serviceName;
  final Function(int rating, String? comment) onSubmit;
  final VoidCallback onCancel;

  const FeedbackPopup({
    super.key,
    required this.appointmentId,
    required this.serviceName,
    required this.onSubmit,
    required this.onCancel,
  });

  @override
  State<FeedbackPopup> createState() => _FeedbackPopupState();
}

class _FeedbackPopupState extends State<FeedbackPopup> {
  int _selectedRating = 0;
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _submitFeedback() {
    if (_selectedRating > 0) {
      final comment = _commentController.text.trim();
      widget.onSubmit(_selectedRating, comment.isEmpty ? null : comment);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            const Text(
              'Thank You for Using Our Service',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF171717),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'We appreciate you choosing our platform for your government service needs.',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Color(0xFF737373),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Service name
            Text(
              widget.serviceName,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF171717),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Rating section
            const Text(
              'Rate Your Experience',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF171717),
              ),
            ),
            const SizedBox(height: 16),

            // Star rating
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final starIndex = index + 1;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedRating = starIndex;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      Icons.star,
                      size: 32,
                      color:
                          starIndex <= _selectedRating
                              ? const Color(0xFFFFA500)
                              : const Color(0xFFE5E5E5),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),

            // Comment section
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Share your Thoughts',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF171717),
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _commentController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText:
                    'Your thoughts matter to us! Feel free to leave a comment.',
                hintStyle: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  color: Color(0xFF737373),
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFE5E5E5)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF7C3AED)),
                ),
                contentPadding: EdgeInsets.all(12),
              ),
            ),
            const SizedBox(height: 24),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: widget.onCancel,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFE5E5E5)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF737373),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _selectedRating > 0 ? _submitFeedback : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _selectedRating > 0
                              ? const Color(0xFFE65100)
                              : const Color(0xFFE5E5E5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                    ),
                    child: Text(
                      'Submit Feedback',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color:
                            _selectedRating > 0
                                ? Colors.white
                                : const Color(0xFF737373),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
