# Calling Feature - Zegocloud VoIP Integration

This folder contains the VoIP calling implementation using Zegocloud for voice and video calls, with special support for smartwatch devices.

## Contents

### Files

1. **zegocloud_call_screen.dart**
   - Main call screen UI for phone/tablet devices
   - Handles incoming/outgoing calls
   - Microphone and camera controls
   - Call timer and status display

2. **smartwatch_call_widget.dart**
   - Optimized UI for smartwatch displays (< 280px width)
   - Large, readable text and buttons
   - Simplified controls for small screens
   - Radial menu layout for smartwatch interactions

3. **quick_dial_widget.dart**
   - Quick dial widget for initiating calls
   - Recent contacts display
   - Pre-customizable with default recipients
   - Automatically detects smartwatch and shows appropriate UI

## Features

### Call States
- **Idle**: No active call
- **Outgoing**: Dialing phase
- **Ringing**: Waiting for answer
- **Connected**: Active call in progress
- **Disconnecting**: Ending call
- **Disconnected**: Call ended
- **Error**: Call failed

### Call Controls
- ✅ Microphone toggle (mute/unmute)
- ✅ Camera toggle (for video calls)
- ✅ Call end button
- ✅ Call accept/reject for incoming calls
- ✅ Call duration tracking
- ✅ Call status indicators

### Smartwatch Features
- 📱 Automatic detection of small screens
- 🎯 Large touch targets for wearable devices
- 📊 Simplified status display
- 🔇 Core microphone control
- ⏱️ Easy-to-read call duration

## Usage

### Basic Voice Call on Phone
```dart
Navigator.of(context).push(
  MaterialPageRoute(
    builder: (context) => ZegocloudCallScreen(
      calleeId: 'user_id',
      calleeName: 'John Doe',
      isVideoCall: false,
    ),
  ),
);
```

### Smartwatch Call
```dart
showDialog(
  context: context,
  barrierDismissible: false,
  builder: (context) => Dialog(
    insetPadding: EdgeInsets.zero,
    child: SmartwatchCallWidget(
      calleeId: 'user_id',
      calleeName: 'John Doe',
      onCallEnded: () => Navigator.pop(context),
    ),
  ),
);
```

### Quick Dial Widget
```dart
QuickDialWidget(
  enableSmartwatch: true,
  defaultCalleeId: 'default_user',
  defaultCalleeName: 'Caregiver',
)
```

## Integration Steps

1. **Update pubspec.yaml** with Zegocloud dependencies ✅ (Already done)
2. **Configure Zegocloud credentials** in `services/zegocloud_voip_service.dart`
3. **Add CallProvider** to main.dart MultiProvider ✅ (Already done)
4. **Add calling UI** to your home page (see CALLING_EXAMPLES.dart)
5. **Configure permissions** (see ZEGOCLOUD_SETUP.md)

## Platform Support

- ✅ Android Phone
- ✅ iOS Phone
- ✅ Android Smartwatch (Wear OS)
- ✅ iOS Watch (watchOS)
- ✅ Android Tablet
- ✅ iPad

## Smartwatch Detection

The app automatically detects smartwatch screens based on width:
```dart
final screenSize = MediaQuery.of(context).size;
final isSmartwatchSize = screenSize.width < 280;
```

Devices with width < 280px will use the simplified SmartwatchCallWidget UI.

## Related Files

- **Service**: `lib/services/zegocloud_voip_service.dart`
- **Provider**: `lib/core/providers/call_provider.dart`
- **Setup Guide**: `ZEGOCLOUD_SETUP.md` (in project root)
- **Examples**: `CALLING_EXAMPLES.dart` (in this folder)

## Configuration

### AppID and AppSign
Before using, configure Zegocloud credentials in:
```dart
// lib/services/zegocloud_voip_service.dart
static const int appID = YOUR_APP_ID;
static const String appSign = 'YOUR_APP_SIGN';
```

Get these from: https://console.zegocloud.com

### Permissions
- **Android**: Microphone, Camera, Network
- **iOS**: Microphone, Camera (via Info.plist)

See ZEGOCLOUD_SETUP.md for complete permission configuration.

## Best Practices

1. **Request Permissions Early**: Call `ZegocloudVoipService.requestPermissions()` on app start
2. **Handle Errors**: Use CallProvider error states and message display
3. **Cleanup**: CallProvider automatically manages resources in dispose()
4. **Testing**: Test on actual smartwatch devices for best experience
5. **Accessibility**: Ensure call controls are accessible to elderly users

## Troubleshooting

### No Audio During Call
- Check microphone permissions are granted
- Verify permissions in AndroidManifest.xml and Info.plist
- Test microphone in system settings

### Smartwatch UI Not Showing
- Check device screen width (< 280px)
- Verify enableSmartwatch=true in QuickDialWidget
- Check device is actually recognized as smartwatch

### Call Won't Connect
- Verify AppID and AppSign in zegocloud_voip_service.dart
- Check both devices have internet connection
- Verify Zegocloud credentials are valid

### Permission Errors on Android
- Run `flutter clean` and rebuild
- Check android/app/src/main/AndroidManifest.xml has all permissions
- Verify compileSdk and targetSdk are at least 33

## Future Enhancements

- [ ] Call recording
- [ ] Screen sharing
- [ ] Video call support
- [ ] Call history persistence
- [ ] Call notifications/ringtone
- [ ] Multi-party group calls
- [ ] Call quality monitoring
- [ ] Call logs/analytics

## Support

- Zegocloud Docs: https://doc.zegocloud.com/
- Flutter VoIP Guide: https://pub.dev/packages/zego_uikit_prebuilt_call
- Project Setup: See ZEGOCLOUD_SETUP.md
