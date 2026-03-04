import 'package:flutter/material.dart';
import 'package:eldercareapp/services/audio_route_service.dart';

enum CallState {
  idle,
  outgoing,
  ringing,
  connected,
  disconnecting,
  disconnected,
  error,
}

class CallProvider extends ChangeNotifier {
  // Call state
  CallState _callState = CallState.idle;
  String? _currentCalleeId;
  String? _currentCalleeName;
  bool _isMicrophoneMuted = false;
  bool _isCameraEnabled = true;
  Duration _callDuration = Duration.zero;
  late Stopwatch _callTimer;
  String? _errorMessage;

  // Getters
  CallState get callState => _callState;
  String? get currentCalleeId => _currentCalleeId;
  String? get currentCalleeName => _currentCalleeName;
  bool get isMicrophoneMuted => _isMicrophoneMuted;
  bool get isCameraEnabled => _isCameraEnabled;
  Duration get callDuration => _callDuration;
  String? get errorMessage => _errorMessage;
  bool get isCallActive =>
      _callState == CallState.connected ||
      _callState == CallState.ringing ||
      _callState == CallState.outgoing;

  CallProvider() {
    _callTimer = Stopwatch();
  }

  /// Start an outgoing call
  Future<void> initiateCall({
    required String calleeId,
    required String calleeName,
    bool isVideoCall = false,
  }) async {
    try {
      _callState = CallState.outgoing;
      _currentCalleeId = calleeId;
      _currentCalleeName = calleeName;
      _callDuration = Duration.zero;
      _errorMessage = null;
      notifyListeners();

      // Start timer for call duration
      _callTimer.start();

      // Update to ringing after a brief delay
      await Future.delayed(const Duration(milliseconds: 500));
      _callState = CallState.ringing;
      notifyListeners();
    } catch (e) {
      _callState = CallState.error;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// Simulates call being accepted/connected
  Future<void> acceptCall() async {
    try {
      if (_callState != CallState.ringing) {
        throw Exception('No incoming call to accept');
      }
      _callState = CallState.connected;
      // Force speakerphone on when connected (helps with smartwatch -> phone audio)
      try {
        await AudioRouteService.setSpeakerphoneOn(true);
      } catch (_) {}
      notifyListeners();
    } catch (e) {
      _callState = CallState.error;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// End the current call
  Future<void> endCall() async {
    try {
      _callState = CallState.disconnecting;
      notifyListeners();

      _callTimer.stop();
      await Future.delayed(const Duration(milliseconds: 500));

      _callState = CallState.disconnected;
      _currentCalleeId = null;
      _currentCalleeName = null;
      _isMicrophoneMuted = false;
      _isCameraEnabled = true;
      notifyListeners();

      // Reset to idle after a brief delay
      await Future.delayed(const Duration(milliseconds: 1000));
      _callState = CallState.idle;
      _callDuration = Duration.zero;
      notifyListeners();
    } catch (e) {
      _callState = CallState.error;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// Reject an incoming call
  Future<void> rejectCall() async {
    resetCall();
  }

  /// Handle incoming call from Zego
  void incomingCall({
    required String callerId,
    required String callerName,
    bool isVideo = false,
  }) {
    _callState = CallState.ringing;
    _currentCalleeId = callerId;
    _currentCalleeName = callerName;
    _callDuration = Duration.zero;
    _errorMessage = null;
    notifyListeners();
  }

  /// Toggle microphone mute status
  void toggleMicrophone() {
    _isMicrophoneMuted = !_isMicrophoneMuted;
    notifyListeners();
  }

  /// Toggle camera status
  void toggleCamera() {
    _isCameraEnabled = !_isCameraEnabled;
    notifyListeners();
  }

  /// Update call duration
  void updateCallDuration() {
    if (_callTimer.isRunning) {
      _callDuration = _callTimer.elapsed;
      notifyListeners();
    }
  }

  /// Reset call state
  void resetCall() {
    _callState = CallState.idle;
    _currentCalleeId = null;
    _currentCalleeName = null;
    _isMicrophoneMuted = false;
    _isCameraEnabled = true;
    _callDuration = Duration.zero;
    _errorMessage = null;
    _callTimer.stop();
    _callTimer.reset();
    notifyListeners();
  }

  /// Handle call errors
  void setError(String message) {
    _callState = CallState.error;
    _errorMessage = message;
    notifyListeners();
  }

  @override
  void dispose() {
    if (_callTimer.isRunning) {
      _callTimer.stop();
    }
    super.dispose();
  }
}
