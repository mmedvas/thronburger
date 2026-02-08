part of 'auth_bloc.dart';

/// Auth Events
sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Check initial auth state
class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

/// Login event
class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

/// Signup event
class AuthSignupRequested extends AuthEvent {
  final String email;
  final String password;
  final String? fullName;

  const AuthSignupRequested({
    required this.email,
    required this.password,
    this.fullName,
  });

  @override
  List<Object?> get props => [email, password, fullName];
}

/// Logout event
class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

/// Auth state changed (from stream)
class AuthStateChanged extends AuthEvent {
  final User? user;

  const AuthStateChanged(this.user);

  @override
  List<Object?> get props => [user];
}
