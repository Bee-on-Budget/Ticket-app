// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web; // Firebase Web configuration
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        return windows;
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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: "AIzaSyCtIAveLjjggnG2xLXTc_hUF2mFBS-DuUs",
    appId: "1:991049695804:android:24ec0866ec200a1cdd7939",
    messagingSenderId: "991049695804",
    projectId: "ticket-app-7914a",
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDEBpA0hmCLCeDS1sWly2-UcuboxGkCocc',
    authDomain: 'ticket-app-7914a.firebaseapp.com',
    projectId: 'ticket-app-7914a',
    storageBucket: 'ticket-app-7914a.firebasestorage.app',
    messagingSenderId: '991049695804',
    appId: '1:991049695804:web:73d5ac0d78c6e33bdd7939',
    measurementId: 'G-N51CFTX2H8',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDEBpA0hmCLCeDS1sWly2-UcuboxGkCocc',
    appId: '1:991049695804:web:73d5ac0d78c6e33bdd7939',
    messagingSenderId: '991049695804',
    projectId: 'ticket-app-7914a',
    authDomain: 'ticket-app-7914a.firebaseapp.com',
    storageBucket: 'ticket-app-7914a.firebasestorage.app',
    measurementId: 'G-N51CFTX2H8',
  );
}
