
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
    apiKey: 'AIzaSyChoD843FHUi_tZFgoWSZ-Q5Bwv8fdksmE',
    appId: '1:977976645211:web:6a7e57e84a20b9bcd6d17e',
    messagingSenderId: '977976645211',
    projectId: 'agrolink-631c1',
    authDomain: 'agrolink-631c1.firebaseapp.com',
    storageBucket: 'agrolink-631c1.firebasestorage.app',
    measurementId: 'G-9J0KSWR7R9',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB-JpyR4C8IIOudb3BsackiWDX7lbhHAnA',
    appId: '1:977976645211:android:ed93e0a2e8eef3c9d6d17e',
    messagingSenderId: '977976645211',
    projectId: 'agrolink-631c1',
    storageBucket: 'agrolink-631c1.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBxduBaaTDjROPnuu7s71bJ25bpzCcElQQ',
    appId: '1:977976645211:ios:d5abbf0e5fd905e2d6d17e',
    messagingSenderId: '977976645211',
    projectId: 'agrolink-631c1',
    storageBucket: 'agrolink-631c1.firebasestorage.app',
    iosBundleId: 'com.example.agrolink',
  );
}
