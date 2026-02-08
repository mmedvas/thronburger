import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/models.dart';
import '../../repositories/customer_repository.dart';

part 'customer_auth_event.dart';
part 'customer_auth_state.dart';

class CustomerAuthBloc extends Bloc<CustomerAuthEvent, CustomerAuthState> {
  final CustomerRepository _customerRepository;
  StreamSubscription<User?>? _authSubscription;

  CustomerAuthBloc({required CustomerRepository customerRepository})
    : _customerRepository = customerRepository,
      super(const CustomerAuthState()) {
    on<CustomerAuthCheckRequested>(_onCheckRequested);
    on<CustomerAuthOtpSent>(_onOtpSent);
    on<CustomerAuthOtpVerified>(_onOtpVerified);
    on<CustomerAuthNameUpdated>(_onNameUpdated);
    on<CustomerAuthNameSkipped>(_onNameSkipped);
    on<CustomerAuthLogoutRequested>(_onLogoutRequested);
    on<CustomerAuthStateChanged>(_onAuthStateChanged);

    // Listen to auth state changes
    _authSubscription = _customerRepository.authStateChanges.listen((user) {
      add(CustomerAuthStateChanged(user));
    });
  }

  Future<void> _onCheckRequested(
    CustomerAuthCheckRequested event,
    Emitter<CustomerAuthState> emit,
  ) async {
    final user = _customerRepository.currentUser;
    if (user != null) {
      try {
        final customer = await _customerRepository.getCustomer(user.uid);
        if (customer != null) {
          emit(
            state.copyWith(
              status: CustomerAuthStatus.authenticated,
              customer: customer,
              phone: user.phoneNumber,
            ),
          );
        } else {
          // User exists but no customer profile - create one
          final phone = user.phoneNumber ?? '';
          final newCustomer = await _customerRepository.upsertCustomer(
            userId: user.uid,
            phone: phone,
          );
          emit(
            state.copyWith(
              status: CustomerAuthStatus.needsName,
              customer: newCustomer,
              phone: phone,
              isNewUser: true,
            ),
          );
        }
      } catch (e) {
        emit(
          state.copyWith(
            status: CustomerAuthStatus.unauthenticated,
            errorMessage: e.toString(),
          ),
        );
      }
    } else {
      emit(state.copyWith(status: CustomerAuthStatus.unauthenticated));
    }
  }

  Future<void> _onOtpSent(
    CustomerAuthOtpSent event,
    Emitter<CustomerAuthState> emit,
  ) async {
    emit(
      state.copyWith(status: CustomerAuthStatus.sendingOtp, phone: event.phone),
    );

    try {
      await _customerRepository.sendOtp(event.phone);
      emit(
        state.copyWith(status: CustomerAuthStatus.otpSent, phone: event.phone),
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage = e.message ?? 'Unknown error';
      if (errorMessage.contains('rate limit') ||
          errorMessage.contains('too many requests')) {
        errorMessage = 'Too many attempts. Please wait a few minutes.';
      }
      emit(
        state.copyWith(
          status: CustomerAuthStatus.error,
          errorMessage: errorMessage,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: CustomerAuthStatus.error,
          errorMessage: 'Failed to send code. Please try again.',
        ),
      );
    }
  }

  Future<void> _onOtpVerified(
    CustomerAuthOtpVerified event,
    Emitter<CustomerAuthState> emit,
  ) async {
    emit(state.copyWith(status: CustomerAuthStatus.verifying));

    try {
      final response = await _customerRepository.verifyOtp(
        event.phone,
        event.otp,
      );

      if (response.user != null) {
        // Check if customer profile exists
        Customer? customer = await _customerRepository.getCustomer(
          response.user!.uid,
        );

        if (customer == null) {
          // New user - create customer profile
          customer = await _customerRepository.upsertCustomer(
            userId: response.user!.uid,
            phone: event.phone,
          );
          emit(
            state.copyWith(
              status: CustomerAuthStatus.needsName,
              customer: customer,
              phone: event.phone,
              isNewUser: true,
            ),
          );
        } else if (customer.name == null || customer.name!.isEmpty) {
          // Existing user without name
          emit(
            state.copyWith(
              status: CustomerAuthStatus.needsName,
              customer: customer,
              phone: event.phone,
              isNewUser: false,
            ),
          );
        } else {
          // Existing user with name - fully authenticated
          emit(
            state.copyWith(
              status: CustomerAuthStatus.authenticated,
              customer: customer,
              phone: event.phone,
              isNewUser: false,
            ),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = e.message ?? 'Unknown error';
      if (errorMessage.contains('invalid') ||
          errorMessage.contains('expired')) {
        errorMessage = 'Invalid or expired code. Please try again.';
      }
      emit(
        state.copyWith(
          status: CustomerAuthStatus.otpSent, // Stay on OTP screen
          errorMessage: errorMessage,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: CustomerAuthStatus.otpSent,
          errorMessage: 'Verification failed. Please try again.',
        ),
      );
    }
  }

  Future<void> _onNameUpdated(
    CustomerAuthNameUpdated event,
    Emitter<CustomerAuthState> emit,
  ) async {
    if (state.customer == null) return;

    emit(state.copyWith(status: CustomerAuthStatus.verifying));

    try {
      final updatedCustomer = await _customerRepository.updateName(
        state.customer!.id,
        event.name,
      );
      emit(
        state.copyWith(
          status: CustomerAuthStatus.authenticated,
          customer: updatedCustomer,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: CustomerAuthStatus.needsName,
          errorMessage: 'Failed to save name. Please try again.',
        ),
      );
    }
  }

  Future<void> _onNameSkipped(
    CustomerAuthNameSkipped event,
    Emitter<CustomerAuthState> emit,
  ) async {
    emit(state.copyWith(status: CustomerAuthStatus.authenticated));
  }

  Future<void> _onLogoutRequested(
    CustomerAuthLogoutRequested event,
    Emitter<CustomerAuthState> emit,
  ) async {
    await _customerRepository.signOut();
    emit(const CustomerAuthState(status: CustomerAuthStatus.unauthenticated));
  }

  Future<void> _onAuthStateChanged(
    CustomerAuthStateChanged event,
    Emitter<CustomerAuthState> emit,
  ) async {
    if (event.user == null && state.isAuthenticated) {
      // User was logged out
      emit(const CustomerAuthState(status: CustomerAuthStatus.unauthenticated));
    }
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}
