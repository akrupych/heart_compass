// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars
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
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    // ignore: missing_enum_constant_in_switch
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
    }

    throw UnsupportedError(
      'DefaultFirebaseOptions are not supported for this platform.',
    );
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA0AkdwoNpcGlaLP7q0s1pyzMl85DR0qBE',
    appId: '1:1086389105589:android:9a68db6da70563d481dffc',
    messagingSenderId: '1086389105589',
    projectId: 'heart-compass-ca01b',
    storageBucket: 'heart-compass-ca01b.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBsHJOwbX_Jt3SVMYd_kb88DaoMzmn_69A',
    appId: '1:1086389105589:ios:635771797ecde4f081dffc',
    messagingSenderId: '1086389105589',
    projectId: 'heart-compass-ca01b',
    storageBucket: 'heart-compass-ca01b.appspot.com',
    iosClientId: '1086389105589-cqo0ou4c4l6b8id64idkfa5m5ucvh8h4.apps.googleusercontent.com',
    iosBundleId: 'com.aeladrin.heartCompass',
  );
}
