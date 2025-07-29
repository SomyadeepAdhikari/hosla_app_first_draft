import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

// Auth Events
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {}

class AuthLoginRequested extends AuthEvent {
  final String phoneNumber;

  const AuthLoginRequested(this.phoneNumber);

  @override
  List<Object?> get props => [phoneNumber];
}

class AuthOTPVerificationRequested extends AuthEvent {
  final String otp;

  const AuthOTPVerificationRequested(this.otp);

  @override
  List<Object?> get props => [otp];
}

class AuthLogoutRequested extends AuthEvent {}

// Auth State
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final String userId;
  final String phoneNumber;

  const AuthAuthenticated({
    required this.userId,
    required this.phoneNumber,
  });

  @override
  List<Object?> get props => [userId, phoneNumber];
}

class AuthUnauthenticated extends AuthState {}

class AuthOTPSent extends AuthState {
  final String phoneNumber;

  const AuthOTPSent(this.phoneNumber);

  @override
  List<Object?> get props => [phoneNumber];
}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

// Auth BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthLoginRequested>(_onAuthLoginRequested);
    on<AuthOTPVerificationRequested>(_onAuthOTPVerificationRequested);
    on<AuthLogoutRequested>(_onAuthLogoutRequested);
  }

  void _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    // Check if user is already authenticated
    await Future.delayed(const Duration(seconds: 1));

    // For now, emit unauthenticated
    emit(AuthUnauthenticated());
  }

  void _onAuthLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      // Send OTP logic here
      await Future.delayed(const Duration(seconds: 2));

      emit(AuthOTPSent(event.phoneNumber));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  void _onAuthOTPVerificationRequested(
    AuthOTPVerificationRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      // Verify OTP logic here
      await Future.delayed(const Duration(seconds: 2));

      emit(const AuthAuthenticated(
        userId: 'user123',
        phoneNumber: '+91XXXXXXXXXX',
      ));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  void _onAuthLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    // Logout logic here
    await Future.delayed(const Duration(seconds: 1));

    emit(AuthUnauthenticated());
  }
}
