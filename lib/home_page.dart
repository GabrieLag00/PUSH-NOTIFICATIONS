import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/notifications/notification_service.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationService = NotificationService();

    return Scaffold(
      appBar: AppBar(title: const Text('Inicio')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Bienvenido a TurismoApp'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                notificationService.showBigPicture(
                  title: 'Notificación de prueba',
                  body: 'Este es un mensaje local desde HomePage',
                  imageUrl:
                      'https://i.pinimg.com/736x/c1/5c/ec/c15cec3e5e5fa5850fa9ce61adb65c0b.jpg',
                );
              },
              child: const Text('Probar notificación'),
            ),
          ],
        ),
      ),
    );
  }
}
