part of 'customer_auth_bloc.dart';

abstract class CustomerAuthEvent extends Equatable {
  const CustomerAuthEvent();

  @override
  List<Object?> get props => [];
}

/// Check initial auth state
class CustomerAuthCheckRequested extends CustomerAuthEvent {
  const CustomerAuthCheckRequested();
}

/// Send OTP to phone number
class CustomerAuthOtpSent extends CustomerAuthEvent {
  final String phone;

  const CustomerAuthOtpSent(this.phone);

  @override
  List<Object?> get props => [phone];
}

/// Verify OTP
class CustomerAuthOtpVerified extends CustomerAuthEvent {
  final String phone;
  final String otp;

  const CustomerAuthOtpVerified({
    required this.phone,
    required this.otp,
  });

  @override
  List<Object?> get props => [phone, otp];
}

/// Update customer name
class CustomerAuthNameUpdated extends CustomerAuthEvent {
  final String name;

  const CustomerAuthNameUpdated(this.name);

  @override
  List<Object?> get props => [name];
}

/// Skip name entry
class CustomerAuthNameSkipped extends CustomerAuthEvent {
  const CustomerAuthNameSkipped();
}

/// Logout
class CustomerAuthLogoutRequested extends CustomerAuthEvent {
  const CustomerAuthLogoutRequested();
}

/// Auth state changed (from stream)
class CustomerAuthStateChanged extends CustomerAuthEvent {
  final User? user;

  const CustomerAuthStateChanged(this.user);

  @override
  List<Object?> get props => [user];
}
