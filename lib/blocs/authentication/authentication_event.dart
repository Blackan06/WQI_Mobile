// lib/bloc/authentication_event.dart
import 'package:equatable/equatable.dart';

abstract class AuthenticationEvent extends Equatable {
  const AuthenticationEvent();

  @override
  List<Object?> get props => [];
}

// Sự kiện khi người dùng ấn nút login
class LoginRequested extends AuthenticationEvent {
  final String username;
  final String password;

  const LoginRequested(this.username, this.password);

  @override
  List<Object?> get props => [username, password];
}
