import 'package:flutter/material.dart';

class MedicalAppointmentBookingScreen extends StatefulWidget {
  const MedicalAppointmentBookingScreen({super.key});

  @override
  State<MedicalAppointmentBookingScreen> createState() =>
      _MedicalAppointmentBookingScreenState();
}

class _MedicalAppointmentBookingScreenState
    extends State<MedicalAppointmentBookingScreen> {
  DateTime selectedDate = DateTime.now();
  String? selectedTimeSlot;

  final List<String> timeSlots = [
    '10:00 AM',
    '11:00 AM',
    '12:00 PM',
    '02:00 PM',
    '03:00 PM',
    '04:00 PM',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),

            // Progress Indicator
            _buildProgressIndicator(),

            // Main Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),

                    // Title
                    const Text(
                      'Select Date & Time',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF171717),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Subtitle
                    const Text(
                      'Choose your preferred date and time slot for the medical appointment',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFFADAEBC),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Calendar
                    _buildCalendar(),

                    const SizedBox(height: 32),

                    // Time Slots Section
                    const Text(
                      'Available Time Slots',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF171717),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Time Slots Grid
                    _buildTimeSlots(),

                    const SizedBox(height: 40),

                    // Book Appointment Button
                    GestureDetector(
                      onTap:
                          selectedTimeSlot != null
                              ? () {
                                // Handle booking
                                _showBookingConfirmation();
                              }
                              : null,
                      child: Container(
                        width: double.infinity,
                        height: 48,
                        decoration: BoxDecoration(
                          color:
                              selectedTimeSlot != null
                                  ? const Color(0xFFFF5B00)
                                  : const Color(0xFFE5E5E5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Text(
                            'Book Appointment',
                            style: TextStyle(
                              fontFamily: 'Proxima Nova',
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      height: 103,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE5E5E5), width: 1)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 52, 16, 12),
        child: Row(
          children: [
            // Back button
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: SizedBox(
                width: 33.5,
                height: 36,
                child: const Icon(
                  Icons.arrow_back_ios,
                  size: 18,
                  color: Color(0xFF525252),
                ),
              ),
            ),

            // Gov Portal centered with logo
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Gov logo
                  Container(
                    width: 47,
                    height: 47,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: const DecorationImage(
                        image: AssetImage('assets/images/gov_portal_logo.png'),
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
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            // Notification icon
            Container(
              width: 18.74,
              height: 14.56,
              margin: const EdgeInsets.only(right: 16),
              child: const Icon(
                Icons.notifications_outlined,
                size: 18,
                color: Color(0xFF525252),
              ),
            ),

            // Avatar
            Container(
              width: 53,
              height: 53,
              decoration: const BoxDecoration(shape: BoxShape.circle),
              child: Stack(
                children: [
                  // Outer circle with border
                  Container(
                    width: 53,
                    height: 53,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF384455),
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/avatar_image-56586a.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  // Online status indicator
                  Positioned(
                    right: 1.5,
                    bottom: 1.5,
                    child: Container(
                      width: 13,
                      height: 13,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF27D79E),
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          // Step 1 - Completed
          _buildProgressStep(1, true, true),
          _buildProgressLine(true),

          // Step 2 - Completed
          _buildProgressStep(2, true, true),
          _buildProgressLine(true),

          // Step 3 - Current
          _buildProgressStep(3, true, false),
        ],
      ),
    );
  }

  Widget _buildProgressStep(int step, bool isActive, bool isCompleted) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? const Color(0xFFFF5B00) : const Color(0xFFE5E5E5),
        border: Border.all(
          color: isActive ? const Color(0xFFFF5B00) : const Color(0xFFE5E5E5),
          width: 2,
        ),
      ),
      child: Center(
        child:
            isCompleted
                ? const Icon(Icons.check, size: 16, color: Colors.white)
                : Text(
                  step.toString(),
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isActive ? Colors.white : const Color(0xFF9CA3AF),
                  ),
                ),
      ),
    );
  }

  Widget _buildProgressLine(bool isCompleted) {
    return Expanded(
      child: Container(
        height: 2,
        color: isCompleted ? const Color(0xFFFF5B00) : const Color(0xFFE5E5E5),
      ),
    );
  }

  Widget _buildCalendar() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE5E5E5)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: CalendarDatePicker(
        initialDate: selectedDate,
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(const Duration(days: 30)),
        onDateChanged: (date) {
          setState(() {
            selectedDate = date;
            selectedTimeSlot = null; // Reset time slot when date changes
          });
        },
      ),
    );
  }

  Widget _buildTimeSlots() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 2.5,
      ),
      itemCount: timeSlots.length,
      itemBuilder: (context, index) {
        final timeSlot = timeSlots[index];
        final isSelected = selectedTimeSlot == timeSlot;

        return GestureDetector(
          onTap: () {
            setState(() {
              selectedTimeSlot = timeSlot;
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFFF5B00) : Colors.white,
              border: Border.all(
                color:
                    isSelected
                        ? const Color(0xFFFF5B00)
                        : const Color(0xFFE5E5E5),
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                timeSlot,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? Colors.white : const Color(0xFF171717),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showBookingConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Booking Confirmed'),
          content: Text(
            'Your medical appointment has been booked for ${selectedDate.day}/${selectedDate.month}/${selectedDate.year} at $selectedTimeSlot',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Go back to previous screen
                Navigator.pop(context); // Go back to documents screen
                Navigator.pop(context); // Go back to appointment details screen
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
