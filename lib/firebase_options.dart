import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class DefaultFirebaseOptions {

  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    } else {
      return android;
    }
  }

  // 🔹 Android config
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyACHwRWdezxYtSV8XVu39riCEnrfOyMWZg',
    appId: '1:436543886888:android:d63811332309b1c4a2c71d',
    messagingSenderId: '436543886888',
    projectId: 'myapp-bec98',
    storageBucket: 'myapp-bec98.firebasestorage.app',
  );

  // 🔹 Web config
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "AIzaSyBBtQmHxMVwK57GS4ZYhy46noLn-mah9QM",
    authDomain: "myapp-bec98.firebaseapp.com",
    databaseURL: "https://myapp-bec98-default-rtdb.firebaseio.com",
    projectId: "myapp-bec98",
    storageBucket: "myapp-bec98.firebasestorage.app",
    messagingSenderId: "436543886888",
    appId: "1:436543886888:web:f9c1d62b16a29c23a2c71d",
    measurementId: "G-RCEBHQBSVB",
  );
}