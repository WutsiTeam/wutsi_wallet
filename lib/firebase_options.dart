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
    apiKey: 'AIzaSyB6pt55lpZUc0Sj6PZlyqtETL4HoDb6xZw',
    appId: '1:4026312901:web:915b6b05c59b58b2ada8ac',
    messagingSenderId: '4026312901',
    projectId: 'wutsi-wallet-int',
    authDomain: 'wutsi-wallet-int.firebaseapp.com',
    storageBucket: 'wutsi-wallet-int.appspot.com',
    measurementId: 'G-GXK72YJTLE',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAAHuyuwpAFBxZWq4RyEda_3xDScrO4VgU',
    appId: '1:4026312901:android:0f42eb0b91381a46ada8ac',
    messagingSenderId: '4026312901',
    projectId: 'wutsi-wallet-int',
    storageBucket: 'wutsi-wallet-int.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA7xkNkcCflyiLlDApz4ybUJXBlqIov1Is',
    appId: '1:4026312901:ios:e1428d688b9f1bbdada8ac',
    messagingSenderId: '4026312901',
    projectId: 'wutsi-wallet-int',
    storageBucket: 'wutsi-wallet-int.appspot.com',
    iosClientId: '4026312901-bc0e1ergj9i81r4sdopgltg32mrfjk0n.apps.googleusercontent.com',
    iosBundleId: 'com.wutsi.wutsiWallet',
  );
}
