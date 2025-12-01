import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'database_helper.dart';
import 'user_provider.dart';
import 'package:intl/intl.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.userId == null) return;

    final db = DatabaseHelper.instance;
    final notifications = await db.getNotifications(userProvider.userId!);

    setState(() {
      _notifications = notifications;
      _isLoading = false;
    });
  }

  Future<void> _markAsRead(int notificationId) async {
    final db = DatabaseHelper.instance;
    await db.markNotificationAsRead(notificationId);
    _loadNotifications();
  }

  Future<void> _generateSampleNotifications() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.userId == null) return;

    final db = DatabaseHelper.instance;
    final now = DateTime.now();

    final sampleNotifications = [
      {
        'user_id': userProvider.userId!,
        'title': 'Heart Rate Alert',
        'message': 'Your heart rate has been elevated for the past hour. Consider taking a rest.',
        'type': 'health',
        'created_at': now.subtract(const Duration(hours: 2)).toIso8601String(),
      },
      {
        'user_id': userProvider.userId!,
        'title': 'Medication Reminder',
        'message': 'Time to take your evening medication.',
        'type': 'reminder',
        'created_at': now.subtract(const Duration(hours: 5)).toIso8601String(),
      },
      {
        'user_id': userProvider.userId!,
        'title': 'Blood Pressure Check',
        'message': 'Your blood pressure reading was normal today. Keep up the good work!',
        'type': 'health',
        'created_at': now.subtract(const Duration(days: 1)).toIso8601String(),
      },
      {
        'user_id': userProvider.userId!,
        'title': 'Emergency Contact Update',
        'message': 'Please review and update your emergency contacts.',
        'type': 'system',
        'created_at': now.subtract(const Duration(days: 2)).toIso8601String(),
      },
    ];

    for (var notification in sampleNotifications) {
      await db.insertNotification(notification);
    }

    _loadNotifications();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sample notifications generated!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.blue,
        elevation: 0,
        actions: [
          if (_notifications.isEmpty)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _generateSampleNotifications,
              tooltip: 'Add sample notifications',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.notifications_none,
                        size: 80,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No notifications yet',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'You\'ll see notifications here',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade400,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _generateSampleNotifications,
                        icon: const Icon(Icons.add),
                        label: const Text('Generate Sample Data'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadNotifications,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _notifications.length,
                    itemBuilder: (context, index) {
                      final notification = _notifications[index];
                      final isRead = notification['is_read'] == 1;
                      final createdAt = DateTime.parse(notification['created_at']);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: isRead ? 0 : 2,
                        color: isRead ? Colors.grey.shade50 : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: isRead ? Colors.grey.shade200 : Colors.blue.shade100,
                            width: 1,
                          ),
                        ),
                        child: InkWell(
                          onTap: () {
                            if (!isRead) {
                              _markAsRead(notification['id']);
                            }
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: _getNotificationColor(notification['type']).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    _getNotificationIcon(notification['type']),
                                    color: _getNotificationColor(notification['type']),
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              notification['title'],
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          if (!isRead)
                                            Container(
                                              width: 8,
                                              height: 8,
                                              decoration: const BoxDecoration(
                                                color: Colors.blue,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        notification['message'],
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        _formatDateTime(createdAt),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'health':
        return Icons.favorite;
      case 'reminder':
        return Icons.alarm;
      case 'emergency':
        return Icons.warning;
      case 'system':
        return Icons.info;
      default:
        return Icons.notifications;
    }
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'health':
        return Colors.red;
      case 'reminder':
        return Colors.orange;
      case 'emergency':
        return Colors.deepOrange;
      case 'system':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d, yyyy').format(dateTime);
    }
  }
}