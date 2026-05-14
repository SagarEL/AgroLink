import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../utils/logger.dart';

/// Wires up FCM permission, token retrieval, and foreground listeners.
class MessagingService {
  MessagingService(this._fcm);
  final FirebaseMessaging _fcm;

  Future<String?> initialize() async {
    try {
      final settings = await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        appLog.w('Push notifications denied by user');
        return null;
      }
      // The VAPID key is required on web. Replace via dart-define if needed.
      const vapid = String.fromEnvironment('FIREBASE_WEB_VAPID_KEY', defaultValue: '');
      final token = kIsWeb && vapid.isNotEmpty
          ? await _fcm.getToken(vapidKey: vapid)
          : await _fcm.getToken();
      appLog.i('FCM token acquired');
      return token;
    } catch (e, st) {
      appLog.e('Messaging init failed', error: e, stackTrace: st);
      return null;
    }
  }

  Stream<RemoteMessage> onForegroundMessage() => FirebaseMessaging.onMessage;
  Stream<RemoteMessage> onOpenedApp() => FirebaseMessaging.onMessageOpenedApp;
  Future<RemoteMessage?> initialMessage() => _fcm.getInitialMessage();
}
