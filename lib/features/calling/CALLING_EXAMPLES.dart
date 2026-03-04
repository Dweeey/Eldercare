// Example: How to integrate Zegocloud calling into your home page

import 'package:flutter/material.dart';
import 'package:eldercareapp/features/calling/presentation/quick_dial_widget.dart';
import 'package:eldercareapp/features/calling/presentation/zegocloud_call_screen.dart';
import 'package:eldercareapp/features/calling/presentation/smartwatch_call_widget.dart';

// Example 1: Add Quick Dial to your home page
class HomePageWithCalling extends StatelessWidget {
  const HomePageWithCalling({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Your existing widgets...
          
          // Add Quick Dial Widget
          QuickDialWidget(
            enableSmartwatch: true,
            // Optional: Pre-fill with caregiver info
            defaultCalleeId: 'caregiver_user_id',
            defaultCalleeName: 'Dr. Smith (Caregiver)',
          ),
          
          // Your other widgets...
        ],
      ),
    );
  }
}

// Example 2: Add Quick Call Button to Home Page
class HomePageWithQuickCallButton extends StatelessWidget {
  const HomePageWithQuickCallButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Emergency/Quick Call Button
            ElevatedButton.icon(
              onPressed: () {
                // Navigate to call screen with pre-configured caregiver
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ZegocloudCallScreen(
                      calleeId: 'caregiver_id',
                      calleeName: 'Main Caregiver',
                      isVideoCall: false,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.call, size: 32),
              label: const Text('Call Caregiver'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            
            // Other emergency buttons
            ElevatedButton.icon(
              onPressed: () {
                // Add SOS logic
              },
              icon: const Icon(Icons.emergency, size: 32),
              label: const Text('SOS'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Example 3: Show Recent Contacts for Calling
class CallHistoryExample extends StatelessWidget {
  final List<Map<String, String>> recentContacts = [
    {'id': 'user_1', 'name': 'Dr. John Smith'},
    {'id': 'user_2', 'name': 'Nurse Maria'},
    {'id': 'user_3', 'name': 'Family (James)'},
  ];

  const CallHistoryExample({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: recentContacts.length,
      itemBuilder: (context, index) {
        final contact = recentContacts[index];
        return ListTile(
          leading: CircleAvatar(
            child: Text(contact['name']![0]),
          ),
          title: Text(contact['name']!),
          trailing: IconButton(
            icon: const Icon(Icons.call, color: Colors.green),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ZegocloudCallScreen(
                    calleeId: 'contact_id',
                    calleeName: 'contact_name',
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

// Example 4: Smartwatch-specific integration
void showSmartWatchCall(BuildContext context) {
  final screenSize = MediaQuery.of(context).size;
  final isSmartwatchSize = screenSize.width < 280;

  if (isSmartwatchSize) {
    // On smartwatch, show full-screen call interface
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        insetPadding: EdgeInsets.zero,
        child: SmartwatchCallWidget(
          calleeId: 'caregiver_id',
          calleeName: 'Caregiver',
          onCallEnded: () => Navigator.pop(context),
        ),
      ),
    );
  } else {
    // On phone, use regular call screen
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ZegocloudCallScreen(
          calleeId: 'caregiver_id',
          calleeName: 'Caregiver',
        ),
      ),
    );
  }
}

// Import this into home_page.dart
/*
import 'package:eldercareapp/features/calling/presentation/zegocloud_call_screen.dart';
import 'package:eldercareapp/features/calling/presentation/smartwatch_call_widget.dart';
import 'package:eldercareapp/features/calling/presentation/quick_dial_widget.dart';

Then use the examples above to add calling functionality to your home page.
*/
