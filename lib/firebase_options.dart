// Archivo generado manualmente con datos de google-services.json
// La herramienta flutterfire configure falló por timeout.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;

/// Default [FirebaseOptions] for all supported platforms.
///
/// Este archivo contiene las claves de configuración necesarias para que la aplicación
/// Flutter se conecte a tu proyecto de Firebase: manos-locales-36845.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for iOS - '
          'you can re-run this command with the --ios-bundle-id argument',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macOS - '
          'you can re-run this command with the --macos-bundle-id argument',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for Windows - '
          'you can re-run this command with the --windows-app-id argument',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for Linux - '
          'you can re-run this command with the --linux-app-id argument',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC4KoPaphmp5g8XUA8uh3ITHWdcDl3J5QQ',
    appId: '1:1078973695555:android:b7a457d8f7c131ca15b6f6',
    messagingSenderId: '1078973695555',
    projectId: 'manos-locales-36845',
    storageBucket: 'manos-locales-36845.firebasestorage.app',
  );
}
