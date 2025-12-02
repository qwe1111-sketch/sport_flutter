import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sport_flutter/domain/entities/user.dart';
import 'package:sport_flutter/domain/usecases/get_user_profile.dart';
import 'package:sport_flutter/domain/usecases/login.dart';
import 'package:sport_flutter/domain/usecases/register.dart';
import 'package:sport_flutter/domain/usecases/reset_password.dart';
import 'package:sport_flutter/domain/usecases/send_password_reset_code.dart';
import 'package:sport_flutter/domain/usecases/send_verification_code.dart';
import 'package:sport_flutter/domain/usecases/update_user_profile.dart';
import 'package:equatable/equatable.dart';

// #region Auth State
abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {} // Generic loading for other actions

// Specific loading states for Reset Password Page
class SendingPasswordResetCodeInProgress extends AuthState {}
class ResettingPasswordInProgress extends AuthState {}

class AuthCodeSent extends AuthState {}
class PasswordResetSuccess extends AuthState {}
class AuthAuthenticated extends AuthState {
  final User user;
  const AuthAuthenticated({required this.user});
  @override
  List<Object?> get props => [user];
}
class AuthRegistrationSuccess extends AuthState {}
class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
  @override
  List<Object?> get props => [message];
}
// #endregion

// #region Auth Event
abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class AppStarted extends AuthEvent {}

class SendCodeEvent extends AuthEvent {
  final String email;
  const SendCodeEvent(this.email);
  @override
  List<Object?> get props => [email];
}

class SendPasswordResetCodeEvent extends AuthEvent {
  final String email;
  const SendPasswordResetCodeEvent(this.email);
  @override
  List<Object?> get props => [email];
}

class ResetPasswordEvent extends AuthEvent {
  final String email;
  final String code;
  final String newPassword;

  const ResetPasswordEvent(this.email, this.code, this.newPassword);

  @override
  List<Object?> get props => [email, code, newPassword];
}

class RegisterEvent extends AuthEvent {
  final String username;
  final String email;
  final String password;
  final String code;
  const RegisterEvent(this.username, this.email, this.password, this.code);
  @override
  List<Object?> get props => [username, email, password, code];
}

class LoginEvent extends AuthEvent {
  final String username;
  final String password;
  const LoginEvent(this.username, this.password);
  @override
  List<Object?> get props => [username, password];
}

class LogoutEvent extends AuthEvent {}

class UpdateProfileEvent extends AuthEvent {
  final String? username;
  final String? avatarUrl;
  final String? bio;

  const UpdateProfileEvent({this.username, this.avatarUrl, this.bio});

  @override
  List<Object?> get props => [username, avatarUrl, bio];
}
// #endregion

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final Login loginUseCase;
  final Register registerUseCase;
  final SendVerificationCode sendCodeUseCase;
  final SendPasswordResetCode sendPasswordResetCodeUseCase;
  final ResetPassword resetPasswordUseCase;
  final GetUserProfile getUserProfileUseCase;
  final UpdateUserProfile updateUserProfileUseCase;

  AuthBloc({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.sendCodeUseCase,
    required this.sendPasswordResetCodeUseCase,
    required this.resetPasswordUseCase,
    required this.getUserProfileUseCase,
    required this.updateUserProfileUseCase,
  }) : super(AuthInitial()) {
    on<AppStarted>(_onAppStarted);
    on<SendCodeEvent>(_onSendCode);
    on<SendPasswordResetCodeEvent>(_onSendPasswordResetCode);
    on<ResetPasswordEvent>(_onResetPassword);
    on<RegisterEvent>(_onRegister);
    on<LoginEvent>(_onLogin);
    on<LogoutEvent>(_onLogout);
    on<UpdateProfileEvent>(_onUpdateProfile);
  }

  String _extractErrorMessage(Object e) {
    if (e is Exception) {
      return e.toString().replaceFirst('Exception: ', '');
    }
    return 'An unknown error occurred';
  }

  void _onAppStarted(AppStarted event, Emitter<AuthState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('user_token');

    if (token != null) {
      try {
        final user = await getUserProfileUseCase();
        emit(AuthAuthenticated(user: user));
      } catch (_) {
        emit(AuthUnauthenticated());
      }
    } else {
      emit(AuthUnauthenticated());
    }
  }

  void _onSendCode(SendCodeEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading()); // Keep generic for registration
    try {
      await sendCodeUseCase(event.email);
      emit(AuthCodeSent());
    } catch (e) {
      emit(AuthError(_extractErrorMessage(e)));
    }
  }

  void _onSendPasswordResetCode(SendPasswordResetCodeEvent event, Emitter<AuthState> emit) async {
    emit(SendingPasswordResetCodeInProgress()); // Use specific state
    try {
      await sendPasswordResetCodeUseCase(event.email);
      emit(AuthCodeSent());
    } catch (e) {
      emit(AuthError(_extractErrorMessage(e)));
    }
  }

  void _onResetPassword(ResetPasswordEvent event, Emitter<AuthState> emit) async {
    emit(ResettingPasswordInProgress()); // Use specific state
    try {
      await resetPasswordUseCase(event.email, event.code, event.newPassword);
      emit(PasswordResetSuccess());
    } catch (e) {
      emit(AuthError(_extractErrorMessage(e)));
    }
  }

  void _onRegister(RegisterEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await registerUseCase(event.username, event.email, event.password, event.code);
      emit(AuthRegistrationSuccess());
    } catch (e) {
      emit(AuthError(_extractErrorMessage(e)));
    }
  }

  void _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final token = await loginUseCase(event.username, event.password);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_token', token);
      final user = await getUserProfileUseCase();
      emit(AuthAuthenticated(user: user));
    } catch (e) {
      emit(AuthError(_extractErrorMessage(e)));
    }
  }

  void _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_token');
    emit(AuthUnauthenticated());
  }

  void _onUpdateProfile(UpdateProfileEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final updatedUser = await updateUserProfileUseCase(
        username: event.username,
        avatarUrl: event.avatarUrl,
        bio: event.bio,
      );
      emit(AuthAuthenticated(user: updatedUser));
    } catch (e) {
      emit(AuthError(_extractErrorMessage(e)));
    }
  }
}
