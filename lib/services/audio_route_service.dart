import 'package:flutter/services.dart';

class AudioRouteService {
  static const MethodChannel _channel = MethodChannel('eldercareapp/audio');

  /// Turn the speakerphone on or off.
  /// Returns true on success.
  static Future<bool> setSpeakerphoneOn(bool on) async {
    try {
      final res = await _channel.invokeMethod('setSpeakerphoneOn', {'on': on});
      return res == true;
    } on PlatformException catch (e) {
      // ignore errors but log if needed
      return false;
    }
  }
}
