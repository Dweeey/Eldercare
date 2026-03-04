import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eldercareapp/core/providers/call_provider.dart';
import 'dart:async';

/// Smartwatch-optimized call widget for small screens
/// Designed for wearable devices with limited screen real estate
class SmartwatchCallWidget extends StatefulWidget {
  final String calleeId;
  final String calleeName;
  final Function? onCallEnded;

  const SmartwatchCallWidget({
    super.key,
    required this.calleeId,
    required this.calleeName,
    this.onCallEnded,
  });

  @override
  State<SmartwatchCallWidget> createState() => _SmartwatchCallWidgetState();
}

class _SmartwatchCallWidgetState extends State<SmartwatchCallWidget> {
  late Timer _durationTimer;
  late CallProvider _callProvider;

  @override
  void initState() {
    super.initState();
    _callProvider = Provider.of<CallProvider>(context, listen: false);
    _initializeCall();
    _startDurationTimer();
  }

  Future<void> _initializeCall() async {
    await _callProvider.initiateCall(
      calleeId: widget.calleeId,
      calleeName: widget.calleeName,
      isVideoCall: false, // Smartwatch typically doesn't support video
    );
  }

  void _startDurationTimer() {
    _durationTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        _callProvider.updateCallDuration();
      },
    );
  }

  @override
  void dispose() {
    _durationTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions for smartwatch optimization
    final screenSize = MediaQuery.of(context).size;
    final isSmartwatchSize = screenSize.width < 280;

    return Consumer<CallProvider>(
      builder: (context, callProvider, _) {
        return Container(
          color: const Color(0xFF1A1A1A),
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(isSmartwatchSize ? 8.0 : 16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Caller name (large text for smartwatch readability)
                  Text(
                    widget.calleeName.length > 12
                        ? widget.calleeName.substring(0, 12)
                        : widget.calleeName,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isSmartwatchSize ? 14 : 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: isSmartwatchSize ? 8 : 12),

                  // Call status indicator
                  _buildStatusIndicator(callProvider, isSmartwatchSize),
                  SizedBox(height: isSmartwatchSize ? 6 : 12),

                  // Call duration during active call
                  if (callProvider.callState == CallState.connected)
                    Text(
                      _formatDuration(callProvider.callDuration),
                      style: TextStyle(
                        color: Colors.greenAccent,
                        fontSize: isSmartwatchSize ? 12 : 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  SizedBox(height: isSmartwatchSize ? 8 : 16),

                  // Smartwatch controls (circular layout for radial menus)
                  if (callProvider.isCallActive)
                    _buildSmartwatchControls(callProvider, isSmartwatchSize),

                  // End call button (always visible and prominent)
                  SizedBox(height: isSmartwatchSize ? 4 : 8),
                  SizedBox(
                    width: double.infinity,
                    height: isSmartwatchSize ? 32 : 40,
                    child: ElevatedButton(
                      onPressed: () async {
                        await callProvider.endCall();
                        widget.onCallEnded?.call();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade600,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Icon(
                        Icons.call_end,
                        color: Colors.white,
                        size: isSmartwatchSize ? 14 : 16,
                      ),
                    ),
                  ),

                  // Error display
                  if (callProvider.callState == CallState.error)
                    Padding(
                      padding: EdgeInsets.only(top: isSmartwatchSize ? 6 : 12),
                      child: Container(
                        padding: EdgeInsets.all(isSmartwatchSize ? 4 : 8),
                        decoration: BoxDecoration(
                          color: Colors.red.shade800,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          callProvider.errorMessage ?? 'Call error',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isSmartwatchSize ? 10 : 12,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusIndicator(CallProvider callProvider, bool isSmartwatchSize) {
    String statusText = '';
    Color statusColor = Colors.grey;

    switch (callProvider.callState) {
      case CallState.outgoing:
        statusText = 'Calling...';
        statusColor = Colors.amber;
        break;
      case CallState.ringing:
        statusText = 'Ringing...';
        statusColor = Colors.amber;
        break;
      case CallState.connected:
        statusText = 'Connected';
        statusColor = Colors.green;
        break;
      case CallState.disconnecting:
        statusText = 'Disconnecting...';
        statusColor = Colors.orange;
        break;
      case CallState.disconnected:
        statusText = 'Disconnected';
        statusColor = Colors.grey;
        break;
      case CallState.error:
        statusText = 'Error';
        statusColor = Colors.red;
        break;
      case CallState.idle:
        statusText = 'Ready';
        statusColor = Colors.grey;
        break;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: isSmartwatchSize ? 6 : 8,
          height: isSmartwatchSize ? 6 : 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: statusColor,
          ),
        ),
        SizedBox(width: isSmartwatchSize ? 4 : 6),
        Text(
          statusText,
          style: TextStyle(
            color: statusColor,
            fontSize: isSmartwatchSize ? 10 : 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildSmartwatchControls(
    CallProvider callProvider,
    bool isSmartwatchSize,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Microphone toggle
        SizedBox(
          width: isSmartwatchSize ? 32 : 40,
          height: isSmartwatchSize ? 32 : 40,
          child: FloatingActionButton(
            mini: isSmartwatchSize,
            onPressed: callProvider.toggleMicrophone,
            backgroundColor: callProvider.isMicrophoneMuted
                ? Colors.red.shade700
                : Colors.grey.shade600,
            child: Icon(
              callProvider.isMicrophoneMuted ? Icons.mic_off : Icons.mic,
              size: isSmartwatchSize ? 12 : 14,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}
