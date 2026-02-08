import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/models.dart';
import '../../repositories/repositories.dart';

part 'auth_event.dart';
part 'auth_state.dart';

/// Authentication BLoC
/// Manages staff authentication state
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  StreamSubscription<AuthState>? _authStateSubscription;

  AuthBloc({required AuthRepository authRepository})
    : _authRepository = authRepository,
      super(const AuthState.initial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthSignupRequested>(_onSignupRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthStateChanged>(_onAuthStateChanged);

    // Listen to Firebase auth state changes
    _authStateSubscription = _authRepository.authStateChanges
        .asyncMap((user) async {
          if (user != null) {
            final profile = await _authRepository.getProfile(user.uid);
            // Only consider authenticated for this Bloc if it's a staff member (has profile)
            if (profile != null) {
              return AuthState.authenticated(user: user, profile: profile);
            }
          }
          return const AuthState.unauthenticated();
        })
        .listen((state) {
          add(AuthStateChanged(state.user));
        });
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());

    final user = _authRepository.currentUser;
    if (user != null) {
      final profile = await _authRepository.getProfile(user.uid);
      if (profile != null) {
        emit(AuthState.authenticated(user: user, profile: profile));
      } else {
        emit(const AuthState.unauthenticated());
      }
    } else {
      emit(const AuthState.unauthenticated());
    }
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());

    try {
      final response = await _authRepository.signIn(
        email: event.email,
        password: event.password,
      );

      if (response.user != null) {
        final profile = await _authRepository.getProfile(response.user!.uid);
        if (profile != null) {
          emit(AuthState.authenticated(user: response.user!, profile: profile));
        } else {
          emit(AuthState.error('Access Denied: Not a staff account'));
        }
      } else {
        emit(AuthState.error('Login failed'));
      }
    } on FirebaseAuthException catch (e) {
      emit(AuthState.error(e.message ?? 'Login failed'));
    } catch (e) {
      emit(AuthState.error(e.toString()));
    }
  }

  Future<void> _onSignupRequested(
    AuthSignupRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());

    try {
      final response = await _authRepository.signUp(
        email: event.email,
        password: event.password,
        fullName: event.fullName,
      );

      if (response.user != null) {
        // Wait a moment for the trigger to create profile
        await Future.delayed(const Duration(milliseconds: 500));
        final profile = await _authRepository.getProfile(response.user!.uid);
        if (profile != null) {
          emit(AuthState.authenticated(user: response.user!, profile: profile));
        } else {
          emit(
            AuthState.error(
              'Account created but staff profile missing. Contact admin.',
            ),
          );
        }
      } else {
        emit(AuthState.error('Signup failed'));
      }
    } on FirebaseAuthException catch (e) {
      emit(AuthState.error(e.message ?? 'Signup failed'));
    } catch (e) {
      emit(AuthState.error(e.toString()));
    }
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _authRepository.signOut();
    emit(const AuthState.unauthenticated());
  }

  void _onAuthStateChanged(
    AuthStateChanged event,
    Emitter<AuthState> emit,
  ) async {
    if (event.user != null) {
      final profile = await _authRepository.getProfile(event.user!.uid);
      if (profile != null) {
        emit(AuthState.authenticated(user: event.user!, profile: profile));
      } else {
        emit(const AuthState.unauthenticated());
      }
    } else {
      emit(const AuthState.unauthenticated());
    }
  }

  @override
  Future<void> close() {
    _authStateSubscription?.cancel();
    return super.close();
  }
}
