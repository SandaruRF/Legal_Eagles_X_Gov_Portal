import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';
import '../../core/services/http_client_service.dart';
import '../../core/config/api_config.dart';
import '../../widgets/chatbot_overlay.dart';
import '../../widgets/bottom_navigation_bar.dart';
import 'dart:convert';
import 'dart:async';

class NotificationItem {
  final String id;
  final String title;
  final String description;
  final String time;
  bool isRead; // Make mutable for marking as read
  final String type;
  final DateTime createdAt;

  NotificationItem({
    required this.id,
    required this.title,
    required this.description,
    required this.time,
    required this.isRead,
    required this.type,
    required this.createdAt,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'] ?? json['notification_id'] ?? '',
      title: _getTitleFromType(json['type'] ?? ''),
      description: json['message'] ?? json['description'] ?? '',
      time: _formatTime(json['created_at']),
      isRead: json['is_read'] ?? json['read'] ?? false,
      type: json['type'] ?? '',
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  static String _getTitleFromType(String type) {
    switch (type.toLowerCase()) {
      case 'appointmentstatuschange':
        return 'Appointment Status Update';
      case 'document_expiry':
        return 'Renew Documents';
      case 'appointment':
        return 'Appointment Reminder';
      case 'general':
        return 'General Notification';
      case 'document':
        return 'Document Update';
      default:
        return 'Notification';
    }
  }

  static String _formatTime(String? dateTime) {
    if (dateTime == null) return 'Now';

    try {
      final DateTime created = DateTime.parse(dateTime);
      final DateTime now = DateTime.now();
      final Duration difference = now.difference(created);

      if (difference.inMinutes < 1) {
        return 'Just now';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes} minutes ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours} hours ago';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} days ago';
      } else {
        return '${(difference.inDays / 7).floor()} weeks ago';
      }
    } catch (e) {
      return 'Recently';
    }
  }
}

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  Set<String> expandedNotifications =
      {}; // Track which notifications are expanded

  // WebSocket and backend integration
  WebSocketChannel? _channel;
  StreamSubscription?
  _subscription; // Make nullable to avoid LateInitializationError
  bool _isConnected = false;
  int _unreadCount = 0;
  final HttpClientService _httpClient = HttpClientService();
  String? _citizenId;
  Timer? _reconnectTimer;

  List<NotificationItem> notifications = [
    NotificationItem(
      id: '1',
      title: 'Appointment Confirmed',
      description:
          'Your appointment for passport services on 20th August at 12:00 p.m. is confirmed',
      time: '2 days ago',
      isRead: false,
      type: 'appointment_confirmed',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    NotificationItem(
      id: '2',
      title: 'Appointment Reminder',
      description:
          'Your appointment for extension of driving license is due on 20th August at 2:00 p.m. If you\'re unable to make it please cancel the appointment. Kindly bring the below documents with you:\n\nNIC\nPassport\nBirth Certificate',
      time: '1 week ago',
      isRead: false,
      type: 'appointment_reminder',
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
    ),
    NotificationItem(
      id: '3',
      title: 'Missing Documents',
      description:
          'To confirm the appointment kindly send us the below documents: NIC, License',
      time: '2 days ago',
      isRead: false,
      type: 'missing_documents',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    NotificationItem(
      id: '4',
      title: 'Renew Documents',
      description:
          'Your driving License will get expire on 2nd of September. Kindly request you to renew.',
      time: '1 week ago',
      isRead: false,
      type: 'renew_documents',
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  @override
  void dispose() {
    _cleanup();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    try {
      await _getCitizenProfile();
      if (_citizenId != null) {
        await _connectWebSocket();
        await _loadUnreadNotifications();
      }
    } catch (e) {
      print('Failed to initialize app: $e');
    }
  }

  Future<void> _getCitizenProfile() async {
    try {
      final response = await _httpClient.get('/citizens/me');
      if (response.success && response.data != null) {
        _citizenId = response.data['citizen_id'];
      }
    } catch (e) {
      print('Failed to get citizen profile: $e');
    }
  }

  Future<void> _connectWebSocket() async {
    if (_citizenId == null) return;

    try {
      _cleanup(); // Clean up existing connection

      // Try WebSocket connection
      final wsUrl =
          '${ApiConfig.baseUrl.replaceFirst('http', 'ws')}/ws/notifications/$_citizenId';
      _channel = IOWebSocketChannel.connect(wsUrl);

      _subscription = _channel!.stream.listen(
        _handleWebSocketMessage,
        onError: _handleWebSocketError,
        onDone: _handleWebSocketDone,
      );

      setState(() {
        _isConnected = true;
      });

      print('WebSocket connected for citizen: $_citizenId');
    } catch (e) {
      print('WebSocket connection failed: $e');
      // Fallback to polling if WebSocket fails
      _startPollingMode();
    }
  }

  void _startPollingMode() {
    print('Starting polling mode as WebSocket fallback');
    setState(() {
      _isConnected = false; // Show as offline but still functional
    });

    // Poll for notifications every 30 seconds
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) {
        _loadUnreadNotifications();
      } else {
        timer.cancel();
      }
    });
  }

  void _handleWebSocketMessage(dynamic message) {
    try {
      final data = jsonDecode(message);
      final notification = NotificationItem.fromJson(data);

      // Check for duplicates
      if (!notifications.any((n) => n.id == notification.id)) {
        setState(() {
          notifications.insert(0, notification);
          if (!notification.isRead) {
            _unreadCount++;
          }
        });

        // Show in-app notification
        _showInAppNotification(notification);
      }
    } catch (e) {
      print('Failed to handle WebSocket message: $e');
    }
  }

  void _handleWebSocketError(error) {
    print('WebSocket error: $error');
    setState(() {
      _isConnected = false;
    });
    // Switch to polling mode instead of trying to reconnect WebSocket
    _startPollingMode();
  }

  void _handleWebSocketDone() {
    print('WebSocket connection closed');
    setState(() {
      _isConnected = false;
    });
    // Switch to polling mode instead of trying to reconnect WebSocket
    _startPollingMode();
  }

  Future<void> _loadUnreadNotifications() async {
    try {
      final response = await _httpClient.get('/api/notifications/unread');
      if (response.success && response.data != null) {
        List<NotificationItem> unreadNotifications = [];

        // Handle different response structures
        if (response.data is List) {
          // Backend returns list directly
          unreadNotifications =
              (response.data as List)
                  .map((json) => NotificationItem.fromJson(json))
                  .toList();
        } else if (response.data is Map &&
            response.data['notifications'] != null) {
          // Backend returns object with notifications field
          unreadNotifications =
              (response.data['notifications'] as List)
                  .map((json) => NotificationItem.fromJson(json))
                  .toList();
        }

        setState(() {
          // Merge with existing notifications (remove duplicates)
          for (final newNotification in unreadNotifications) {
            if (!notifications.any((n) => n.id == newNotification.id)) {
              notifications.insert(0, newNotification);
            }
          }
          // Count unread notifications
          _unreadCount = unreadNotifications.length;
        });
      }
    } catch (e) {
      print('Failed to load unread notifications: $e');
    }
  }

  Future<void> _markAsRead(String notificationId) async {
    try {
      final response = await _httpClient.post(
        '/api/notifications/$notificationId/read',
      );

      if (response.success) {
        setState(() {
          final notification = notifications.firstWhere(
            (n) => n.id == notificationId,
          );
          if (!notification.isRead) {
            notification.isRead = true;
            _unreadCount = (_unreadCount - 1).clamp(0, _unreadCount);
          }
        });
      } else {
        print('Failed to mark notification as read: ${response.message}');
      }
    } catch (e) {
      print('Failed to mark notification as read: $e');
    }
  }

  void _showInAppNotification(NotificationItem notification) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              notification.title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              notification.description.length > 60
                  ? '${notification.description.substring(0, 60)}...'
                  : notification.description,
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF3B82F6),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'View',
          textColor: Colors.white,
          onPressed: () {
            _handleNotificationTap(notification);
          },
        ),
      ),
    );
  }

  void _handleNotificationTap(NotificationItem notification) {
    // Mark as read when tapped
    if (!notification.isRead) {
      _markAsRead(notification.id);
    }

    // Navigate based on notification type
    switch (notification.type) {
      case 'AppointmentStatusChange':
      case 'appointment':
      case 'appointment_confirmed':
      case 'appointment_reminder':
        Navigator.pushNamed(context, '/appointments');
        break;
      case 'document_expiry':
      case 'missing_documents':
      case 'renew_documents':
      case 'document':
        Navigator.pushNamed(context, '/documents');
        break;
      case 'general':
      default:
        // Just expand the notification in the current screen
        _toggleExpanded(notification.id);
        break;
    }
  }

  void _cleanup() {
    _subscription?.cancel(); // Use null-aware operator
    _channel?.sink.close();
    _reconnectTimer?.cancel();
  }

  void _deleteNotification(String id) {
    // Show confirmation dialog before deleting
    _showDeleteConfirmationDialog(id);
  }

  void _showDeleteConfirmationDialog(String id) {
    final notification = notifications.firstWhere((n) => n.id == id);

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.delete_outline,
                          color: Color(0xFFEF4444),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Delete Notification',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF171717),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Content
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Are you sure you want to delete this notification?',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF171717),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFE5E5E5)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              notification.title,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF171717),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              notification.description.length > 80
                                  ? '${notification.description.substring(0, 80)}...'
                                  : notification.description,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF525252),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'This action cannot be undone.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF9CA3AF),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 44,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: const Color(0xFFE5E5E5),
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                ),
                                child: const Text(
                                  'Cancel',
                                  style: TextStyle(
                                    color: Color(0xFF525252),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              height: 44,
                              decoration: BoxDecoration(
                                color: const Color(0xFFEF4444),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  _confirmDeleteNotification(id);
                                },
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                ),
                                child: const Text(
                                  'Delete',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _confirmDeleteNotification(String id) {
    setState(() {
      notifications.removeWhere((notification) => notification.id == id);
      expandedNotifications.remove(id); // Remove from expanded set when deleted
    });

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Notification deleted successfully'),
        backgroundColor: Color(0xFF22C55E),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _toggleExpanded(String id) {
    setState(() {
      if (expandedNotifications.contains(id)) {
        expandedNotifications.remove(id);
      } else {
        expandedNotifications.add(id);
      }
    });
  }

  bool _isMessageLong(String message) {
    // Consider message long if it has more than 100 characters or contains newlines
    return message.length > 100 || message.contains('\n');
  }

  String _getTruncatedMessage(String message) {
    if (message.contains('\n')) {
      return message.split('\n').first + '...';
    }
    if (message.length > 100) {
      return message.substring(0, 100) + '...';
    }
    return message;
  }

  Widget _buildActionButton(NotificationItem notification) {
    final bool isExpanded = expandedNotifications.contains(notification.id);
    final bool isLong = _isMessageLong(notification.description);

    // For document-related notifications, always show upload button regardless of message length
    if (notification.type == 'missing_documents') {
      return Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF22C55E),
          borderRadius: BorderRadius.circular(4),
        ),
        child: TextButton(
          onPressed: () => _showDocumentUploadDialog(notification),
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text(
            'Upload Documents',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }

    // For document renewal notifications
    if (notification.type == 'renew_documents') {
      return Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF22C55E),
          borderRadius: BorderRadius.circular(4),
        ),
        child: TextButton(
          onPressed: () => _showDocumentRenewalDialog(notification),
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text(
            'Renew Now',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }

    // If message is not long and not a document notification, don't show any action button
    if (!isLong) {
      return const SizedBox.shrink(); // Return empty widget
    }

    // If message is long, show View Details/Show Less button
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFE65100),
        borderRadius: BorderRadius.circular(4),
      ),
      child: TextButton(
        onPressed: () => _toggleExpanded(notification.id),
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text(
          isExpanded ? 'Show Less' : 'View Details',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  void _showDocumentUploadDialog(NotificationItem notification) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF22C55E).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.upload_file,
                          color: Color(0xFF22C55E),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Upload Documents',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF171717),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(
                          Icons.close,
                          color: Color(0xFF9CA3AF),
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
                // Content
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification.description,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF525252),
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Required Documents:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF171717),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildDocumentUploadItem('National Identity Card (NIC)'),
                      _buildDocumentUploadItem('Driving License'),
                      const SizedBox(height: 20),
                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 44,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: const Color(0xFFE5E5E5),
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                ),
                                child: const Text(
                                  'Cancel',
                                  style: TextStyle(
                                    color: Color(0xFF525252),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              height: 44,
                              decoration: BoxDecoration(
                                color: const Color(0xFF22C55E),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  _navigateToDocumentUpload(notification);
                                },
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                ),
                                child: const Text(
                                  'Upload Files',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDocumentUploadItem(String documentName) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E5E5)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFF22C55E).withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Icon(
              Icons.description,
              color: Color(0xFF22C55E),
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              documentName,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF171717),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Icon(Icons.upload, color: Color(0xFF9CA3AF), size: 16),
        ],
      ),
    );
  }

  void _navigateToDocumentUpload(NotificationItem notification) {
    // For now, show a snackbar - you can replace this with actual navigation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Document upload screen would open here'),
        backgroundColor: Color(0xFF22C55E),
      ),
    );
  }

  void _showDocumentRenewalDialog(NotificationItem notification) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF22C55E).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.refresh,
                          color: Color(0xFF22C55E),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Renew Document',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF171717),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(
                          Icons.close,
                          color: Color(0xFF9CA3AF),
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
                // Content
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification.description,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF525252),
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFD97706)),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.warning_amber,
                              color: Color(0xFFD97706),
                              size: 20,
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Your document will expire soon. Renew now to avoid service interruptions.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF92400E),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 44,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: const Color(0xFFE5E5E5),
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                ),
                                child: const Text(
                                  'Later',
                                  style: TextStyle(
                                    color: Color(0xFF525252),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              height: 44,
                              decoration: BoxDecoration(
                                color: const Color(0xFF22C55E),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  _navigateToDocumentRenewal(notification);
                                },
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                ),
                                child: const Text(
                                  'Renew Now',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _navigateToDocumentRenewal(NotificationItem notification) {
    // For now, show a snackbar - you can replace this with actual navigation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Document renewal screen would open here'),
        backgroundColor: Color(0xFF22C55E),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF525252)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Notifications',
              style: TextStyle(
                color: Color(0xFF171717),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (_unreadCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$_unreadCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
        centerTitle: true,
        actions: [
          // WebSocket connection indicator
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color:
                        _isConnected
                            ? const Color(0xFF22C55E)
                            : const Color(
                              0xFFFB923C,
                            ), // Orange for polling mode
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  _isConnected
                      ? 'Live'
                      : 'Sync', // Show "Sync" instead of "Offline" for polling mode
                  style: TextStyle(
                    color:
                        _isConnected
                            ? const Color(0xFF22C55E)
                            : const Color(0xFFFB923C),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE5E5E5), height: 1),
        ),
      ),
      body:
          notifications.isEmpty
              ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.notifications_none,
                      size: 64,
                      color: Color(0xFF9CA3AF),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No notifications',
                      style: TextStyle(
                        fontSize: 18,
                        color: Color(0xFF6B7280),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              )
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final notification = notifications[index];
                  return GestureDetector(
                    onTap: () => _handleNotificationTap(notification),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color:
                            notification.isRead
                                ? Colors.white
                                : const Color(
                                  0xFFF3F4F6,
                                ), // Light background for unread
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color:
                              notification.isRead
                                  ? const Color(0xFFE5E5E5)
                                  : const Color(
                                    0xFF3B82F6,
                                  ), // Blue border for unread
                          width: notification.isRead ? 1 : 2,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    notification.title,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF171717),
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap:
                                      () =>
                                          _deleteNotification(notification.id),
                                  child: const Icon(
                                    Icons.close,
                                    color: Color(0xFF9CA3AF),
                                    size: 20,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              expandedNotifications.contains(notification.id) ||
                                      !_isMessageLong(notification.description)
                                  ? notification.description
                                  : _getTruncatedMessage(
                                    notification.description,
                                  ),
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF525252),
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  notification.time,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF737373),
                                  ),
                                ),
                                _buildActionButton(notification),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ), // Close ListView.builder
      floatingActionButton: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFF262626),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: () {
              showDialog(
                context: context,
                barrierDismissible: true,
                barrierColor: Colors.transparent,
                builder: (BuildContext context) {
                  return const ChatbotOverlay(currentPage: 'Notifications');
                },
              );
            },
            child: const Center(
              child: Icon(
                Icons.chat_bubble_outline,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: const CustomBottomNavigationBar(
        currentPage: 'notifications',
      ),
    );
  }
}
