// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
    apiKey: 'AIzaSyC-tGXl4DboDtllHu-XySlM2ezArTtAeJ8',
    appId: '1:1091383284684:web:d1a96e95fe4dd0c4f74369',
    messagingSenderId: '1091383284684',
    projectId: 'project-aba39',
    authDomain: 'project-aba39.firebaseapp.com',
    storageBucket: 'project-aba39.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDSBl-S4OoyxEUVou7iwgsO9cNE4AFpY9w',
    appId: '1:1091383284684:android:cec8f3838faf406af74369',
    messagingSenderId: '1091383284684',
    projectId: 'project-aba39',
    storageBucket: 'project-aba39.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBzvtviXr8tuVTzFU4I67ZlxLHqavUJVao',
    appId: '1:1091383284684:ios:d162409ef7d977f7f74369',
    messagingSenderId: '1091383284684',
    projectId: 'project-aba39',
    storageBucket: 'project-aba39.appspot.com',
    iosBundleId: 'com.example.project',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBzvtviXr8tuVTzFU4I67ZlxLHqavUJVao',
    appId: '1:1091383284684:ios:740331856b6d2218f74369',
    messagingSenderId: '1091383284684',
    projectId: 'project-aba39',
    storageBucket: 'project-aba39.appspot.com',
    iosBundleId: 'com.example.project.RunnerTests',
  );
}