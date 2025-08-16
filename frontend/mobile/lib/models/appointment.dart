class Appointment {
  final String appointmentId;
  final String referenceNumber;
  final String serviceName;
  final String scheduledDate;
  final String scheduledTime;
  final String status;
  final String address;

  const Appointment({
    required this.appointmentId,
    required this.referenceNumber,
    required this.serviceName,
    required this.scheduledDate,
    required this.scheduledTime,
    required this.status,
    required this.address,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      appointmentId: json['appointment_id'] ?? '',
      referenceNumber: json['reference_number'] ?? '',
      serviceName: json['service_name'] ?? '',
      scheduledDate: json['scheduled_date'] ?? '',
      scheduledTime: json['scheduled_time'] ?? '',
      status: json['status'] ?? '',
      address: json['address'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'appointment_id': appointmentId,
      'reference_number': referenceNumber,
      'service_name': serviceName,
      'scheduled_date': scheduledDate,
      'scheduled_time': scheduledTime,
      'status': status,
      'address': address,
    };
  }

  /// Get formatted appointment date and time for display
  String get formattedAppointmentDateTime {
    try {
      // Combine scheduled_date and scheduled_time for display
      return '$scheduledDate at $scheduledTime';
    } catch (e) {
      return 'Date: $scheduledDate, Time: $scheduledTime';
    }
  }

  /// Get formatted submission date (using current date as placeholder)
  String get formattedCreatedDateTime {
    // Since the API doesn't provide created date, we can show a placeholder
    // or you could add this field to the backend response
    final now = DateTime.now();
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    final month = months[now.month - 1];
    final day = now.day;
    final year = now.year;
    final hour = now.hour;
    final minute = now.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);

    return '$month $day, $year at $displayHour:$minute $period';
  }

  Appointment copyWith({
    String? appointmentId,
    String? referenceNumber,
    String? serviceName,
    String? scheduledDate,
    String? scheduledTime,
    String? status,
    String? address,
  }) {
    return Appointment(
      appointmentId: appointmentId ?? this.appointmentId,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      serviceName: serviceName ?? this.serviceName,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      status: status ?? this.status,
      address: address ?? this.address,
    );
  }

  @override
  String toString() {
    return 'Appointment(appointmentId: $appointmentId, serviceName: $serviceName, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Appointment &&
        other.appointmentId == appointmentId &&
        other.referenceNumber == referenceNumber &&
        other.serviceName == serviceName;
  }

  @override
  int get hashCode {
    return appointmentId.hashCode ^
        referenceNumber.hashCode ^
        serviceName.hashCode;
  }
}
