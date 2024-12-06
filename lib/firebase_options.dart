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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for android - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyA6jHtiudsBxXfxUh7AQHplqeBbgcEt5uY',
    appId: '1:607563996465:web:1d4312945305ddf337a410',
    messagingSenderId: '607563996465',
    projectId: 'nebulanutrition-16c2a',
    authDomain: 'nebulanutrition-16c2a.firebaseapp.com',
    databaseURL: 'https://nebulanutrition-16c2a-default-rtdb.firebaseio.com',
    storageBucket: 'nebulanutrition-16c2a.firebasestorage.app',
    measurementId: 'G-2XB9WDT09X',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAzV_U0ogKN8k7AQKSsNEMlCqtQOFn_FVk',
    appId: '1:607563996465:ios:6bebdc8b13f7983337a410',
    messagingSenderId: '607563996465',
    projectId: 'nebulanutrition-16c2a',
    databaseURL: 'https://nebulanutrition-16c2a-default-rtdb.firebaseio.com',
    storageBucket: 'nebulanutrition-16c2a.firebasestorage.app',
    iosClientId: '607563996465-6a5uc41qnae54ncs1gko4qb39fvu896f.apps.googleusercontent.com',
    iosBundleId: 'com.example.nebnu',
  );

}