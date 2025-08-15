import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/vault_document.dart';
import '../core/services/vault_service.dart';

/// State for vault documents
class VaultState {
  final List<VaultDocument> documents;
  final bool isLoading;
  final bool isUploading;
  final String? error;

  const VaultState({
    this.documents = const [],
    this.isLoading = false,
    this.isUploading = false,
    this.error,
  });

  VaultState copyWith({
    List<VaultDocument>? documents,
    bool? isLoading,
    bool? isUploading,
    String? error,
  }) {
    return VaultState(
      documents: documents ?? this.documents,
      isLoading: isLoading ?? this.isLoading,
      isUploading: isUploading ?? this.isUploading,
      error: error,
    );
  }
}

/// Vault provider for managing vault documents
class VaultNotifier extends StateNotifier<VaultState> {
  VaultNotifier() : super(const VaultState());

  final VaultService _vaultService = VaultService();

  /// Fetch vault documents from API
  Future<void> fetchVaultDocuments() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _vaultService.getVaultDocuments();

      if (response.success && response.data != null) {
        state = state.copyWith(
          documents: response.data!,
          isLoading: false,
          error: null,
        );
      } else {
        state = state.copyWith(isLoading: false, error: response.message);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to fetch vault documents: ${e.toString()}',
      );
    }
  }

  /// Upload documents to vault
  Future<void> uploadDocuments({
    required VaultDocumentType documentType,
    required List<String> filePaths,
    DateTime? expiryDate,
  }) async {
    state = state.copyWith(isUploading: true, error: null);

    try {
      final response = await _vaultService.uploadDocuments(
        documentType: documentType,
        filePaths: filePaths,
        expiryDate: expiryDate,
      );

      if (response.success && response.data != null) {
        // Add the new document to the list
        final updatedDocuments = [...state.documents, response.data!];
        state = state.copyWith(
          documents: updatedDocuments,
          isUploading: false,
          error: null,
        );
      } else {
        state = state.copyWith(isUploading: false, error: response.message);
      }
    } catch (e) {
      state = state.copyWith(
        isUploading: false,
        error: 'Failed to upload documents: ${e.toString()}',
      );
    }
  }

  /// Clear vault data (used for logout)
  void clearVault() {
    state = const VaultState();
  }

  /// Add a document manually (if needed after upload)
  void addDocument(VaultDocument document) {
    final updatedDocuments = [...state.documents, document];
    state = state.copyWith(documents: updatedDocuments, error: null);
  }

  /// Remove a document (after deletion)
  void removeDocument(String documentId) {
    final updatedDocuments =
        state.documents.where((doc) => doc.documentId != documentId).toList();
    state = state.copyWith(documents: updatedDocuments, error: null);
  }
}

/// Provider for vault state
final vaultProvider = StateNotifierProvider<VaultNotifier, VaultState>((ref) {
  return VaultNotifier();
});

/// Convenience provider to get just the documents
final vaultDocumentsProvider = Provider<List<VaultDocument>>((ref) {
  return ref.watch(vaultProvider).documents;
});

/// Convenience provider to check if vault data is loading
final isVaultLoadingProvider = Provider<bool>((ref) {
  return ref.watch(vaultProvider).isLoading;
});

/// Convenience provider to check if documents are being uploaded
final isVaultUploadingProvider = Provider<bool>((ref) {
  return ref.watch(vaultProvider).isUploading;
});

/// Convenience provider to get vault errors
final vaultErrorProvider = Provider<String?>((ref) {
  return ref.watch(vaultProvider).error;
});

/// Provider to get document count
final documentCountProvider = Provider<int>((ref) {
  final documents = ref.watch(vaultDocumentsProvider);
  return documents.length;
});

/// Provider to get documents that are expiring soon
final expiringSoonDocumentsProvider = Provider<List<VaultDocument>>((ref) {
  final documents = ref.watch(vaultDocumentsProvider);
  return documents.where((doc) => doc.isExpiringSoon).toList();
});

/// Provider to get expired documents
final expiredDocumentsProvider = Provider<List<VaultDocument>>((ref) {
  final documents = ref.watch(vaultDocumentsProvider);
  return documents.where((doc) => doc.isExpired).toList();
});
