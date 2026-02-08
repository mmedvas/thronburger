import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/app_localizations.dart';
import '../../config/theme.dart';
import '../../models/models.dart';
import '../../repositories/repositories.dart';
import '../../blocs/locale/locale_bloc.dart';
import '../../blocs/customer_auth/customer_auth_bloc.dart';

/// Customer Profile Screen
/// Profile info and settings
class CustomerProfileScreen extends StatefulWidget {
  const CustomerProfileScreen({super.key});

  @override
  State<CustomerProfileScreen> createState() => _CustomerProfileScreenState();
}

class _CustomerProfileScreenState extends State<CustomerProfileScreen> {
  Customer? _customer;
  bool _isLoading = true;
  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    try {
      final customerRepo = context.read<CustomerRepository>();
      final user = customerRepo.currentUser;

      if (user != null) {
        final customer = await customerRepo.getCustomer(user.uid);
        setState(() {
          _customer = customer;
          _nameController.text = customer?.name ?? '';
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateName() async {
    if (_nameController.text.isEmpty) return;

    try {
      final customerRepo = context.read<CustomerRepository>();
      final user = customerRepo.currentUser;

      if (user != null) {
        final updated = await customerRepo.updateName(
          user.uid,
          _nameController.text,
        );
        setState(() => _customer = updated);
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Name updated')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    }
  }

  Future<void> _signOut() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.logout),
        content: Text(l10n.logoutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              l10n.logout,
              style: const TextStyle(color: AppTheme.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      context.read<CustomerAuthBloc>().add(const CustomerAuthLogoutRequested());
      context.go('/');
    }
  }

  Future<void> _deleteAccount() async {
    // First confirmation
    final firstConfirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This will permanently remove:\n\n'
          '• Your profile information\n'
          '• All saved addresses\n'
          '• Your order history\n\n'
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete Account',
              style: TextStyle(color: AppTheme.error),
            ),
          ),
        ],
      ),
    );

    if (firstConfirm != true || !mounted) return;

    // Second confirmation with typing
    final deleteController = TextEditingController();
    final secondConfirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Type DELETE to confirm account deletion:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: deleteController,
              decoration: const InputDecoration(
                hintText: 'Type DELETE',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (deleteController.text.toUpperCase() == 'DELETE') {
                Navigator.pop(context, true);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please type DELETE to confirm'),
                    backgroundColor: AppTheme.error,
                  ),
                );
              }
            },
            child: const Text(
              'Delete Forever',
              style: TextStyle(color: AppTheme.error),
            ),
          ),
        ],
      ),
    );

    if (secondConfirm != true || !mounted) return;

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final customerRepo = context.read<CustomerRepository>();
      await customerRepo.deleteAccount();

      if (mounted) {
        Navigator.pop(context); // Close loading
        context.read<CustomerAuthBloc>().add(const CustomerAuthLogoutRequested());
        context.go('/');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Your account has been deleted'),
            backgroundColor: AppTheme.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete account: ${e.toString()}'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  void _showLanguageSelector() {
    final l10n = AppLocalizations.of(context);
    final localeBloc = context.read<LocaleBloc>();
    final currentLocale = localeBloc.state.locale;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              l10n.language,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            leading: const Text('🇺🇸', style: TextStyle(fontSize: 24)),
            title: Text(l10n.english),
            trailing: currentLocale.languageCode == 'en'
                ? const Icon(Icons.check, color: AppTheme.primary)
                : null,
            onTap: () {
              localeBloc.add(const LocaleChanged(Locale('en')));
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Text('🇮🇶', style: TextStyle(fontSize: 24)),
            title: Text(l10n.arabic),
            trailing: currentLocale.languageCode == 'ar'
                ? const Icon(Icons.check, color: AppTheme.primary)
                : null,
            onTap: () {
              localeBloc.add(const LocaleChanged(Locale('ar')));
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Text('🇮🇶', style: TextStyle(fontSize: 24)),
            title: Text(l10n.kurdish),
            trailing: currentLocale.languageCode == 'ku'
                ? const Icon(Icons.check, color: AppTheme.primary)
                : null,
            onTap: () {
              localeBloc.add(const LocaleChanged(Locale('ku')));
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  String _getLanguageName(String code) {
    final l10n = AppLocalizations.of(context);
    switch (code) {
      case 'en':
        return l10n.english;
      case 'ar':
        return l10n.arabic;
      case 'ku':
        return l10n.kurdish;
      default:
        return l10n.english;
    }
  }

  Widget _buildSignInPrompt(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.account_circle_outlined,
                size: 48,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Welcome to Thronburger!',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Sign in with your phone number to place orders and save your addresses.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => context.go('/customer/auth'),
                icon: const Icon(Icons.phone),
                label: const Text('Sign In with Phone'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final customerRepo = context.read<CustomerRepository>();
    final user = customerRepo.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: AppTheme.background,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : user == null
          ? _buildSignInPrompt(context)
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Profile Header
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: AppTheme.primary,
                            child: Text(
                              (_customer?.name ?? 'U')
                                  .substring(0, 1)
                                  .toUpperCase(),
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _customer?.name ?? 'Customer',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _customer?.phone ?? user.phoneNumber ?? '',
                            style: TextStyle(color: AppTheme.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Edit Name
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Your Name',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _nameController,
                                  decoration: const InputDecoration(
                                    hintText: 'Enter your name',
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton(
                                onPressed: _updateName,
                                child: const Text('Save'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Saved Addresses
                  Card(
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.location_on_outlined),
                          title: const Text('Saved Addresses'),
                          subtitle: Text(
                            '${_customer?.addresses.length ?? 0} addresses',
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => _showAddresses(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Language Setting
                  BlocBuilder<LocaleBloc, LocaleState>(
                    builder: (context, localeState) {
                      final l10n = AppLocalizations.of(context);
                      return Card(
                        child: ListTile(
                          leading: const Icon(Icons.language),
                          title: Text(l10n.language),
                          subtitle: Text(
                            _getLanguageName(localeState.locale.languageCode),
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: _showLanguageSelector,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // Settings
                  Card(
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.help_outline),
                          title: const Text('Help & Support'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Contact: 0750 123 4567'),
                              ),
                            );
                          },
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.info_outline),
                          title: const Text('About'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            showAboutDialog(
                              context: context,
                              applicationName: 'Thronburger',
                              applicationVersion: '1.0.0',
                              applicationLegalese: '© 2024 Thronburger',
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Sign Out
                  OutlinedButton.icon(
                    onPressed: _signOut,
                    icon: const Icon(Icons.logout, color: AppTheme.error),
                    label: const Text(
                      'Sign Out',
                      style: TextStyle(color: AppTheme.error),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppTheme.error),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Delete Account
                  TextButton.icon(
                    onPressed: _deleteAccount,
                    icon: const Icon(
                      Icons.delete_forever,
                      color: AppTheme.textMuted,
                      size: 20,
                    ),
                    label: const Text(
                      'Delete Account',
                      style: TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  void _showAddresses() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          final addresses = _customer?.addresses ?? [];
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Saved Addresses',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: addresses.isEmpty
                    ? const Center(child: Text('No saved addresses'))
                    : ListView.builder(
                        controller: scrollController,
                        itemCount: addresses.length,
                        itemBuilder: (context, index) {
                          final address = addresses[index];
                          return ListTile(
                            leading: Icon(
                              address.isDefault
                                  ? Icons.home
                                  : Icons.location_on_outlined,
                              color: address.isDefault
                                  ? AppTheme.primary
                                  : null,
                            ),
                            title: Text(address.label),
                            subtitle: Text(address.fullAddress),
                            trailing: address.isDefault
                                ? const Chip(label: Text('Default'))
                                : null,
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
