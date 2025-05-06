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
    try {
      final result = await authRepository.login(event.username, event.password);
      if (result != null) {
        emit(
          AuthenticationSuccess(
            accessToken: result.accessToken,
            userId: result.account_id,
          ),
        );
      } else {
        emit(
          const AuthenticationFailure(
            message: "Tên đăng nhập hoặc mật khẩu không đúng",
          ),
        );
      }
    } catch (e) {
      emit(AuthenticationFailure(message: e.toString()));
    }
  }
}
