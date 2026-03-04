import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eldercareapp/core/providers/call_provider.dart';

class ZegocloudCallScreen extends StatefulWidget {
  final String calleeId;
  final String calleeName;
  final bool isVideoCall;
  final bool incoming;

  const ZegocloudCallScreen({
    super.key,
    required this.calleeId,
    required this.calleeName,
    this.isVideoCall = false,
    this.incoming = false,
  });

  @override
  State<ZegocloudCallScreen> createState() => _ZegocloudCallScreenState();
}

class _ZegocloudCallScreenState extends State<ZegocloudCallScreen> {
  late CallProvider _callProvider;

  @override
  void initState() {
    super.initState();
    _callProvider = Provider.of<CallProvider>(context, listen: false);
    // Only initiate outgoing call if this is not an incoming call
    if (!widget.incoming) {
      _initializeCall();
    }
  }

  Future<void> _initializeCall() async {
    await _callProvider.initiateCall(
      calleeId: widget.calleeId,
      calleeName: widget.calleeName,
      isVideoCall: widget.isVideoCall,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: Consumer<CallProvider>(
        builder: (context, callProvider, _) {
          return Stack(
            children: [
              // Main call display
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Caller info
                    CircleAvatar(
                      radius: 60,
                      child: Text(
                        widget.calleeName.isNotEmpty
                            ? widget.calleeName[0].toUpperCase()
                            : '?',
                        style: const TextStyle(fontSize: 40),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      widget.calleeName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Call status and duration
                    if (callProvider.callState == CallState.outgoing)
                      const Text(
                        'Calling...',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                    if (callProvider.callState == CallState.ringing)
                      const Text(
                        'Ringing...',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                    if (callProvider.callState == CallState.connected)
                      Text(
                        _formatDuration(callProvider.callDuration),
                        style: const TextStyle(
                          color: Colors.greenAccent,
                          fontSize: 16,
                        ),
                      ),
                  ],
                ),
              ),

              // Control buttons at bottom
              Positioned(
                bottom: 40,
                left: 0,
                right: 0,
                child: _buildCallControls(callProvider),
              ),

              // Error message
              if (callProvider.callState == CallState.error)
                Positioned(
                  top: 50,
                  left: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade700,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      callProvider.errorMessage ?? 'An error occurred',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCallControls(CallProvider callProvider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Microphone toggle
        if (callProvider.isCallActive)
          FloatingActionButton(
            onPressed: callProvider.toggleMicrophone,
            backgroundColor: callProvider.isMicrophoneMuted
                ? Colors.red.shade700
                : Colors.grey.shade700,
            child: Icon(
              callProvider.isMicrophoneMuted ? Icons.mic_off : Icons.mic,
              color: Colors.white,
            ),
          ),
        const SizedBox(width: 20),

        // Camera toggle (only for video calls)
        if (widget.isVideoCall && callProvider.isCallActive)
          FloatingActionButton(
            onPressed: callProvider.toggleCamera,
            backgroundColor: !callProvider.isCameraEnabled
                ? Colors.red.shade700
                : Colors.grey.shade700,
            child: Icon(
              callProvider.isCameraEnabled ? Icons.videocam : Icons.videocam_off,
              color: Colors.white,
            ),
          ),
        if (widget.isVideoCall && callProvider.isCallActive)
          const SizedBox(width: 20),

        // End call button
        FloatingActionButton(
          onPressed: () async {
            await callProvider.endCall();
            if (mounted) {
              Navigator.of(context).pop();
            }
          },
          backgroundColor: Colors.red,
          child: const Icon(
            Icons.call_end,
            color: Colors.white,
          ),
        ),

        // Accept call button (for incoming calls)
        if (callProvider.callState == CallState.ringing)
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: FloatingActionButton(
              onPressed: () async {
                await callProvider.acceptCall();
              },
              backgroundColor: Colors.green,
              child: const Icon(
                Icons.call,
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
