import 'package:flutter/material.dart';
import 'package:eldercareapp/features/calling/presentation/zegocloud_call_screen.dart';
import 'package:eldercareapp/features/calling/presentation/smartwatch_call_widget.dart';

/// Quick dial widget for initiating voice calls
/// Can be added to the home page or any screen where calls need to be initiated
class QuickDialWidget extends StatefulWidget {
  final String? defaultCalleeId;
  final String? defaultCalleeName;
  final bool enableSmartwatch;

  const QuickDialWidget({
    super.key,
    this.defaultCalleeId,
    this.defaultCalleeName,
    this.enableSmartwatch = false,
  });

  @override
  State<QuickDialWidget> createState() => _QuickDialWidgetState();
}

class _QuickDialWidgetState extends State<QuickDialWidget> {
  final TextEditingController _calleeIdController = TextEditingController();
  final TextEditingController _calleeNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.defaultCalleeId != null) {
      _calleeIdController.text = widget.defaultCalleeId!;
    }
    if (widget.defaultCalleeName != null) {
      _calleeNameController.text = widget.defaultCalleeName!;
    }
  }

  @override
  void dispose() {
    _calleeIdController.dispose();
    _calleeNameController.dispose();
    super.dispose();
  }

  void _initiateCall(BuildContext context) {
    final calleeId = _calleeIdController.text.trim();
    final calleeName = _calleeNameController.text.trim();

    if (calleeId.isEmpty || calleeName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both ID and name')),
      );
      return;
    }

    // Check if smartwatch size
    final screenSize = MediaQuery.of(context).size;
    final isSmartwatchSize = screenSize.width < 280;

    if (isSmartwatchSize && widget.enableSmartwatch) {
      // Show smartwatch call widget in a fullscreen dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Dialog(
          insetPadding: EdgeInsets.zero,
          child: SmartwatchCallWidget(
            calleeId: calleeId,
            calleeName: calleeName,
            onCallEnded: () => Navigator.pop(context),
          ),
        ),
      );
    } else {
      // Navigate to regular call screen
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ZegocloudCallScreen(
            calleeId: calleeId,
            calleeName: calleeName,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Dial',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _calleeIdController,
              decoration: InputDecoration(
                labelText: 'Recipient ID',
                hintText: 'Enter recipient ID',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _calleeNameController,
              decoration: InputDecoration(
                labelText: 'Recipient Name',
                hintText: 'Enter recipient name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.edit),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _initiateCall(context),
                icon: const Icon(Icons.call),
                label: const Text('Start Call'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Call history/contacts widget for quick access
class CallContactsWidget extends StatelessWidget {
  final List<Map<String, String>> contacts;

  const CallContactsWidget({
    super.key,
    required this.contacts,
  });

  @override
  Widget build(BuildContext context) {
    if (contacts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'No contacts yet. Add contacts to start calling.',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: contacts.length,
      itemBuilder: (context, index) {
        final contact = contacts[index];
        final contactId = contact['id'] ?? '';
        final contactName = contact['name'] ?? '';

        return ListTile(
          leading: CircleAvatar(
            child: Text(contactName.isNotEmpty ? contactName[0] : '?'),
          ),
          title: Text(contactName),
          subtitle: Text(contactId),
          trailing: IconButton(
            icon: const Icon(Icons.call, color: Colors.green),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ZegocloudCallScreen(
                    calleeId: contactId,
                    calleeName: contactName,
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
