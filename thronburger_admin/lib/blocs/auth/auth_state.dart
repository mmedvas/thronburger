part of 'auth_bloc.dart';

/// Auth Status
enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

/// Auth State
class AuthState extends Equatable {
  final AuthStatus status;
  final User? user;
  final UserProfile? profile;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.profile,
    this.errorMessage,
  });

  /// Initial state
  const AuthState.initial() : this();

  /// Loading state
  const AuthState.loading() : this(status: AuthStatus.loading);

  /// Authenticated state
  const AuthState.authenticated({
    required User user,
    required UserProfile? profile,
  }) : this(status: AuthStatus.authenticated, user: user, profile: profile);

  /// Unauthenticated state
  const AuthState.unauthenticated() : this(status: AuthStatus.unauthenticated);

  /// Error state
  const AuthState.error(String message)
    : this(status: AuthStatus.error, errorMessage: message);

  /// Check if user is admin
  bool get isAdmin => profile?.isAdmin ?? false;

  /// Check if user is cashier (any authenticated user)
  bool get isCashier => status == AuthStatus.authenticated;

  /// Copy with method
  AuthState copyWith({
    AuthStatus? status,
    User? user,
    UserProfile? profile,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      profile: profile ?? this.profile,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, user, profile, errorMessage];
}
