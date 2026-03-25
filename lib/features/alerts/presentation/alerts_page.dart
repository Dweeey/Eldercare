import 'package:eldercareapp/services/zegocloud_voip_service.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

// --- MODELS ---
enum AlertSeverity { all, warning, critical }

class AlertItem {
  final String id;
  final String title;
  final String subtitle;
  final String details;
  final DateTime time;
  final AlertSeverity severity;

  const AlertItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.details,
    required this.time,
    required this.severity,
  });

  // Factory to safely convert Firebase data into our UI Model
  factory AlertItem.fromFirestore(Map<String, dynamic> data, String id) {
    return AlertItem(
      id: id,
      title: data['title'] ?? 'Unknown Alert',
      subtitle: data['subtitle'] ?? '',
      details: data['details'] ?? '',
      time: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      severity: data['severity'] == 'critical'
          ? AlertSeverity.critical
          : AlertSeverity.warning,
    );
  }

  // UPDATED: Uses the intl package to show both the Date and Time
  String get formattedDateTime {
    // This will format it exactly like: "Mar 21, 2:15 AM"
    return DateFormat('MMM d, h:mm a').format(time);
  }
}

// --- UI PAGE ---
class AlertsPage extends StatefulWidget {
  const AlertsPage({super.key});

  @override
  State<AlertsPage> createState() => _AlertsPageState();
}

class _AlertsPageState extends State<AlertsPage> {
  int _selectedTab = 0; // 0 = All, 1 = Warning, 2 = Critical

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      
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
                        const SnackBar(content: Text('Search coming soon.')),
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

            // --- REAL-TIME FIREBASE STREAM BUILDER ---
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                // Listening to an "alerts" collection, ordered by newest first
                stream: FirebaseFirestore.instance
                    .collection('alerts')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Text(
                        'No alerts',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade500,
                        ),
                      ),
                    );
                  }

                  // 1. Convert Firebase docs into our AlertItem objects
                  List<AlertItem> allAlerts = snapshot.data!.docs.map((doc) {
                    return AlertItem.fromFirestore(
                        doc.data() as Map<String, dynamic>, doc.id);
                  }).toList();

                  // 2. Filter based on the selected tab
                  List<AlertItem> filteredAlerts = allAlerts.where((alert) {
                    if (_selectedTab == 1) return alert.severity == AlertSeverity.warning;
                    if (_selectedTab == 2) return alert.severity == AlertSeverity.critical;
                    return true; // If _selectedTab is 0, show all
                  }).toList();

                  if (filteredAlerts.isEmpty) {
                    return Center(
                      child: Text(
                        'No alerts in this category',
                        style: TextStyle(color: Colors.grey.shade500),
                      ),
                    );
                  }

                  // 3. Build the UI List
                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    itemCount: filteredAlerts.length,
                    itemBuilder: (context, index) {
                      final alert = filteredAlerts[index];
                      final isCritical = alert.severity == AlertSeverity.critical;
                      return _buildAlertCard(context, alert, isCritical);
                    },
                  );
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
                    color: accentColor.withOpacity(0.1),
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
                          // UPDATED: Now calls the newly formatted DateTime getter
                          Text(
                            alert.formattedDateTime,
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
                      // REAL ZEGOCLOUD CALL TRIGGER
                      ZegocloudVoipService.startCall(
                        calleeId: "patient_001", // The ID of the smartwatch
                        calleeName: "Patient Watch",
                        isVideoCall: false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: const Text('Call Now', style: TextStyle(color: Colors.white)),
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
          ],
        ),
      ),
    );
  }
}