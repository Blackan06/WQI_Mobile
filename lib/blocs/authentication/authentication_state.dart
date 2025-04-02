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
  final int userId;

  AuthenticationSuccess(this.userId);
}

// Đăng nhập thất bại
class AuthenticationFailure extends AuthenticationState {
  final String error;
  const AuthenticationFailure(this.error);

  @override
  List<Object?> get props => [error];
}
