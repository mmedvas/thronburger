import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../l10n/app_localizations.dart';

import '../../../blocs/customer_auth/customer_auth_bloc.dart';
import '../../../config/theme.dart';

class PhoneInputScreen extends StatefulWidget {
  const PhoneInputScreen({super.key});

  @override
  State<PhoneInputScreen> createState() => _PhoneInputScreenState();
}

class _PhoneInputScreenState extends State<PhoneInputScreen>
    with WidgetsBindingObserver {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _phoneFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Auto-focus phone field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _phoneFocusNode.requestFocus();
      // Check if OTP was already sent (e.g. from reCAPTCHA return)
      _checkIfOtpAlreadySent();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _phoneController.dispose();
    _phoneFocusNode.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // App came back from reCAPTCHA in Safari
      // Give Firebase a moment to process the callback, then check state
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _checkIfOtpAlreadySent();
        }
      });
    }
  }

  void _checkIfOtpAlreadySent() {
    final authState = context.read<CustomerAuthBloc>().state;
    if (authState.status == CustomerAuthStatus.otpSent) {
      context.go('/customer/auth/verify', extra: authState.phone);
    } else if (authState.status == CustomerAuthStatus.authenticated) {
      context.go('/customer');
    } else if (authState.status == CustomerAuthStatus.needsName) {
      context.go('/customer/auth/name');
    }
  }

  String _formatPhoneNumber(String phone) {
    // Remove all non-digits
    String digits = phone.replaceAll(RegExp(r'\D'), '');

    // If it starts with 0, replace with country code
    if (digits.startsWith('0')) {
      digits = '964${digits.substring(1)}';
    }

    // If it doesn't start with country code, add it
    if (!digits.startsWith('964')) {
      digits = '964$digits';
    }

    return '+$digits';
  }

  void _sendOtp() {
    if (_formKey.currentState!.validate()) {
      final formattedPhone = _formatPhoneNumber(_phoneController.text);
      context.read<CustomerAuthBloc>().add(CustomerAuthOtpSent(formattedPhone));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocListener<CustomerAuthBloc, CustomerAuthState>(
      listener: (context, state) {
        if (state.status == CustomerAuthStatus.otpSent) {
          context.go('/customer/auth/verify', extra: state.phone);
        } else if (state.status == CustomerAuthStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? l10n.somethingWentWrong),
              backgroundColor: AppTheme.error,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/'),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  // Icon
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.phone_android_rounded,
                      size: 32,
                      color: AppTheme.primary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Title
                  Text(
                    l10n.phoneInputTitle,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.phoneInputSubtitle,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Phone Input
                  TextFormField(
                    controller: _phoneController,
                    focusNode: _phoneFocusNode,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.done,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9+]')),
                      LengthLimitingTextInputFormatter(15),
                    ],
                    decoration: InputDecoration(
                      hintText: l10n.phoneHint,
                      prefixIcon: const Icon(Icons.phone_outlined),
                      prefixText: '+964 ',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.phoneRequired;
                      }
                      // Remove non-digits for validation
                      final digits = value.replaceAll(RegExp(r'\D'), '');
                      if (digits.length < 10) {
                        return l10n.invalidPhone;
                      }
                      return null;
                    },
                    onFieldSubmitted: (_) => _sendOtp(),
                  ),
                  const Spacer(),
                  // Send Code Button
                  BlocBuilder<CustomerAuthBloc, CustomerAuthState>(
                    builder: (context, state) {
                      final isLoading =
                          state.status == CustomerAuthStatus.sendingOtp;
                      return SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _sendOtp,
                          child: isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.black,
                                  ),
                                )
                              : Text(l10n.sendCode),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
