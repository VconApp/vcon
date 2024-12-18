// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
        return macos;
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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDrCYvuNyig5Ash0QPc8j4YGSJOaOKcWK8',
    appId: '1:700567401814:web:266f61d23e91efc04212f7',
    messagingSenderId: '700567401814',
    projectId: 'flutter-firebase-tutoria-9856d',
    authDomain: 'flutter-firebase-tutoria-9856d.firebaseapp.com',
    storageBucket: 'flutter-firebase-tutoria-9856d.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDsZZhlSPURlvx_n05nqlKbRHZ2x4slpyk',
    appId: '1:700567401814:android:11f4837ab29c47c54212f7',
    messagingSenderId: '700567401814',
    projectId: 'flutter-firebase-tutoria-9856d',
    storageBucket: 'flutter-firebase-tutoria-9856d.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBmKMqdSG85NJgqb5Sm20a8nZLlACR-GwA',
    appId: '1:700567401814:ios:5b2961af8c76cd074212f7',
    messagingSenderId: '700567401814',
    projectId: 'flutter-firebase-tutoria-9856d',
    storageBucket: 'flutter-firebase-tutoria-9856d.appspot.com',
    iosBundleId: 'com.example.vcon3rdpartyAuth',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBmKMqdSG85NJgqb5Sm20a8nZLlACR-GwA',
    appId: '1:700567401814:ios:5b2961af8c76cd074212f7',
    messagingSenderId: '700567401814',
    projectId: 'flutter-firebase-tutoria-9856d',
    storageBucket: 'flutter-firebase-tutoria-9856d.appspot.com',
    iosBundleId: 'com.example.vcon3rdpartyAuth',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDrCYvuNyig5Ash0QPc8j4YGSJOaOKcWK8',
    appId: '1:700567401814:web:266f61d23e91efc04212f7',
    messagingSenderId: '700567401814',
    projectId: 'flutter-firebase-tutoria-9856d',
    authDomain: 'flutter-firebase-tutoria-9856d.firebaseapp.com',
    storageBucket: 'flutter-firebase-tutoria-9856d.appspot.com',
  );
}
