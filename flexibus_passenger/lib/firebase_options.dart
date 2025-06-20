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
    apiKey: 'AIzaSyAyFThxuSPhOXwY65e3c9LkD-ffmIK2XUs',
    appId: '1:808128930124:web:0954fa303b0be53557afe9',
    messagingSenderId: '808128930124',
    projectId: 'flexibus-33b47',
    authDomain: 'flexibus-33b47.firebaseapp.com',
    storageBucket: 'flexibus-33b47.firebasestorage.app',
    measurementId: 'G-SPVV340D4H',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBoZau4uRa7OOq9rQ-c-rLegIwV4M1d0fo',
    appId: '1:808128930124:android:da47b5a947cde36f57afe9',
    messagingSenderId: '808128930124',
    projectId: 'flexibus-33b47',
    storageBucket: 'flexibus-33b47.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDQkp_dbzzpLsq7LJUANzZKQACbh8Wx6WU',
    appId: '1:808128930124:ios:0732bae1418df85b57afe9',
    messagingSenderId: '808128930124',
    projectId: 'flexibus-33b47',
    storageBucket: 'flexibus-33b47.firebasestorage.app',
    iosBundleId: 'com.example.flexibusPassenger',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDQkp_dbzzpLsq7LJUANzZKQACbh8Wx6WU',
    appId: '1:808128930124:ios:0732bae1418df85b57afe9',
    messagingSenderId: '808128930124',
    projectId: 'flexibus-33b47',
    storageBucket: 'flexibus-33b47.firebasestorage.app',
    iosBundleId: 'com.example.flexibusPassenger',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAyFThxuSPhOXwY65e3c9LkD-ffmIK2XUs',
    appId: '1:808128930124:web:d5104b37d73ac27057afe9',
    messagingSenderId: '808128930124',
    projectId: 'flexibus-33b47',
    authDomain: 'flexibus-33b47.firebaseapp.com',
    storageBucket: 'flexibus-33b47.firebasestorage.app',
    measurementId: 'G-WZ0VGMZVR3',
  );

}