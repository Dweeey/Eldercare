import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAU2sccq4OX9Gsx3GIlAAJSCnC9nPwR3Yo',
    appId: '1:909778576380:web:2dd33e852eaac29f344879',
    messagingSenderId: '909778576380',
    projectId: 'eldercareplus-7bed9',
    authDomain: 'eldercareplus-7bed9.firebaseapp.com',
    storageBucket: 'eldercareplus-7bed9.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAU2sccq4OX9Gsx3GIlAAJSCnC9nPwR3Yo',
    appId: '1:909778576380:android:2dd33e852eaac29f344879',
    messagingSenderId: '909778576380',
    projectId: 'eldercareplus-7bed9',
    storageBucket: 'eldercareplus-7bed9.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAU2sccq4OX9Gsx3GIlAAJSCnC9nPwR3Yo',
    appId: '1:909778576380:ios:2dd33e852eaac29f344879',
    messagingSenderId: '909778576380',
    projectId: 'eldercareplus-7bed9',
    storageBucket: 'eldercareplus-7bed9.firebasestorage.app',
  );
}
