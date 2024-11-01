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
    apiKey: 'AIzaSyBuWQKQ1yInAf0dDA99jT9PY7-7eT4zixU',
    appId: '1:354234220170:web:44cdcc695afdf2dc28f773',
    messagingSenderId: '354234220170',
    projectId: 'riendzo',
    authDomain: 'riendzo.firebaseapp.com',
    storageBucket: 'riendzo.appspot.com',
    measurementId: 'G-FLH0H5Z9NE',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDO2BuVb3giWbNKddRDRqLRcpdyrC20tlY',
    appId: '1:354234220170:android:4258c22c9bcfa32728f773',
    messagingSenderId: '354234220170',
    projectId: 'riendzo',
    storageBucket: 'riendzo.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBH4tGyMyOT96gXDBf1hqdrtGOWaKlDmSM',
    appId: '1:354234220170:ios:b5efaadc78f77f3d28f773',
    messagingSenderId: '354234220170',
    projectId: 'riendzo',
    storageBucket: 'riendzo.appspot.com',
    iosBundleId: 'riendzo.io.riendzo',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBH4tGyMyOT96gXDBf1hqdrtGOWaKlDmSM',
    appId: '1:354234220170:ios:b5efaadc78f77f3d28f773',
    messagingSenderId: '354234220170',
    projectId: 'riendzo',
    storageBucket: 'riendzo.appspot.com',
    iosBundleId: 'riendzo.io.riendzo',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBuWQKQ1yInAf0dDA99jT9PY7-7eT4zixU',
    appId: '1:354234220170:web:1a0ab62bee567d9228f773',
    messagingSenderId: '354234220170',
    projectId: 'riendzo',
    authDomain: 'riendzo.firebaseapp.com',
    storageBucket: 'riendzo.appspot.com',
    measurementId: 'G-ZV5XXRYD8B',
  );
}
