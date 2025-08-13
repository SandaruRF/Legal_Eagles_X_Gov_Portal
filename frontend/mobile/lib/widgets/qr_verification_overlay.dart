import 'package:flutter/material.dart';

class QRVerificationOverlay extends StatelessWidget {
  const QRVerificationOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(23),
      child: Container(
        width: 350,
        height: 580,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(11),
        ),
        child: Padding(
          padding: const EdgeInsets.all(44),
          child: Column(
            children: [
              // Title text
              const Text(
                'Let the officer scan this QR to confirm your identity.',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF000000),
                  height: 1.56,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 33),

              // QR Code placeholder
              Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE5E5E5), width: 1),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // QR Code icon
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: const Color(0xFF171717),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.qr_code_2,
                        color: Colors.white,
                        size: 72,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // QR Code text
                    const Text(
                      'QR Code',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF737373),
                        height: 1.43,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ID number
                    const Text(
                      'ID: SL123456789V',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF525252),
                        height: 1.33,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Close button
              SizedBox(
                width: 173,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8C1F28),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Close',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      height: 1.21,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
