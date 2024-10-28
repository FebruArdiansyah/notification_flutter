import 'package:cobafirebase/main.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class FirebaseApi {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> initNotifications() async {
    // Meminta izin notifikasi dari pengguna
    await _firebaseMessaging.requestPermission();

    // Mencetak token untuk pengujian (dapat dihapus pada produksi)
    final fCMToken = await _firebaseMessaging.getToken();
    print('Token : $fCMToken');

    // Inisialisasi notifikasi push dan local notifications
    await initPushNotifications();
    _initializeLocalNotifications();
  }

  void handleMessage(RemoteMessage? message) {
    if (message == null) return;

    navigatorKey.currentState?.pushNamed(
      '/notifications_screen',
      arguments: message,
    );
  }

  Future<void> initPushNotifications() async {
    // Menangani pesan ketika aplikasi dibuka pertama kali setelah ditutup sepenuhnya
    FirebaseMessaging.instance.getInitialMessage().then(handleMessage);

    // Menangani pesan ketika notifikasi dibuka dari tray dalam keadaan background
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);

    // Menangani pesan ketika aplikasi dalam keadaan aktif (foreground)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("Foreground message received: ${message.notification?.title}");
      _showLocalNotification(message);
    });
  }

  void _initializeLocalNotifications() {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      channelDescription: 'your_channel_description',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _flutterLocalNotificationsPlugin.show(
      0,
      message.notification?.title ?? 'Default Title',
      message.notification?.body ?? 'Default Body',
      platformChannelSpecifics,
    );
  }
}
