import 'dart:io'; // Cần thêm import này
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'navigation/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Yêu cầu quyền thông báo cho người dùng
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  print('User granted permission: ${settings.authorizationStatus}');

  String personID = "your-person-id"; // Bạn cần khai báo personID

  if (Platform.isIOS) {
    // Lấy APNS token
    String? apnsToken = await messaging.getAPNSToken();
    if (apnsToken != null) {
      // Đăng ký theo chủ đề nếu APNS token có giá trị
      await messaging.subscribeToTopic(personID);
    } else {
      // Chờ đợi 3 giây nếu APNS token vẫn chưa có
      await Future<void>.delayed(const Duration(seconds: 3));
      apnsToken = await messaging.getAPNSToken();
      if (apnsToken != null) {
        await messaging.subscribeToTopic(personID);
      }
    }
  } else {
    // Đăng ký theo chủ đề nếu không phải trên iOS
    await messaging.subscribeToTopic(personID);
  }

  // Lấy FCM token
  String? token = await messaging.getToken();
  print('FCM Device Token: $token'); // In device token ra console

  // Lắng nghe thông báo khi ứng dụng đang ở chế độ foreground
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print(
      'Received a message while in the foreground: ${message.notification?.title}, ${message.notification?.body}',
    );
    // Bạn có thể xử lý thông báo tại đây, chẳng hạn như hiển thị một Snackbar hoặc Dialog
  });

  // Lắng nghe khi người dùng nhấn vào thông báo
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print('Opened app via notification: ${message.notification?.title}');
    // Điều hướng đến màn hình tương ứng trong ứng dụng của bạn
  });

  // Lắng nghe thông báo khi ứng dụng ở chế độ nền hoặc bị đóng
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(MyApp());
}

// Hàm xử lý thông báo khi ứng dụng ở chế độ nền
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling a background message: ${message.notification?.title}');
  // Bạn có thể xử lý các thông báo ở đây
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Persistent Bottom Navigation with GoRouter',
      theme: ThemeData.dark(),
      routerConfig: AppRouter.router,
    );
  }
}
