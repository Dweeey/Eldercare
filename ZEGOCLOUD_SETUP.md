# Zegocloud VoIP Integration Guide

## Overview
This guide explains how to set up and use Zegocloud VoIP functionality in your eldercare app, including smartwatch support.

## Prerequisites
1. Zegocloud account (https://console.zegocloud.com)
2. AppID and AppSign credentials from Zegocloud Console
3. Flutter 3.10.1 or higher
4. Android and iOS development environments set up

## Setup Steps

### 1. Get Zegocloud Credentials
- Go to https://console.zegocloud.com
- Create a new project or use existing one
- Copy your **AppID** and **AppSign**
- These will be used in `zegocloud_voip_service.dart`

### 2. Update Credentials
In `lib/services/zegocloud_voip_service.dart`, update:
```dart
static const int appID = YOUR_APP_ID;  // Replace with your App ID
static const String appSign = 'YOUR_APP_SIGN';  // Replace with your App Sign
```

### 3. Permissions Configuration

#### Android (android/app/build.gradle)
```gradle
android {
    compileSdk 34  // Or higher
    defaultConfig {
        targetSdk 34  // Or higher
    }
}
```

#### Android Manifest (android/app/src/main/AndroidManifest.xml)
Add these permissions:
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.MICROPHONE" />
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
<uses-permission android:name="android.permission.ACCESS_WIFI_STATE" />
<uses-permission android:name="android.permission.CHANGE_NETWORK_STATE" />
<uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS" />
<uses-permission android:name="android.permission.RECORD_AUDIO" />
```

#### iOS (ios/Podfile)
Uncomment the following lines if needed:
```ruby
post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
    target.build_configurations.each do |config|
      config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= [
        '$(inherited)',
        'PERMISSION_MICROPHONE=1',
        'PERMISSION_CAMERA=1',
      ]
    end
  end
end
```

#### iOS Info.plist (ios/Runner/Info.plist)
Add these keys:
```xml
<key>NSMicrophoneUsageDescription</key>
<string>This app needs access to your microphone to make voice calls</string>
<key>NSCameraUsageDescription</key>
<string>This app needs access to your camera for video calls</string>
```

### 4. Initialize in main.dart
```dart
import 'package:eldercareapp/services/zegocloud_voip_service.dart';
import 'package:eldercareapp/core/providers/call_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize Zegocloud VoIP
  try {
    await ZegocloudVoipService.init();
  } catch (e) {
    print('Zegocloud init error: $e');
  }
  
  runApp(MyApp());
}
```

### 5. Add CallProvider to MultiProvider
In `main.dart`, add to the providers list:
```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => UserProvider()),
    ChangeNotifierProvider(create: (_) => ThemeProvider()),
    ChangeNotifierProvider(create: (_) => CallProvider()),  // Add this
  ],
  child: Consumer<ThemeProvider>(...),
)
```

## Usage

### Basic Voice Call
```dart
import 'package:eldercareapp/features/calling/presentation/zegocloud_call_screen.dart';

// Navigate to call screen
Navigator.of(context).push(
  MaterialPageRoute(
    builder: (context) => ZegocloudCallScreen(
      calleeId: 'recipient_id',
      calleeName: 'Recipient Name',
      isVideoCall: false,
    ),
  ),
);
```

### Smartwatch Call
```dart
import 'package:eldercareapp/features/calling/presentation/smartwatch_call_widget.dart';

// Show on smartwatch
showDialog(
  context: context,
  barrierDismissible: false,
  builder: (context) => Dialog(
    insetPadding: EdgeInsets.zero,
    child: SmartwatchCallWidget(
      calleeId: 'recipient_id',
      calleeName: 'Recipient Name',
      onCallEnded: () => Navigator.pop(context),
    ),
  ),
);
```

### Quick Dial Widget
Add to your home page:
```dart
import 'package:eldercareapp/features/calling/presentation/quick_dial_widget.dart';

QuickDialWidget(
  enableSmartwatch: true,
  // Optional: set default recipient
  defaultCalleeId: 'default_recipient_id',
  defaultCalleeName: 'Default Recipient',
)
```

## Features

### CallProvider
State management for calls with the following states:
- `idle`: No active call
- `outgoing`: Dialing
- `ringing`: Call ringing
- `connected`: Call in progress
- `disconnecting`: Ending call
- `disconnected`: Call ended
- `error`: Call error

Methods:
- `initiateCall()`: Start a call
- `acceptCall()`: Accept incoming call
- `endCall()`: End current call
- `rejectCall()`: Reject incoming call
- `toggleMicrophone()`: Toggle mic on/off
- `toggleCamera()`: Toggle camera on/off

### ZegocloudVoipService
Service wrapper for Zegocloud SDK:
- `init()`: Initialize SDK
- `requestPermissions()`: Request microphone/camera permissions
- `hasPermissions()`: Check if permissions are granted
- `startCall()`: Start a call
- `endCall()`: End call
- `setMicrophoneMuted()`: Mute/unmute microphone
- `setCameraEnabled()`: Enable/disable camera

## Smartwatch Integration

The app automatically detects smartwatch screens (width < 280px) and shows optimized UI:
- Large, readable text
- Simplified controls
- Circular layout for radial menus
- Touch-optimized button sizes

## Testing

1. Connect two devices (or emulators)
2. Use the Quick Dial widget to initiate calls
3. On Android: Grant microphone permissions when prompted
4. On iOS: Grant microphone access through iOS settings

## Troubleshooting

### Call not connecting
- Check that AppID and AppSign are correct in zegocloud_voip_service.dart
- Ensure both users are connected to the internet
- Verify firewall/network settings allow VoIP traffic

### Audio not working
- Check microphone permissions are granted
- Verify microphone isn't muted in system settings
- Test with speaker phone first

### Permission errors
- On Android: Check AndroidManifest.xml has all required permissions
- On iOS: Check Info.plist has microphone and camera descriptions
- Run `flutter clean` and rebuild

### Smartwatch UI not showing
- Check screen width detection (< 280px)
- Verify device is actually a smartwatch or small screen device

## Advanced Configuration

For production use, consider:
1. Storing AppID/AppSign in environment variables
2. Implementing call logging/analytics
3. Adding call recording (with user consent)
4. Implementing call quality monitoring
5. Adding ringtone notifications
6. Implementing call waits/hold functionality

## Support
- Zegocloud Documentation: https://doc.zegocloud.com/
- Flutter SDK Docs: https://pub.dev/packages/zego_uikit_prebuilt_call
- Package Repository: https://pub.dev/packages/zego_uikit
