import 'dart:developer';
import 'package:firebase_messaging/firebase_messaging.dart';
import "core/notifications/notification_service.dart";

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  log(
    'BG message: ${message.messageId} title=${message.notification?.title} data=${message.data}',
  );

  final notificationService = NotificationService();
  await notificationService.init();

  final title =
      message.notification?.title ?? message.data['title'] ?? 'Título';
  final body = message.notification?.body ?? message.data['body'] ?? 'Mensaje';
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
}
