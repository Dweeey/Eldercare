# Quick Start: Zegocloud VoIP Integration

Your eldercare app now has full VoIP calling support with smartwatch compatibility! Here's how to get started in 5 minutes.

## 1️⃣ Get Your Zegocloud Credentials

1. Go to https://console.zegocloud.com (create account if needed)
2. Create a new project or use existing one
3. Copy your **AppID** and **AppSign**

## 2️⃣ Update Your Credentials

Open `lib/services/zegocloud_voip_service.dart` and update:

```dart
static const int appID = 123456789;  // ← Your AppID here
static const String appSign = 'abc...xyz';  // ← Your AppSign here
```

## 3️⃣ Install Dependencies

```bash
flutter pub get
```

Dependencies added:
- `zego_uikit_prebuilt_call`: ^4.2.0
- `zego_uikit`: ^2.9.0
- `permission_handler`: ^11.4.4

## 4️⃣ Configure Permissions

### Android
Add to `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.MICROPHONE" />
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.INTERNET" />
```

### iOS
Add to `ios/Runner/Info.plist`:
```xml
<key>NSMicrophoneUsageDescription</key>
<string>This app needs microphone access for voice calls</string>
<key>NSCameraUsageDescription</key>
<string>This app needs camera access for video calls</string>
```

## 5️⃣ Add Calling to Your Home Page

In your `home_page.dart`, add the quick dial widget:

```dart
import 'package:eldercareapp/features/calling/presentation/quick_dial_widget.dart';

// Inside your home page build method:
QuickDialWidget(
  enableSmartwatch: true,
  defaultCalleeId: 'caregiver_id',      // Optional: pre-fill recipient
  defaultCalleeName: 'Dr. Smith',       // Optional: pre-fill name
)
```

Or add a quick call button:

```dart
ElevatedButton.icon(
  onPressed: () {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ZegocloudCallScreen(
          calleeId: 'caregiver_id',
          calleeName: 'Dr. Smith',
        ),
      ),
    );
  },
  icon: const Icon(Icons.call),
  label: const Text('Call Caregiver'),
)
```

## 📁 What's Included

### Services
- **zegocloud_voip_service.dart**: Zegocloud SDK wrapper

### Providers
- **call_provider.dart**: Call state management (using Provider pattern)

### UI Components
- **zegocloud_call_screen.dart**: Full-featured call screen for phones/tablets
- **smartwatch_call_widget.dart**: Optimized for smartwatch screens (< 280px)
- **quick_dial_widget.dart**: Quick dial with contact management

### Documentation
- **ZEGOCLOUD_SETUP.md**: Complete setup and configuration guide
- **lib/features/calling/README.md**: Feature documentation
- **CALLING_EXAMPLES.dart**: Code examples for common use cases

## 🎯 Features Available

✅ **Voice Calling** - Full duplex voice communication  
✅ **Smartwatch Support** - Auto-optimized UI for watches  
✅ **Call Control** - Mute/unmute microphone  
✅ **Video Ready** - Framework ready for video calls  
✅ **State Management** - Integrated with Provider pattern  
✅ **Error Handling** - Comprehensive error states  
✅ **Call Timer** - Automatic duration tracking  
✅ **Status Display** - Real-time call status indicators  

## 🧪 Testing

**Local Testing:**
```bash
flutter run
```

**Test on Two Devices:**
1. Install on two devices (phones, tablets, or watches)
2. Grant microphone permissions when prompted
3. Use Quick Dial widget to initiate calls
4. Answer on the other device

## 🐛 Common Issues

**Issue: "Call not connecting"**
- Check AppID and AppSign are correct
- Verify both devices have internet
- Check firewall allows VoIP traffic

**Issue: "No microphone permission"**
- On Android: Check AndroidManifest.xml has `MICROPHONE` permission
- On iOS: Manually grant in Settings → Privacy → Microphone
- Restart app after granting permission

**Issue: "Smartwatch UI not showing"**
- Verify your device has screen width < 280px
- Check `enableSmartwatch: true` in QuickDialWidget

## 📱 Smartwatch Integration

The app automatically detects smartwatch screens and shows optimized UI:
- Large, readable text
- Touch-friendly buttons
- Simplified controls (mute + end call)
- Circular layout for radial menus

No additional code needed - just use the widgets as-is!

## 📚 Next Steps

1. Read [ZEGOCLOUD_SETUP.md](ZEGOCLOUD_SETUP.md) for detailed setup
2. Check [lib/features/calling/README.md](lib/features/calling/README.md) for full documentation
3. Review [CALLING_EXAMPLES.dart](lib/features/calling/CALLING_EXAMPLES.dart) for code examples
4. Test on your smartwatch device
5. Configure for production use

## 🔧 Advanced Configuration

After basic setup, consider:
- Adding call notifications
- Implementing call history/logging
- Setting up call recording (with consent)
- Adding group calling support
- Implementing emergency/SOS button

## ❓ Support

- **Zegocloud Documentation**: https://doc.zegocloud.com/
- **Flutter SDK**: https://pub.dev/packages/zego_uikit_prebuilt_call
- **Setup Guide**: See ZEGOCLOUD_SETUP.md in project root
- **Examples**: See CALLING_EXAMPLES.dart

---

**That's it! Your app now has VoIP calling with smartwatch support.** 🎉

Need help? Check the documentation files or review the example code!
