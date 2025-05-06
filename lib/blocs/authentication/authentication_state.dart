// lib/bloc/authentication_state.dart
import 'package:equatable/equatable.dart';

abstract class AuthenticationState extends Equatable {
  const AuthenticationState();

  @override
  List<Object?> get props => [];
}

// Trạng thái ban đầu
class AuthenticationInitial extends AuthenticationState {}

// Đang gọi API / đang load
class AuthenticationLoading extends AuthenticationState {}

// Đăng nhập thành công
class AuthenticationSuccess extends AuthenticationState {
  final String accessToken;
  final int userId;

  const AuthenticationSuccess({
    required this.accessToken,
    required this.userId,
  });

  @override
  List<Object> get props => [accessToken, userId];

  AuthenticationSuccess copyWith({
    String? accessToken,
    int? userId,
  }) {
    return AuthenticationSuccess(
      accessToken: accessToken ?? this.accessToken,
      userId: userId ?? this.userId,
    );
  }
}

// Đăng nhập thất bại
class AuthenticationFailure extends AuthenticationState {
  final String message;
  final int? statusCode;

  const AuthenticationFailure({
    required this.message,
    this.statusCode,
  });

  @override
  List<Object?> get props => [message, statusCode];
}
