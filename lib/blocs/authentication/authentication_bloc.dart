// lib/bloc/authentication_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'authentication_event.dart';
import 'authentication_state.dart';
import 'package:wqi_mobile/repositories/authentication_repository.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  final AuthenticationRepository authRepository;

  AuthenticationBloc({required this.authRepository})
      : super(AuthenticationInitial()) {
    on<LoginRequested>(_onLoginRequested);
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthenticationState> emit,
  ) async {
    emit(AuthenticationLoading());
    final userId = await authRepository.login(event.username, event.password);
    if (userId != null) {
      emit(AuthenticationSuccess(userId));
    } else {
      emit(AuthenticationFailure("Tên đăng nhập hoặc mật khẩu không đúng"));
    }
  }
}
