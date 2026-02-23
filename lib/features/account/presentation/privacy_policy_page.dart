import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        backgroundColor: Colors.blue,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              title: '1. Introduction',
              content:
                  'ElderCare ("we", "us", "our", or "Company") operates the ElderCare mobile application (the "Service"). This page informs you of our policies regarding the collection, use, and disclosure of personal data when you use our Service and the choices you have associated with that data.',
            ),
            _buildSection(
              title: '2. Information Collection and Use',
              content:
                  'We collect several different types of information for various purposes to provide and improve our Service to you.\n\n'
                  '• Personal Data: While using our Service, we may ask you to provide us with certain personally identifiable information that can be used to contact or identify you ("Personal Data"). This may include, but is not limited to:\n'
                  '  - Email address\n'
                  '  - First name and last name\n'
                  '  - Phone number\n'
                  '  - Address, State, Province, ZIP/Postal code, City\n'
                  '  - Cookies and Usage Data\n\n'
                  '• Usage Data: We may also collect information on how the Service is accessed and used ("Usage Data"). This may include information such as your computer\'s Internet Protocol address (e.g. IP address), browser type, browser version, the pages you visit, the time and date of your visit, the time spent on those pages, and other diagnostic data.',
            ),
            _buildSection(
              title: '3. Health Information',
              content:
                  'ElderCare collects and stores health-related information including medical history, medications, emergency contacts, and health metrics. This information is treated with the highest level of confidentiality and is protected under applicable health privacy laws including HIPAA.',
            ),
            _buildSection(
              title: '4. Use of Data',
              content:
                  'ElderCare uses the collected data for various purposes:\n\n'
                  '• To provide and maintain our Service\n'
                  '• To notify you about changes to our Service\n'
                  '• To allow you to participate in interactive features of our Service\n'
                  '• To provide customer support\n'
                  '• To gather analysis or valuable information so that we can improve our Service\n'
                  '• To monitor the usage of our Service\n'
                  '• To detect, prevent and address technical issues',
            ),
            _buildSection(
              title: '5. Security of Data',
              content:
                  'The security of your data is important to us but remember that no method of transmission over the Internet or method of electronic storage is 100% secure. While we strive to use commercially acceptable means to protect your Personal Data, we cannot guarantee its absolute security.',
            ),
            _buildSection(
              title: '6. Changes to This Privacy Policy',
              content:
                  'We may update our Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page and updating the "effective date" at the top of this Privacy Policy.',
            ),
            _buildSection(
              title: '7. Contact Us',
              content:
                  'If you have any questions about this Privacy Policy, please contact us at:\n\n'
                  'Email: privacy@eldercare.com\n'
                  'Phone: 1-800-ELDERCARE\n'
                  'Address: ElderCare Support, 123 Health Street, Medical City, MC 12345',
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Last Updated',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'January 1, 2024',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String content,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade700,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
