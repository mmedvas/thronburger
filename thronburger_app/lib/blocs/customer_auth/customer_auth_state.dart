part of 'customer_auth_bloc.dart';

enum CustomerAuthStatus {
  initial,
  sendingOtp,
  otpSent,
  verifying,
  authenticated,
  needsName,
  unauthenticated,
  error,
}

class CustomerAuthState extends Equatable {
  final CustomerAuthStatus status;
  final Customer? customer;
  final String? phone;
  final String? errorMessage;
  final bool isNewUser;

  const CustomerAuthState({
    this.status = CustomerAuthStatus.initial,
    this.customer,
    this.phone,
    this.errorMessage,
    this.isNewUser = false,
  });

  bool get isAuthenticated => status == CustomerAuthStatus.authenticated;
  bool get isLoading =>
      status == CustomerAuthStatus.sendingOtp ||
      status == CustomerAuthStatus.verifying;

  @override
  List<Object?> get props => [status, customer, phone, errorMessage, isNewUser];

  CustomerAuthState copyWith({
    CustomerAuthStatus? status,
    Customer? customer,
    String? phone,
    String? errorMessage,
    bool? isNewUser,
  }) {
    return CustomerAuthState(
      status: status ?? this.status,
      customer: customer ?? this.customer,
      phone: phone ?? this.phone,
      errorMessage: errorMessage,
      isNewUser: isNewUser ?? this.isNewUser,
    );
  }
}
