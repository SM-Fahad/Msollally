import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web.',
      );
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDRPKGLxgj1dVIc_ZowRRPRif0UJjqAx1U',
    appId: '1:206072623139:android:652e39e133aa078286c196',
    messagingSenderId: '206072623139',
    projectId: 'nodmac-701bd',
    storageBucket: 'nodmac-701bd.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBmvAv8HBonUnOGTJw-rmgfejY-V2S4CJ8',
    appId: '1:206072623139:ios:212f247776a8e01c86c196',
    messagingSenderId: '206072623139',
    projectId: 'nodmac-701bd',
    storageBucket: 'nodmac-701bd.firebasestorage.app',
    iosBundleId: 'com.nodmac.apple',
  );
}
