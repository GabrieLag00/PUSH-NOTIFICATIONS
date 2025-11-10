import 'dart:io';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'core/notifications/notification_service.dart';
import 'firebase_messaging_handler.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
    FirebaseMessaging.instance.getToken().then((token) {
      print('📱 Token FCM: $token');
    });
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      final notificationService = NotificationService();
      await notificationService.init();

      final title =
          message.notification?.title ?? message.data['title'] ?? 'Título';
      final body =
          message.notification?.body ?? message.data['body'] ?? 'Mensaje';
      final imageUrl = message.data['image'] ?? '';

      if (imageUrl.isNotEmpty) {
        await notificationService.showBigPicture(
          title: title,
          body: body,
          imageUrl: imageUrl,
        );
      } else {
        await notificationService.showLocal(title: title, body: body);
      }
    });
    final notificationService = NotificationService();
    await notificationService.init();

    await _ensureFcmDefaultChannel();
    await _requestPermissions();
    _configureForegroundHandlers(notificationService);
  } catch (e, stack) {
    print('🔥 Error en main(): $e');
    print(stack);
  }

  runApp(const ProviderScope(child: TurismoApp()));
}

Future<void> _requestPermissions() async {
  final messaging = FirebaseMessaging.instance;
  if (Platform.isIOS) {
    await messaging.requestPermission(alert: true, badge: true, sound: true);
  } else if (Platform.isAndroid) {
    final androidImpl = FlutterLocalNotificationsPlugin()
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidImpl?.requestNotificationsPermission();
  }
}

void _configureForegroundHandlers(NotificationService local) {
  FirebaseMessaging.onMessage.listen((message) async {
    final title =
        message.data['title'] ?? message.notification?.title ?? 'Mensaje';
    final body =
        message.data['body'] ??
        message.notification?.body ??
        'Tienes una notificación';
    final imageUrl = message.data['image'] ?? '';

    if (imageUrl.isNotEmpty) {
      await local.showBigPicture(title: title, body: body, imageUrl: imageUrl);
    } else {
      await local.showLocal(title: title, body: body);
    }
  });
  FirebaseMessaging.onMessageOpenedApp.listen((message) {
    log('onMessageOpenedApp: ${message.data}');
    // TODO: Navegar a pantalla con datos (deep link)
  });
}

Future<void> _ensureFcmDefaultChannel() async {
  const channel = AndroidNotificationChannel(
    'default_channel_fcm',
    'General (FCM)',
    description: 'Canal por defecto para mensajes FCM',
    importance: Importance.high,
    playSound: true,
  );
  final plugin = FlutterLocalNotificationsPlugin()
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();
  await plugin?.createNotificationChannel(channel);
}
