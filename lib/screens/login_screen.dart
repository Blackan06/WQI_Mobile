import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../blocs/authentication/authentication_bloc.dart';
import '../blocs/authentication/authentication_event.dart';
import '../blocs/authentication/authentication_state.dart';
import 'bottom_nav_screen.dart';
import '../main.dart'; // Để sử dụng hàm registerDeviceToken

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _onLoginPressed() {
    // Gửi sự kiện login qua Bloc
    context.read<AuthenticationBloc>().add(
          LoginRequested(_usernameController.text, _passwordController.text),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đăng nhập'),
      ),
      body: BlocConsumer<AuthenticationBloc, AuthenticationState>(
        listener: (context, state) {
          if (state is AuthenticationSuccess) {
            final userId = state.userId;
            // Sau khi login thành công, lấy FCM token và đăng ký
            FirebaseMessaging.instance.getToken().then((token) {
              print(token);
              if (token != null) {
                registerDeviceToken(token, userId);
              }
            });
            // Chuyển sang màn hình có Bottom Navigation
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const BottomNavScreen()),
            );
          } else if (state is AuthenticationFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error)),
            );
          }
        },
        builder: (context, state) {
          if (state is AuthenticationLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Hình icon từ assets
              Image.asset(
                'assets/images/water.png',
                width: 150,
                height: 150,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _onLoginPressed,
                child: const Text('Đăng nhập'),
              ),
            ],
          );
        },
      ),
    );
  }
}
