# KYC NIC Front Upload Implementation

## Overview
Implemented the NIC front upload functionality for the KYC verification process using the `/api/citizen/kyc/upload-nic-front` endpoint.

## Implementation Details

### 1. API Configuration
- **File**: `lib/core/config/environment_config.dart`
- **Added**: `kycUploadNicFront` endpoint configuration
- **Endpoint**: `/api/citizen/kyc/upload-nic-front`

### 2. HTTP Client Service Enhancement
- **File**: `lib/core/services/http_client_service.dart`
- **Added**: `uploadFile<T>()` method for multipart file uploads
- **Features**:
  - Supports file uploads with additional form fields
  - Handles multipart/form-data requests
  - Includes proper authentication headers
  - Mock mode support for testing
  - 5-minute timeout for large file uploads

### 3. KYC Service
- **File**: `lib/core/services/kyc_service.dart`
- **Purpose**: Dedicated service for KYC-related API calls
- **Methods**:
  - `uploadNicFront(File imageFile)`: Uploads NIC front image
  - `uploadNicBack(File imageFile)`: Placeholder for NIC back upload
  - `uploadSelfie(File imageFile)`: Placeholder for selfie upload
  - `submitKycForVerification()`: Placeholder for final submission
- **Provider**: `kycServiceProvider` for dependency injection

### 4. NIC Front Upload Screen Enhancement
- **File**: `lib/screens/kyc/nic_front_upload_screen.dart`
- **Enhanced Features**:
  - Real image picker (camera/gallery selection dialog)
  - Actual API integration with backend upload
  - Progress tracking during upload
  - Error handling with user feedback
  - Success/failure notifications
  - File name display in upload states
  - Clear upload functionality

## Technical Specifications

### API Request Format
- **Method**: POST
- **Content-Type**: multipart/form-data
- **Field Name**: `image` (for the image file)
- **Authentication**: Bearer token (JWT)
- **Max File Size**: Configurable (currently no limit set)
- **Supported Formats**: Images (PNG, JPG, JPEG)

### Image Processing
- **Max Dimensions**: 1920x1080 pixels
- **Quality**: 85% compression
- **Source Options**: Camera or Gallery
- **Picker Package**: `image_picker: ^1.0.7`

### Permissions Required
Already configured in `android/app/src/main/AndroidManifest.xml`:
- `android.permission.CAMERA`
- `android.permission.READ_EXTERNAL_STORAGE`
- `android.permission.WRITE_EXTERNAL_STORAGE` (API ≤ 32)

## User Flow

1. **Initial State**: User sees upload area with camera/upload options
2. **Image Selection**: User taps "Open camera" → Dialog appears → User selects Camera or Gallery
3. **Image Capture/Selection**: Image picker opens → User captures/selects image
4. **Upload Process**: 
   - Progress bar shows upload status
   - File name is displayed
   - API call is made to backend
5. **Completion**:
   - **Success**: Checkmark shown, "Done" button to return to KYC verification
   - **Error**: Error message displayed, returns to initial state
6. **Clear Option**: User can clear upload and start over

## Error Handling

### Network Errors
- Connection timeouts
- No internet connectivity
- Server errors (4xx, 5xx responses)

### User Errors
- No image selected
- Image picker cancelled
- Invalid file format/size

### API Errors
- Authentication failures
- Backend validation errors
- File upload failures

## Mock Mode Support
When `Environment.mockMode` is active:
- No actual HTTP requests are made
- Simulated upload success response
- File validation still occurs locally
- All UI states work as expected

## Integration Points

### With KYC Verification Screen
- Callback function `onUploadComplete(String imagePath)` 
- Updates parent screen state when upload succeeds
- Enables "Submit for Verification" button when all documents uploaded

### With Authentication System
- Automatically includes JWT token in upload requests
- Handles token expiration/refresh if needed

## Future Enhancements

1. **Additional Upload Types**:
   - NIC Back upload endpoint integration
   - Selfie upload endpoint integration

2. **Image Validation**:
   - Client-side image quality checks
   - File size limits
   - Format validation

3. **Progress Enhancement**:
   - Real upload progress tracking (not simulated)
   - Upload speed estimation
   - Retry mechanism for failed uploads

4. **UI Improvements**:
   - Image preview before upload
   - Crop/rotate functionality
   - Multiple image selection

## Testing

### Manual Testing Steps
1. Navigate to KYC verification screen
2. Tap "NIC Front" upload card
3. Test both camera and gallery options
4. Verify progress indication
5. Confirm success/error handling
6. Test clear upload functionality

### Mock Mode Testing
Set `Environment.mockMode` in `environment_config.dart` to test without backend connectivity.

## Dependencies

### Required Packages
- `image_picker: ^1.0.7` (already included)
- `http: ^1.1.0` (already included)
- `flutter_riverpod: ^2.4.10` (already included)

### Platform Configurations
- Android permissions configured
- iOS permissions may need Info.plist updates (if targeting iOS)

## Backend Expectations

The backend endpoint `/api/citizen/kyc/upload-nic-front` should:
- Accept multipart/form-data requests
- Expect image file in `image` field
- Require Bearer token authentication
- Return JSON response with success/error status
- Support common image formats (PNG, JPG, JPEG)

### Expected Response Format
```json
{
  "message": "File uploaded successfully",
  "file_id": "unique_file_identifier",
  "upload_url": "https://storage.example.com/uploads/file.jpg"
}
```

### Error Response Format
```json
{
  "message": "Upload failed",
  "errors": ["File too large", "Invalid format"]
}
```
