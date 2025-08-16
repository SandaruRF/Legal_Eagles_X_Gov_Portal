import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import '../../core/services/http_client_service.dart';
import '../../core/config/environment_config.dart';
import 'appointment_time_slot_screen.dart';

class AppointmentLocationScreen extends ConsumerStatefulWidget {
  final String serviceId;
  final Map<String, dynamic> formData;

  const AppointmentLocationScreen({
    super.key,
    required this.serviceId,
    required this.formData,
  });

  @override
  ConsumerState<AppointmentLocationScreen> createState() =>
      _AppointmentLocationScreenState();
}

class _AppointmentLocationScreenState
    extends ConsumerState<AppointmentLocationScreen> {
  List<Map<String, dynamic>>? locations;
  bool isLoading = true;
  String? error;
  String? selectedLocationId;
  final HttpClientService _httpClient = HttpClientService();

  @override
  void initState() {
    super.initState();
    _loadLocations();
  }

  Future<void> _loadLocations() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      print('Loading locations for service ID: ${widget.serviceId}');

      final response = await _httpClient.get(
        '${EnvironmentConfig.appointmentLocations}/${widget.serviceId}',
      );

      if (response.success && response.data != null) {
        final data = response.data is String ? jsonDecode(response.data) : response.data;
        setState(() {
          locations = List<Map<String, dynamic>>.from(data);
          isLoading = false;
        });
      } else {
        throw Exception(response.message);
      }
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  void _proceedToTimeSlots() {
    if (selectedLocationId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => AppointmentTimeSlotScreen(
                serviceId: widget.serviceId,
                locationId: selectedLocationId!,
                formData: widget.formData,
              ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Location'),
        backgroundColor: const Color(0xFFFF5B00),
        foregroundColor: Colors.white,
      ),
      body: _buildBody(),
      bottomNavigationBar:
          selectedLocationId != null
              ? Container(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: _proceedToTimeSlots,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF5B00),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Continue to Time Selection',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              )
              : null,
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF5B00)),
        ),
      );
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error loading locations',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              error!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadLocations,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (locations == null || locations!.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_off, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No locations available',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Please try again later or contact support.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: locations!.length,
      itemBuilder: (context, index) {
        final location = locations![index];

        final isSelected = selectedLocationId == location['location_id'].toString();
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          color: isSelected ? const Color(0xFFFFF3E0) : null,
          child: ListTile(
            selected: isSelected,
            selectedTileColor: const Color(0xFFFFF3E0),
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFF5B00).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.location_on, color: Color(0xFFFF5B00)),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (location['address'] != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    location['address'],
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
                if (location['phone'] != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.phone, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        location['phone'],
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ],
                if (location['hours'] != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        location['hours'],
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ],
            ),
            trailing: Radio<String>(
              value: location['location_id'].toString(),
              groupValue: selectedLocationId,
              onChanged: (value) {
                setState(() {
                  selectedLocationId = value;
                });
              },
              activeColor: const Color(0xFFFF5B00),
            ),
            onTap: () {
              setState(() {
                selectedLocationId = location['location_id'].toString();
              });
            },
          ),
        );
      },
    );
  }
}
