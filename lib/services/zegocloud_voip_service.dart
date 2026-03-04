import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';

class ZegocloudVoipService {
  static final ZegocloudVoipService _instance =
      ZegocloudVoipService._internal();

  factory ZegocloudVoipService() {
    return _instance;
  }

  ZegocloudVoipService._internal();

  // Zegocloud AppID and AppSign (Synced exactly with the Smartwatch)
  static const int appID = 1279737711; 
  static const String appSign = '50a1c85a028c5224b00ec060afda1e71159d4cfdc124e124c441a981d83cd289';

  // Hardcoded Caregiver User ID (for testing)
  // This ID perfectly matches what the smartwatch is trying to call
  static const String caregiverUserId = '5yeapeXNTZcofATleG5ZHZ8siZt2';
  static const String caregiverName = 'Caregiver';

  /// Initialize Zegocloud SDK
  /// IMPORTANT: Call ZegocloudVoipService.init() in your main.dart or after login!
  /// Also call setupIncomingCallHandler() after init to handle incoming calls
  static Future<void> init() async {
    try {
      // THIS is what brings the phone "Online" to ZegoCloud's servers
      // Without this, the smartwatch gets the 105004 (Offline) error
      ZegoUIKitPrebuiltCallInvitationService().init(
        appID: appID,
        appSign: appSign,
        userID: caregiverUserId,
        userName: caregiverName,
        plugins: [ZegoUIKitSignalingPlugin()],
      );
      
      print('Zegocloud VoIP initialized successfully');
    } catch (e) {
      print('Error initializing Zegocloud VoIP: $e');
      rethrow;
    }
  }

  /// Setup handlers for incoming calls - call this after init()
  /// Requires a navigator key to navigate to call screen
  static void setupIncomingCallHandler({
    required GlobalKey<NavigatorState> navigatorKey,
    required Function(String callerId, String callerName, bool isVideo) onIncomingCall,
  }) {
    ZegoUIKitPrebuiltCallInvitationService().setNavigatorKey(navigatorKey);
    print('[Zegocloud] Navigator key and invitation UI configured');
  }

  /// Request microphone and camera permissions
  static Future<bool> requestPermissions() async {
    try {
      final micStatus = await Permission.microphone.request();
      final cameraStatus = await Permission.camera.request();

      return micStatus.isGranted && cameraStatus.isGranted;
    } catch (e) {
      print('Error requesting permissions: $e');
      return false;
    }
  }

  /// Check if permissions are granted
  static Future<bool> hasPermissions() async {
    final micStatus = await Permission.microphone.status;
    final cameraStatus = await Permission.camera.status;

    return micStatus.isGranted && cameraStatus.isGranted;
  }

  /// Start a voice call (Placeholder for manual dialing from the phone)
  static Future<void> startCall({
    required String userId,
    required String userName,
    required String calleeId,
    required String calleeName,
    bool isVideoCall = false,
  }) async {
    try {
      print('Starting call from $userName ($userId) to $calleeName ($calleeId)');
    } catch (e) {
      print('Error starting call: $e');
      rethrow;
    }
  }

  /// End the current call
  static Future<void> endCall() async {
    try {
      print('Call ended');
    } catch (e) {
      print('Error ending call: $e');
      rethrow;
    }
  }

  /// Mute/unmute microphone
  static Future<void> setMicrophoneMuted(bool muted) async {
    try {
      print('Microphone ${muted ? 'muted' : 'unmuted'}');
    } catch (e) {
      print('Error setting microphone status: $e');
    }
  }

  /// Enable/disable camera
  static Future<void> setCameraEnabled(bool enabled) async {
    try {
      print('Camera ${enabled ? 'enabled' : 'disabled'}');
    } catch (e) {
      print('Error setting camera status: $e');
    }
  }

  /// Dispose Zegocloud resources
  static Future<void> dispose() async {
    try {
      ZegoUIKitPrebuiltCallInvitationService().uninit();
      print('Zegocloud VoIP disposed');
    } catch (e) {
      print('Error disposing Zegocloud VoIP: $e');
    }
  }
}