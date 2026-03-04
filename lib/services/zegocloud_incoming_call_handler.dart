import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:eldercareapp/core/providers/call_provider.dart';

/// When an incoming call arrives via Zego, the built-in invitation UI automatically shows.
/// This handler can be used to sync the call info with your custom [CallProvider] if needed.
/// 
/// For most use cases, Zego's built-in UI is sufficient and handles:
/// - Showing incoming call screen
/// - Accept/Reject buttons
/// - Connecting to the call
/// 
/// This is here as a reference for custom call handling if required.
class ZegocloudIncomingCallHandler {
  /// If you want to manually track incoming calls in your CallProvider,
  /// you can call this method—but Zego's built-in UI handles everything by default.
  static void logIncomingCall({
    required String callerId,
    required String callerName,
    required bool isVideoCall,
  }) {
    print(
      '[Incoming Call] From: $callerName (ID: $callerId), '
      'Video: $isVideoCall',
    );
    // If you need custom behavior (e.g., local logging, analytics),
    // add it here.
  }
}
