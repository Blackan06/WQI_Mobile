import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'blocs/authentication/authentication_bloc.dart';
import 'repositories/authentication_repository.dart';
import 'noti_service.dart';
import 'screens/login_screen.dart';
import 'screens/notification_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await NotiService().initNotification();

  // Yêu cầu quyền thông báo
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );
  print('User granted permission: ${settings.authorizationStatus}');

  // Đăng ký subscribe topic dựa vào personID
  String personID = "1";
  if (Platform.isIOS) {
    String? apnsToken = await messaging.getAPNSToken();
    if (apnsToken != null) {
      await messaging.subscribeToTopic(personID);
    } else {
      await Future.delayed(const Duration(seconds: 3));
      apnsToken = await messaging.getAPNSToken();
      if (apnsToken != null) {
        await messaging.subscribeToTopic(personID);
      }
    }
  } else {
    await messaging.subscribeToTopic(personID);
  }

  // Lắng nghe thông báo khi ứng dụng ở foreground
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print(
      'Foreground message: ${message.notification?.title}, ${message.notification?.body}',
    );
    NotiService().showNotification(
      title: message.notification?.title,
      body: message.notification?.body,
    );
  });

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print('Opened via notification: ${message.notification?.title}');
  });

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(MyApp());
}

// Xử lý thông báo ở chế độ background
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Background message: ${message.notification?.title}');
  NotiService().showNotification(
    title: message.notification?.title,
    body: message.notification?.body,
  );
}

// Hàm gọi API đăng ký token
Future<void> registerDeviceToken(String token, int account_id) async {
  final url = Uri.parse('https://dm.anhkiet.xyz/register-token');
  final data = {'device_token': token, 'account_id': account_id};
  print('Gửi lên Server data: $data');
  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: json.encode(data),
  );
  print('Server response: ${response.body}');
  if (response.statusCode == 200) {
    print('Device token registered successfully');
  } else {
    print(
      'Failed to register device token. Status code: ${response.statusCode}',
    );
  }
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  final AuthenticationRepository authRepository = AuthenticationRepository();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login',
      theme: ThemeData.dark(),
      home: BlocProvider(
        create: (context) => AuthenticationBloc(authRepository: authRepository),
        child: const LoginScreen(),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  final int accountId;

  const HomeScreen({Key? key, required this.accountId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => NotificationScreen(accountId: accountId),
                ),
              );
            },
          ),
        ],
      ),
      body: const Center(child: Text('Welcome to the Home Screen')),
    );
  }
}
