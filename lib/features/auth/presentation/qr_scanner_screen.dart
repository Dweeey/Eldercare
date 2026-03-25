import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:eldercareapp/services/qr_code_service.dart';
import 'package:eldercareapp/services/firestore_service.dart';
import 'package:eldercareapp/services/firebase_auth_service.dart';

class QRCodeScannerScreen extends StatefulWidget {
  const QRCodeScannerScreen({super.key});

  @override
  State<QRCodeScannerScreen> createState() => _QRCodeScannerScreenState();
}

class _QRCodeScannerScreenState extends State<QRCodeScannerScreen> {
  final MobileScannerController controller = MobileScannerController();
  final QRCodeService _qrService = QRCodeService();
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuthService _authService = FirebaseAuthService();

  bool isProcessing = false;
  String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Link Smartwatch'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () => controller.toggleTorch(),
          ),
          IconButton(
            icon: const Icon(Icons.flip_camera_android),
            onPressed: () => controller.switchCamera(),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 4,
            child: MobileScanner(
              controller: controller,
              onDetect: _onQRDetect,
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(16),
              color: Colors.grey[900],
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        errorMessage!,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  if (isProcessing)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  else
                    const Text(
                      'Point your camera at the smartwatch QR code',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onQRDetect(BarcodeCapture capture) async {
    if (isProcessing) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final qrCode = barcodes.first.rawValue;
    if (qrCode == null) return;

    setState(() {
      isProcessing = true;
      errorMessage = null;
    });

    try {
      // Parse QR code
      final scannedId = _qrService.parseSmartwatchQRCode(qrCode);

      if (scannedId == null) {
        setState(() {
          errorMessage = 'Invalid QR code format';
          isProcessing = false;
        });
        return;
      }

      // Validate the scanned ID
      if (!_qrService.isValidSmartwatchId(scannedId)) {
        setState(() {
          errorMessage = 'Invalid smartwatch ID format';
          isProcessing = false;
        });
        return;
      }

      // Get current user
      final currentUser = _authService.currentUser;
      if (currentUser == null) {
        setState(() {
          errorMessage = 'User not logged in';
          isProcessing = false;
        });
        return;
      }

      // Handle different ID formats
      if (_qrService.isSmartwatchPairingId(scannedId)) {
        // This is a smartwatch pairing ID (WATCH_XXXXXX)
        // Update the pairing_requests document in Firestore
        await _updatePairingRequest(scannedId, currentUser.uid);
      } else if (_qrService.isPatientId(scannedId)) {
        // This is a patient ID (patient_XXXXX)
        // Legacy format - link smartwatch directly
        await _firestoreService.linkSmartwatchToUser(
          currentUser.uid,
          scannedId,
        );
      }

      // Show success message and navigate back
      if (mounted) {
        Navigator.of(context).pop(scannedId);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Smartwatch linked successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error linking smartwatch: ${e.toString()}';
        isProcessing = false;
      });
    }
  }

  /// Update the pairing_requests document with the user's patient ID
  /// This tells the smartwatch that the user has been authenticated
  Future<void> _updatePairingRequest(String pairingId, String userId) async {
    try {
      // Get user's patient ID from Firestore
      final userDoc = await _firestoreService.getUser(userId);
      var patientId = userDoc?['linkedPatientId'] as String?;

      // If user doesn't have a linked patient ID, ask them to enter one
      if (patientId == null) {
        if (!mounted) return;
        
        patientId = await _showPatientIdDialog();
        if (patientId == null) {
          throw Exception('Patient ID is required to link smartwatch');
        }

        // Save the patient ID to the user's Firestore document
        await _firestoreService.setUserPatientId(userId, patientId);
      }

      // Update the pairing_requests document
      // The smartwatch is listening for this update
      await _firestoreService.updatePairingRequest(
        pairingId,
        patientId,
        userId,
      );
    } catch (e) {
      print('Error updating pairing request: $e');
      rethrow;
    }
  }

  /// Show dialog to ask user for their patient ID
  Future<String?> _showPatientIdDialog() async {
    final TextEditingController controller = TextEditingController();
    
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter Patient ID'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Before linking your smartwatch, please enter your patient ID.\n\nThis ID is provided by your healthcare provider.',
                style: TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: 'e.g., patient_001',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.person),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final value = controller.text.trim();
                if (value.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a patient ID')),
                  );
                  return;
                }
                Navigator.of(context).pop(value);
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
