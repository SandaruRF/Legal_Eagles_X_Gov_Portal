# File Upload Fix for Form Submission

## Problem
The form submission was failing with the error:
```
Converting object to an encodable object failed: Instance of '_File'
```

This occurred because the dynamic form widget was storing `File` objects directly in the form data map, but these cannot be JSON encoded for regular POST requests.

## Root Cause
1. **File Storage**: The `DynamicFormWidget` stores selected files as `File` objects in the `_formData` map
2. **JSON Encoding**: The form submission tried to JSON encode the entire form data, including `File` objects
3. **API Limitation**: The `HttpClientService.post()` method only supports JSON encoding, not multipart form data

## Solution Implemented

### 1. **Separated File and Text Data**
Modified `_handleFormSubmission()` in `dynamic_form_screen.dart` to separate files from text data:

```dart
// Separate files from other form data
final Map<String, dynamic> textData = {};
final Map<String, File> fileData = {};

for (final entry in formData.entries) {
  if (entry.value is File) {
    fileData[entry.key] = entry.value as File;
  } else {
    textData[entry.key] = entry.value;
  }
}
```

### 2. **Added Multipart Form Submission**
Created new `_submitFormWithFiles()` method that uses `http.MultipartRequest`:

```dart
Future<Map<String, dynamic>> _submitFormWithFiles(
  Map<String, dynamic> textData,
  Map<String, File> fileData,
) async {
  // Create multipart request
  final uri = Uri.parse('${ApiConfig.baseUrl}/api/forms/${widget.formId}/submit');
  final request = http.MultipartRequest('POST', uri);
  
  // Add text fields as JSON
  request.fields['form_data'] = jsonEncode(textData);
  request.fields['citizen_id'] = '12345';

  // Add file fields
  for (final entry in fileData.entries) {
    final file = entry.value;
    final multipartFile = await http.MultipartFile.fromPath(
      entry.key,
      file.path,
      filename: file.path.split('/').last,
    );
    request.files.add(multipartFile);
  }

  // Send and process response
  final streamedResponse = await request.send();
  final response = await http.Response.fromStream(streamedResponse);
  
  return jsonDecode(response.body) as Map<String, dynamic>;
}
```

### 3. **Enhanced Logging**
Added comprehensive logging for debugging multipart requests:
- Request URL and fields
- File names and field mappings
- Response status and body
- Error details

## Technical Details

### Request Format
The new implementation sends:
- **Content-Type**: `multipart/form-data`
- **Text Fields**: 
  - `form_data`: JSON string of non-file form fields
  - `citizen_id`: User identifier
- **File Fields**: Binary file data with original filenames

### Backend Compatibility
The backend should expect:
```
POST /api/forms/{form_id}/submit
Content-Type: multipart/form-data

form_data: {"name": "John Doe", "email": "john@example.com"}
citizen_id: 12345
profile_photo: [binary file data]
document_scan: [binary file data]
```

### Error Handling
- Network errors are caught and re-thrown with context
- HTTP errors include status code and response body
- Logging helps debug request/response flow

## Testing
1. **Form with Files**: Submit passport application with photo upload
2. **Form without Files**: Submit text-only forms (should still work)
3. **Mixed Forms**: Forms with both text fields and file uploads
4. **Error Scenarios**: Network failures, invalid files, server errors

## Benefits
1. **File Support**: Now properly handles file uploads in forms
2. **Backward Compatibility**: Text-only forms continue to work
3. **Error Clarity**: Better error messages for debugging
4. **Logging**: Comprehensive request/response logging
5. **Flexibility**: Can handle multiple files per form

## Future Improvements
1. **Progress Tracking**: Show upload progress for large files
2. **File Validation**: Check file size and type before upload
3. **Retry Logic**: Automatic retry for failed uploads
4. **Compression**: Compress images before upload
5. **Background Upload**: Allow background form submission
