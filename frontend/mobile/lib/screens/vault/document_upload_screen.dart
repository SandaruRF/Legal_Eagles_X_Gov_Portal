import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../models/vault_document.dart';
import '../../providers/vault_provider.dart';

class DocumentUploadScreen extends ConsumerStatefulWidget {
  const DocumentUploadScreen({super.key});

  @override
  ConsumerState<DocumentUploadScreen> createState() =>
      _DocumentUploadScreenState();
}

class _DocumentUploadScreenState extends ConsumerState<DocumentUploadScreen> {
  VaultDocumentType? _selectedDocumentType;
  DateTime? _selectedExpiryDate;
  final List<String> _selectedFiles = [];
  final ImagePicker _picker = ImagePicker();

  // Check which document types are already uploaded
  List<VaultDocumentType> _getAvailableDocumentTypes() {
    final existingDocuments = ref.watch(vaultDocumentsProvider);
    final existingTypes =
        existingDocuments.map((doc) => doc.documentType).toSet();

    return VaultDocumentType.values
        .where((type) => !existingTypes.contains(type))
        .toList();
  }

  Future<void> _pickImages() async {
    try {
      final pickedFiles = await _picker.pickMultiImage();
      if (pickedFiles.isNotEmpty) {
        setState(() {
          _selectedFiles.clear();
          _selectedFiles.addAll(pickedFiles.map((file) => file.path));
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking images: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _pickFromCamera() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.camera);
      if (pickedFile != null) {
        setState(() {
          _selectedFiles.add(pickedFile.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error taking photo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _selectExpiryDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFFFF5B00)),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedExpiryDate = picked;
      });
    }
  }

  void _removeFile(int index) {
    setState(() {
      _selectedFiles.removeAt(index);
    });
  }

  Future<void> _uploadDocuments() async {
    if (_selectedDocumentType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a document type'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedFiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one file'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      await ref
          .read(vaultProvider.notifier)
          .uploadDocuments(
            documentType: _selectedDocumentType!,
            filePaths: _selectedFiles,
            expiryDate: _selectedExpiryDate,
          );

      final error = ref.read(vaultErrorProvider);
      if (error == null) {
        if (mounted) {
          // Clear form after successful upload
          setState(() {
            _selectedDocumentType = null;
            _selectedExpiryDate = null;
            _selectedFiles.clear();
          });

          // Refresh the vault documents list
          await ref.read(vaultProvider.notifier).fetchVaultDocuments();

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Documents uploaded successfully!'),
              backgroundColor: Colors.green,
            ),
          );

          // Wait a bit for the vault to refresh, then navigate back
          await Future.delayed(const Duration(milliseconds: 500));
          Navigator.pop(context);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Upload failed: $error'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Upload failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final availableTypes = _getAvailableDocumentTypes();
    final isUploading = ref.watch(isVaultUploadingProvider);

    // Safety check: if selected document type is not available, reset it
    if (_selectedDocumentType != null &&
        !availableTypes.contains(_selectedDocumentType)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _selectedDocumentType = null;
        });
      });
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: Column(
        children: [
          // Status bar area
          Container(
            height: MediaQuery.of(context).padding.top,
            color: const Color(0xFFFAFAFA),
          ),

          // Header
          Container(
            width: double.infinity,
            height: 82,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFFFAFAFA),
              border: Border(
                bottom: BorderSide(color: Color(0xFFE5E5E5), width: 1),
              ),
            ),
            child: Row(
              children: [
                // Back button
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE5E5E5)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios,
                      size: 16,
                      color: Color(0xFF525252),
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                // Title
                const Expanded(
                  child: Text(
                    'Upload Document',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF171717),
                      height: 1.11,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Main content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Document Type Selection
                  const Text(
                    'Document Type',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF171717),
                    ),
                  ),
                  const SizedBox(height: 8),

                  if (availableTypes.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: const Text(
                        'All document types have been uploaded. You can manage existing documents from the vault.',
                        style: TextStyle(
                          color: Color(0xFF737373),
                          fontFamily: 'Inter',
                          fontSize: 14,
                        ),
                      ),
                    )
                  else
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE5E5E5)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<VaultDocumentType>(
                          value: _selectedDocumentType,
                          hint: const Text(
                            'Select document type',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              color: Color(0xFF737373),
                            ),
                          ),
                          onChanged: (VaultDocumentType? value) {
                            setState(() {
                              _selectedDocumentType = value;
                            });
                          },
                          items:
                              availableTypes.map((type) {
                                return DropdownMenuItem<VaultDocumentType>(
                                  value: type,
                                  child: Text(
                                    type.displayName,
                                    style: const TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 14,
                                      color: Color(0xFF171717),
                                    ),
                                  ),
                                );
                              }).toList(),
                        ),
                      ),
                    ),

                  const SizedBox(height: 24),

                  // Expiry Date (Optional)
                  const Text(
                    'Expiry Date (Optional)',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF171717),
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _selectExpiryDate,
                    child: Container(
                      width: double.infinity,
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE5E5E5)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _selectedExpiryDate != null
                                  ? '${_selectedExpiryDate!.day.toString().padLeft(2, '0')}/${_selectedExpiryDate!.month.toString().padLeft(2, '0')}/${_selectedExpiryDate!.year}'
                                  : 'Select expiry date',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 14,
                                color:
                                    _selectedExpiryDate != null
                                        ? const Color(0xFF171717)
                                        : const Color(0xFF737373),
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.calendar_today,
                            size: 16,
                            color: Color(0xFF737373),
                          ),
                        ],
                      ),
                    ),
                  ),

                  if (_selectedExpiryDate != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Tap to change date',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              color: Color(0xFF737373),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedExpiryDate = null;
                            });
                          },
                          child: const Text(
                            'Remove',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              color: Color(0xFFFF5B00),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 24),

                  // File Selection
                  const Text(
                    'Document Files',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF171717),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // File picker buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _pickImages,
                          icon: const Icon(Icons.photo_library, size: 16),
                          label: const Text('Gallery'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF171717),
                            side: const BorderSide(color: Color(0xFFE5E5E5)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _pickFromCamera,
                          icon: const Icon(Icons.camera_alt, size: 16),
                          label: const Text('Camera'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF171717),
                            side: const BorderSide(color: Color(0xFFE5E5E5)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Selected files display
                  if (_selectedFiles.isNotEmpty) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE5E5E5)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_selectedFiles.length} file${_selectedFiles.length > 1 ? 's' : ''} selected',
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF171717),
                            ),
                          ),
                          const SizedBox(height: 12),
                          ...List.generate(_selectedFiles.length, (index) {
                            final fileName =
                                _selectedFiles[index].split('/').last;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(
                                        color: const Color(0xFFE5E5E5),
                                      ),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: Image.file(
                                        File(_selectedFiles[index]),
                                        fit: BoxFit.cover,
                                        errorBuilder: (
                                          context,
                                          error,
                                          stackTrace,
                                        ) {
                                          return const Icon(
                                            Icons.description,
                                            color: Color(0xFF737373),
                                            size: 20,
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      fileName,
                                      style: const TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 12,
                                        color: Color(0xFF171717),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () => _removeFile(index),
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      color: Color(0xFF737373),
                                      size: 16,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ] else ...[
                    Container(
                      width: double.infinity,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFFE5E5E5),
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.cloud_upload_outlined,
                              size: 32,
                              color: Color(0xFF737373),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'No files selected',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 14,
                                color: Color(0xFF737373),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 32),

                  // Upload button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed:
                          availableTypes.isEmpty || isUploading
                              ? null
                              : _uploadDocuments,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF5B00),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: const Color(0xFFE5E5E5),
                        disabledForegroundColor: const Color(0xFF737373),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child:
                          isUploading
                              ? const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Uploading...',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              )
                              : const Text(
                                'Upload Documents',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  height: 1.21,
                                ),
                              ),
                    ),
                  ),

                  const SizedBox(height: 100), // Space for bottom navigation
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
