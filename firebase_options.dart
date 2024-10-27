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
    apiKey: 'AIzaSyBwXpU5HO-7ca3Yhycu0DtIH4WCOwdp_Xc',
    appId: '1:352338164892:web:8ef63d715fa8acdb000159',
    messagingSenderId: '352338164892',
    projectId: 'event-adb29',
    authDomain: 'event-adb29.firebaseapp.com',
    storageBucket: 'event-adb29.appspot.com',
    measurementId: 'G-F7E1G0LQL0',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCmucpLNTzp_0umOznX3Vx_QQV4zFpJFLg',
    appId: '1:352338164892:android:a59db25fe543da3a000159',
    messagingSenderId: '352338164892',
    projectId: 'event-adb29',
    storageBucket: 'event-adb29.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBaZ-QeO4rqwpSXnD7SsQJvUzXT34Mjeg8',
    appId: '1:352338164892:ios:e4351f47d3c95569000159',
    messagingSenderId: '352338164892',
    projectId: 'event-adb29',
    storageBucket: 'event-adb29.appspot.com',
    iosBundleId: 'com.example.event',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBaZ-QeO4rqwpSXnD7SsQJvUzXT34Mjeg8',
    appId: '1:352338164892:ios:e4351f47d3c95569000159',
    messagingSenderId: '352338164892',
    projectId: 'event-adb29',
    storageBucket: 'event-adb29.appspot.com',
    iosBundleId: 'com.example.event',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBwXpU5HO-7ca3Yhycu0DtIH4WCOwdp_Xc',
    appId: '1:352338164892:web:f4822b910366db8f000159',
    messagingSenderId: '352338164892',
    projectId: 'event-adb29',
    authDomain: 'event-adb29.firebaseapp.com',
    storageBucket: 'event-adb29.appspot.com',
    measurementId: 'G-R7584S1ZN4',
  );
}