import 'package:flutter/material.dart';
import 'audio_call_page.dart';
import 'message_page.dart';
import 'alert_details_page.dart';

enum AlertSeverity { all, warning, critical }

class AlertItem {
  final String title;
  final String subtitle;
  final String details;
  final String time;
  final AlertSeverity severity;

  const AlertItem({
    required this.title,
    required this.subtitle,
    required this.details,
    required this.time,
    required this.severity,
  });
}

class AlertsPage extends StatefulWidget {
  const AlertsPage({super.key});

  @override
  State<AlertsPage> createState() => _AlertsPageState();
}

class _AlertsPageState extends State<AlertsPage> {
  int _selectedTab = 0; // 0 = All, 1 = Warning, 2 = Critical

  final List<AlertItem> _alerts = const [
    AlertItem(
      title: 'Fall Detected',
      subtitle: 'Living Room · Mang Juan',
      details: 'No response yet. Please check immediately.',
      time: '2:34 PM',
      severity: AlertSeverity.critical,
    ),
    AlertItem(
      title: 'Heart Rate Critical',
      subtitle: '145 bpm · Above threshold',
      details: 'Normal: 60–100 bpm · Current: 145 bpm (+45%).',
      time: '2:00 PM',
      severity: AlertSeverity.critical,
    ),
    AlertItem(
      title: 'Blood Pressure Elevated',
      subtitle: '145/95 mmHg · Increasing',
      details: 'Normal: <130/80 mmHg · Trend: increasing.',
      time: '2:34 PM',
      severity: AlertSeverity.warning,
    ),
    AlertItem(
      title: 'Low Oxygen Saturation',
      subtitle: 'SpO₂ at 92% · Below 95%',
      details: 'Action: Monitor closely, consider contacting a doctor.',
      time: '2:00 PM',
      severity: AlertSeverity.warning,
    ),
    AlertItem(
      title: 'Daily Health Check Complete',
      subtitle: 'All vitals within normal range',
      details: 'Heart Rate: 72 bpm · BP: 118/76 mmHg · SpO₂: 98%.',
      time: '1:00 AM',
      severity: AlertSeverity.warning,
    ),
    AlertItem(
      title: 'Device Connected',
      subtitle: 'Smartwatch successfully reconnected',
      details: 'Connection restored between watch and phone.',
      time: '12:34 PM',
      severity: AlertSeverity.warning,
    ),
    AlertItem(
      title: 'Battery Fully Charged',
      subtitle: 'Smartwatch battery at 100%',
      details: 'Watch is ready for the day.',
      time: '10:34 PM',
      severity: AlertSeverity.warning,
    ),
    AlertItem(
      title: 'Low Battery Warning',
      subtitle: 'Battery at 15%',
      details: 'Please remind Mang Juan to charge the device.',
      time: '2:00 PM',
      severity: AlertSeverity.warning,
    ),
  ];

  List<AlertItem> get _filteredAlerts {
    if (_selectedTab == 1) {
      return _alerts.where((a) => a.severity == AlertSeverity.warning).toList();
    }
    if (_selectedTab == 2) {
      return _alerts.where((a) => a.severity == AlertSeverity.critical).toList();
    }
    return _alerts;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      // Floating button to open the Messages screen from Alerts.
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const MessagePage()),
          );
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.chat_bubble_outline),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header row: title + search + clear all
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Alerts',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Search coming soon (UI only).')),
                      );
                    },
                  ),
                  TextButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Clear all is a demo action only.')),
                      );
                    },
                    child: const Text('Clear All'),
                  ),
                ],
              ),
            ),

            // Tabs: All / Warning / Critical
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  _buildTabChip(label: 'All', index: 0),
                  const SizedBox(width: 8),
                  _buildTabChip(label: 'Warning', index: 1),
                  const SizedBox(width: 8),
                  _buildTabChip(label: 'Critical', index: 2),
                ],
              ),
            ),

            const SizedBox(height: 4),

            // Alerts list
            Expanded(
              child: _filteredAlerts.isEmpty
                  ? Center(
                      child: Text(
                        'No alerts',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade500,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      itemCount: _filteredAlerts.length,
                      itemBuilder: (context, index) {
                        final alert = _filteredAlerts[index];
                        final isCritical = alert.severity == AlertSeverity.critical;

                        return _buildAlertCard(context, alert, isCritical);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabChip({required String label, required int index}) {
    final isSelected = _selectedTab == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _selectedTab = index);
        },
        child: Container(
          height: 36,
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey.shade800,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAlertCard(BuildContext context, AlertItem alert, bool isCritical) {
    final theme = Theme.of(context);

    Color accentColor;
    IconData icon;
    if (isCritical) {
      accentColor = Colors.red;
      icon = Icons.warning_amber_rounded;
    } else {
      accentColor = Colors.blue;
      icon = Icons.health_and_safety;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: accentColor),
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
                              alert.title,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            alert.time,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        alert.subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        alert.details,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AudioCallPage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: const Text('Call Now'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AlertDetailsPage(
                            title: alert.title,
                            subtitle: alert.subtitle,
                            details: alert.details,
                            isCritical: isCritical,
                          ),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: const Text('View Details'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
