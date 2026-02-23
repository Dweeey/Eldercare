import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:eldercareapp/core/providers/user_provider.dart';
import 'package:eldercareapp/features/account/data/notification_settings_repository.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  bool _emailNotifications = true;
  bool _pushNotifications = true;
  bool _medicationReminders = true;
  bool _appointmentReminders = true;
  bool _emergencyAlerts = true;
  bool _healthUpdates = true;
  bool _isLoading = false;
  bool _isGuestUser = false;

  final SupabaseClient _supabase = Supabase.instance.client;
  final NotificationSettingsRepository _notificationSettingsRepository =
      NotificationSettingsRepository();

  @override
  void initState() {
    super.initState();
    _loadNotificationSettings();
  }

  Future<void> _loadNotificationSettings() async {
    try {
      setState(() => _isLoading = true);
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final userId = userProvider.userId ?? _supabase.auth.currentUser?.id;

      if (userId == null) {
        setState(() {
          _isGuestUser = true;
          _isLoading = false;
        });
        return;
      }

      final response = await _notificationSettingsRepository.fetchSettings(
        userId,
      );

      if (response != null) {
        setState(() {
          _isGuestUser = false;
          _emailNotifications = response['email_notifications'] ?? true;
          _pushNotifications = response['push_notifications'] ?? true;
          _medicationReminders = response['medication_reminders'] ?? true;
          _appointmentReminders = response['appointment_reminders'] ?? true;
          _emergencyAlerts = response['emergency_alerts'] ?? true;
          _healthUpdates = response['health_updates'] ?? true;
        });
      } else {
        setState(() {
          _isGuestUser = false;
        });
      }
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading settings: $e')),
        );
      }
    }
  }

  Future<void> _saveNotificationSettings() async {
    try {
      setState(() => _isLoading = true);
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final userId = userProvider.userId ?? _supabase.auth.currentUser?.id;

      if (userId == null) {
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sign in to save settings')),
          );
        }
        return;
      }

      await _notificationSettingsRepository.saveSettings(
        userId: userId,
        emailNotifications: _emailNotifications,
        pushNotifications: _pushNotifications,
        medicationReminders: _medicationReminders,
        appointmentReminders: _appointmentReminders,
        emergencyAlerts: _emergencyAlerts,
        healthUpdates: _healthUpdates,
      );

      setState(() => _isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notification settings saved')),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving settings: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Notification Settings'),
        backgroundColor: Colors.blue,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _isGuestUser
              ? Center(
                  child: Text(
                    'Sign in to manage notification settings',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildSettingsSection(
                      title: 'Notification Channels',
                      items: [
                        _buildSwitchTile(
                          icon: Icons.email,
                          title: 'Email Notifications',
                          subtitle: 'Receive updates via email',
                          value: _emailNotifications,
                          onChanged: (value) {
                            setState(() => _emailNotifications = value);
                          },
                        ),
                        _buildSwitchTile(
                          icon: Icons.notifications,
                          title: 'Push Notifications',
                          subtitle: 'Receive app notifications',
                          value: _pushNotifications,
                          onChanged: (value) {
                            setState(() => _pushNotifications = value);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildSettingsSection(
                      title: 'Notification Types',
                      items: [
                        _buildSwitchTile(
                          icon: Icons.medication,
                          title: 'Medication Reminders',
                          subtitle: 'Get reminded to take medications',
                          value: _medicationReminders,
                          onChanged: (value) {
                            setState(() => _medicationReminders = value);
                          },
                        ),
                        _buildSwitchTile(
                          icon: Icons.calendar_today,
                          title: 'Appointment Reminders',
                          subtitle: 'Get reminded about appointments',
                          value: _appointmentReminders,
                          onChanged: (value) {
                            setState(() => _appointmentReminders = value);
                          },
                        ),
                        _buildSwitchTile(
                          icon: Icons.warning,
                          title: 'Emergency Alerts',
                          subtitle: 'Critical health alerts',
                          value: _emergencyAlerts,
                          onChanged: (value) {
                            setState(() => _emergencyAlerts = value);
                          },
                        ),
                        _buildSwitchTile(
                          icon: Icons.favorite,
                          title: 'Health Updates',
                          subtitle: 'General health information',
                          value: _healthUpdates,
                          onChanged: (value) {
                            setState(() => _healthUpdates = value);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveNotificationSettings,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Save Settings',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSettingsSection({
    required String title,
    required List<Widget> items,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          ...items,
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.blue, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.blue,
          ),
        ],
      ),
    );
  }
}
