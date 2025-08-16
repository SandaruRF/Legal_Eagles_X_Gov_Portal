# Form Submission and Appointment Booking Implementation

## Overview

This document describes the complete implementation of the dynamic form submission workflow and appointment booking system in the Gov Portal mobile application.

## Workflow Components

### 1. Dynamic Form Submission
**Location**: `lib/screens/forms/dynamic_form_screen.dart`

#### Features:
- **Real API Integration**: Form submission to `/api/forms/{form_id}/submit`
- **Document Download**: Automatic handling of downloadable documents from form responses
- **Multi-path Flow**: Support for forms with and without appointment requirements
- **Error Handling**: Comprehensive error handling with user-friendly messages
- **Loading States**: Visual feedback during submission and processing

#### API Request Format:
```json
{
  "form_data": {
    // All form field values from user input
  },
  "citizen_id": "12345" // TODO: Get from user context/authentication
}
```

#### Expected API Response:
```json
{
  "success": true,
  "message": "Form submitted successfully",
  "data": {
    "download_url": "https://api.example.com/documents/passport_receipt.pdf",
    "filename": "passport_receipt.pdf",
    "requires_appointment": true,
    "service_id": "passport_service",
    "appointment_id": "apt_123456"
  }
}
```

### 2. Document Download System
**Implementation**: Enhanced `_downloadDocument` method

#### Features:
- **Platform-specific Handling**: Different approaches for mobile vs desktop
- **Mobile**: Uses `url_launcher` to open documents in system browser/download manager
- **Desktop**: Downloads files to local application documents directory
- **User Feedback**: Progress indicators and success/error notifications

#### Required Packages:
- `path_provider: ^2.1.2` - For local file storage paths
- `url_launcher: ^6.2.5` - For opening URLs in external applications

### 3. Appointment Booking Flow

#### 3.1 Location Selection Screen
**Location**: `lib/screens/appointments/appointment_location_screen.dart`

##### Features:
- **Dynamic Location Loading**: Fetches available locations from `/api/appointments/locations/{service_id}`
- **Rich Location Information**: Displays name, address, phone, and hours
- **Interactive Selection**: Radio button interface for location selection
- **Validation**: Ensures location is selected before proceeding

##### API Endpoint:
```
GET /api/appointments/locations/{service_id}
```

##### Expected Response:
```json
[
  {
    "id": "loc_001",
    "name": "Downtown Service Center",
    "address": "123 Main St, City, State 12345",
    "phone": "+1-555-0123",
    "hours": "Mon-Fri 9:00 AM - 5:00 PM"
  }
]
```

#### 3.2 Time Slot Selection Screen
**Location**: `lib/screens/appointments/appointment_time_slot_screen.dart`

##### Features:
- **Date-based Organization**: Groups time slots by date with horizontal date selector
- **Grid Layout**: 3-column grid showing available time slots
- **Availability Indicators**: Visual distinction between available and unavailable slots
- **Real-time Selection**: Interactive slot selection with visual feedback

##### API Endpoint:
```
GET /api/appointments/slots?service_id={service_id}&location_id={location_id}
```

##### Expected Response:
```json
[
  {
    "id": "slot_001",
    "date": "2024-01-15",
    "time": "09:00 AM",
    "available": true
  },
  {
    "id": "slot_002", 
    "date": "2024-01-15",
    "time": "09:30 AM",
    "available": false
  }
]
```

#### 3.3 Final Appointment Booking
##### API Endpoint:
```
POST /api/appointments/book
```

##### Request Format:
```json
{
  "service_id": "passport_service",
  "location_id": "loc_001",
  "slot_id": "slot_001",
  "date": "2024-01-15",
  "citizen_id": "12345",
  "form_data": {
    // Original form submission data
  }
}
```

##### Expected Response:
```json
{
  "success": true,
  "message": "Appointment booked successfully",
  "data": {
    "appointment_id": "apt_789012",
    "reference_number": "REF123456789",
    "confirmation_details": {
      "service": "Passport Application",
      "location": "Downtown Service Center", 
      "date": "2024-01-15",
      "time": "09:00 AM"
    }
  }
}
```

## Configuration Updates

### Environment Config
**Location**: `lib/core/config/environment_config.dart`

Added new API endpoints:
```dart
// Appointments Endpoints
static const String appointmentLocations = '$apiVersion/appointments/locations';
static const String appointmentSlots = '$apiVersion/appointments/slots';
static const String appointmentBook = '$apiVersion/appointments/book';
```

### Dependencies
**Location**: `pubspec.yaml`

Added new packages:
```yaml
dependencies:
  path_provider: ^2.1.2  # For file downloads
  url_launcher: ^6.2.5   # For opening documents
```

## User Experience Flow

1. **Form Completion**: User fills out dynamic form (e.g., passport application)
2. **Form Submission**: Form data submitted to backend with loading indicator
3. **Document Processing**: If response includes download URL, document is automatically downloaded/opened
4. **Appointment Check**: If `requires_appointment` is true, user is guided to appointment booking
5. **Location Selection**: User selects preferred service location from available options
6. **Time Selection**: User picks date and time slot from availability grid
7. **Booking Confirmation**: Final appointment booking with confirmation details
8. **Success Feedback**: User receives confirmation with appointment details and reference number

## Technical Implementation Notes

### Error Handling
- Network errors are caught and displayed with retry options
- API errors show specific error messages from server responses
- Loading states prevent user interaction during async operations
- Form validation ensures required fields are completed

### State Management
- Uses Flutter Riverpod for state management
- Form state preserved during navigation between screens
- Appointment selection state maintained through screen transitions

### UI/UX Considerations
- Consistent loading indicators with app branding (orange theme)
- Clear visual feedback for selections and interactions
- Responsive design works across different screen sizes
- Accessibility-friendly with proper semantic labeling

### Future Enhancements
- Integration with user authentication system for citizen_id
- Offline support for form drafts
- Push notifications for appointment reminders
- Calendar integration for appointment management
- Document viewer for downloaded files
- Form auto-save functionality

## Testing Considerations

### Unit Tests
- Test form validation logic
- Test API response parsing
- Test state management flows

### Integration Tests
- End-to-end form submission flow
- Appointment booking complete workflow
- Document download functionality

### Mock Data
- API mock responses for testing without backend
- Various form configurations for testing different field types
- Error scenarios for testing error handling

## Security Considerations

- Form data encrypted during transmission
- Document URLs should be time-limited and secure
- User authentication required for appointment booking
- Input validation and sanitization for all form fields
- Rate limiting for API calls to prevent abuse
