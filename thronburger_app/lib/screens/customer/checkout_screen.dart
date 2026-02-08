import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../models/models.dart';
import '../../repositories/repositories.dart';
import '../../blocs/customer_cart/customer_cart_bloc.dart';
import '../../blocs/customer_auth/customer_auth_bloc.dart';

/// Checkout Screen
/// Order type, address, summary, and payment
class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _orderType = 'pickup'; // 'delivery' or 'pickup'
  Address? _selectedAddress;
  List<Address> _addresses = [];
  final _notesController = TextEditingController();
  bool _isLoading = false;
  bool _isLoadingAddresses = true;

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadAddresses() async {
    try {
      final customerRepo = context.read<CustomerRepository>();
      final user = customerRepo.currentUser;

      if (user != null) {
        final customer = await customerRepo.getCustomer(user.uid);
        setState(() {
          _addresses = customer?.addresses ?? [];
          _selectedAddress = _addresses.isNotEmpty
              ? _addresses.firstWhere(
                  (a) => a.isDefault,
                  orElse: () => _addresses.first,
                )
              : null;
          _isLoadingAddresses = false;
        });
      } else {
        setState(() => _isLoadingAddresses = false);
      }
    } catch (e) {
      setState(() => _isLoadingAddresses = false);
    }
  }

  Future<void> _placeOrder() async {
    print('🔵 _placeOrder called');
    print('🔵 Order type: $_orderType');
    print('🔵 Selected address: $_selectedAddress');

    if (_orderType == 'delivery' && _selectedAddress == null) {
      print('❌ Delivery address validation failed');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a delivery address')),
      );
      return;
    }

    print('✅ Validation passed, setting loading state');
    setState(() => _isLoading = true);

    try {
      print('🔵 Getting repositories...');
      final customerRepo = context.read<CustomerRepository>();
      final orderRepo = context.read<OrderRepository>();
      final cartBloc = context.read<CustomerCartBloc>();
      final user = customerRepo.currentUser;
      print('🔵 User: ${user?.uid}');

      final customer = user != null
          ? await customerRepo.getCustomer(user.uid)
          : null;
      print('🔵 Customer: ${customer?.name}');

      if (user == null) {
        print('❌ User not authenticated');
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Sign In Required'),
              content: const Text(
                'Please sign in or create an account to place your order.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    context.push('/customer/auth');
                  },
                  child: const Text('Sign In'),
                ),
              ],
            ),
          );
        }
        return;
      }

      // Prepare items
      print('🔵 Preparing items from cart...');
      print('🔵 Cart items count: ${cartBloc.state.items.length}');

      for (var i = 0; i < cartBloc.state.items.length; i++) {
        final cartItem = cartBloc.state.items[i];
        print('🔵 Cart item $i:');
        print('  - menuItem.id: ${cartItem.menuItem.id}');
        print('  - menuItem.id type: ${cartItem.menuItem.id.runtimeType}');
        print('  - menuItem.id isEmpty: ${cartItem.menuItem.id.isEmpty}');
        print('  - menuItem.name: ${cartItem.menuItem.name}');
        print('  - quantity: ${cartItem.quantity}');
        print('  - unitPrice: ${cartItem.menuItem.price}');
      }

      final items = cartBloc.state.items.map((item) {
        final id = item.menuItem.id;
        if (id.isEmpty) {
          print(
            '❌ WARNING: Menu item has empty ID! Name: ${item.menuItem.name}',
          );
        }
        return {
          'menuItemId': id,
          'quantity': item.quantity,
          'unitPrice': item.menuItem.price,
        };
      }).toList();
      print('🔵 Items count: ${items.length}');
      print('🔵 Items: $items');

      // Create order
      print('🔵 Creating order...');
      print('🔵 customerId: ${user.uid}');
      print('🔵 orderType: ${_orderType == 'delivery' ? 'online' : 'pickup'}');
      print('🔵 customerName: ${customer?.name}');
      print('🔵 customerPhone: ${customer?.phone}');
      print('🔵 customerAddress: ${_selectedAddress?.fullAddress}');
      print('🔵 notes: ${_notesController.text}');

      await orderRepo.createCustomerOrder(
        customerId: user.uid,
        items: items,
        orderType: _orderType == 'delivery'
            ? OrderType.online
            : OrderType.pickup,
        customerName: customer?.name,
        customerPhone: customer?.phone,
        customerAddress: _orderType == 'delivery'
            ? _selectedAddress?.fullAddress
            : null,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      );

      print('✅ Order created successfully!');

      // Clear cart
      print('🔵 Clearing cart...');
      cartBloc.add(CustomerCartCleared());

      if (mounted) {
        print('🔵 Showing success dialog...');
        // Show success message
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('Order Placed!'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle,
                  size: 64,
                  color: AppTheme.success,
                ),
                const SizedBox(height: 16),
                const Text('Your order has been placed successfully.'),
                const SizedBox(height: 8),
                Text(
                  _orderType == 'pickup'
                      ? 'We\'ll notify you when it\'s ready for pickup.'
                      : 'Your order is on the way!',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.go('/customer/orders');
                },
                child: const Text('View Orders'),
              ),
            ],
          ),
        );
      }
    } catch (e, stackTrace) {
      print('❌ ERROR in _placeOrder: $e');
      print('❌ Stack trace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    } finally {
      print('🔵 Finally block - resetting loading state');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<CustomerAuthBloc, CustomerAuthState>(
          listener: (context, state) {
            if (state.status == CustomerAuthStatus.authenticated) {
              _loadAddresses();
            }
          },
        ),
      ],
      child: BlocBuilder<CustomerCartBloc, CustomerCartState>(
        builder: (context, cartState) {
          if (cartState.items.isEmpty) {
            return Scaffold(
              appBar: AppBar(title: const Text('Checkout')),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.shopping_cart_outlined, size: 64),
                    const SizedBox(height: 16),
                    const Text('Your cart is empty'),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => context.go('/customer/menu'),
                      child: const Text('Browse Menu'),
                    ),
                  ],
                ),
              ),
            );
          }

          return Scaffold(
            appBar: AppBar(
              title: const Text('Checkout'),
              backgroundColor: AppTheme.background,
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Order Type
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Order Type',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _OrderTypeOption(
                                    icon: Icons.store,
                                    label: 'Pickup',
                                    selected: _orderType == 'pickup',
                                    onTap: () =>
                                        setState(() => _orderType = 'pickup'),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _OrderTypeOption(
                                    icon: Icons.delivery_dining,
                                    label: 'Delivery',
                                    selected: _orderType == 'delivery',
                                    onTap: () =>
                                        setState(() => _orderType = 'delivery'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Delivery Address
                    if (_orderType == 'delivery') ...[
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Delivery Address',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  TextButton.icon(
                                    onPressed: () => _showAddAddressSheet(),
                                    icon: const Icon(Icons.add, size: 16),
                                    label: const Text('Add'),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              if (_isLoadingAddresses)
                                const Center(child: CircularProgressIndicator())
                              else if (_addresses.isEmpty)
                                const Text('No saved addresses')
                              else
                                ...(_addresses.map(
                                  (address) => ListTile(
                                    leading: Icon(
                                      _selectedAddress == address
                                          ? Icons.radio_button_checked
                                          : Icons.radio_button_unchecked,
                                      color: _selectedAddress == address
                                          ? AppTheme.primary
                                          : AppTheme.textSecondary,
                                    ),
                                    title: Text(address.label),
                                    subtitle: Text(
                                      address.fullAddress,
                                      maxLines: 2,
                                    ),
                                    contentPadding: EdgeInsets.zero,
                                    onTap: () => setState(
                                      () => _selectedAddress = address,
                                    ),
                                  ),
                                )),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Order Notes
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Order Notes',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _notesController,
                              decoration: const InputDecoration(
                                hintText: 'Any special instructions?',
                              ),
                              maxLines: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Order Summary
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Order Summary',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ...cartState.items.map(
                              (item) => Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${item.quantity}x ${item.menuItem.name}',
                                    ),
                                    Text(
                                      '${item.lineTotal.toStringAsFixed(0)} IQD',
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const Divider(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Total',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                Text(
                                  '${cartState.totalPrice.toStringAsFixed(0)} IQD',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: AppTheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Payment Method
                    Card(
                      child: ListTile(
                        leading: const Icon(
                          Icons.payments_outlined,
                          color: AppTheme.primary,
                        ),
                        title: const Text('Payment Method'),
                        subtitle: const Text('Cash on Delivery'),
                        trailing: const Icon(
                          Icons.check_circle,
                          color: AppTheme.success,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Place Order Button
                    ElevatedButton(
                      onPressed: _isLoading ? null : _placeOrder,
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(
                              'Place Order • ${cartState.totalPrice.toStringAsFixed(0)} IQD',
                            ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showAddAddressSheet() {
    final labelController = TextEditingController();
    final areaController = TextEditingController();
    final streetController = TextEditingController();
    final buildingController = TextEditingController();
    final apartmentController = TextEditingController();

    // Capture references from parent context BEFORE opening bottom sheet
    final customerRepo = context.read<CustomerRepository>();
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Add Address',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: labelController,
              decoration: const InputDecoration(
                labelText: 'Label (e.g., Home, Work)',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: areaController,
              decoration: const InputDecoration(labelText: 'Area/Neighborhood'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: streetController,
              decoration: const InputDecoration(labelText: 'Street'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: buildingController,
              decoration: const InputDecoration(labelText: 'Building/House'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: apartmentController,
              decoration: const InputDecoration(labelText: 'Floor/Apartment'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                if (labelController.text.isEmpty ||
                    areaController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please fill in Label and Area fields'),
                    ),
                  );
                  return;
                }

                // Show loading indicator
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) =>
                      const Center(child: CircularProgressIndicator()),
                );

                try {
                  print('🏠 Saving address...');
                  final user = customerRepo.currentUser;
                  print('🏠 User: ${user?.uid}');

                  if (user == null) {
                    throw Exception('Please sign in to add an address');
                  }

                  final address = Address(
                    id: '',
                    customerId: user.uid,
                    label: labelController.text,
                    area: areaController.text,
                    street: streetController.text.isNotEmpty
                        ? streetController.text
                        : 'N/A',
                    building: buildingController.text.isNotEmpty
                        ? buildingController.text
                        : null,
                    apartment: apartmentController.text.isNotEmpty
                        ? apartmentController.text
                        : null,
                    isDefault: _addresses.isEmpty,
                    createdAt: DateTime.now(),
                  );
                  print(
                    '🏠 Address object created: ${address.label}, ${address.area}',
                  );

                  final newAddress = await customerRepo.addAddress(address);
                  print('🏠 Address saved! ID: ${newAddress.id}');

                  // Close loading dialog
                  if (context.mounted) Navigator.pop(context);

                  setState(() {
                    _addresses.add(newAddress);
                    _selectedAddress ??= newAddress;
                  });
                  print(
                    '🏠 Address added to local list. Total: ${_addresses.length}',
                  );

                  // Close the bottom sheet
                  if (context.mounted) Navigator.pop(context);
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(
                      content: Text('Address saved successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e, stackTrace) {
                  print('❌ Address save error: $e');
                  print('❌ Stack trace: $stackTrace');
                  // Close loading dialog
                  if (context.mounted) Navigator.pop(context);
                  // Close the bottom sheet so user can see the error
                  if (context.mounted) Navigator.pop(context);

                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text('Failed to save address: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Save Address'),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _OrderTypeOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _OrderTypeOption({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: selected
              ? AppTheme.primary.withValues(alpha: 0.1)
              : AppTheme.surface,
          border: Border.all(
            color: selected ? AppTheme.primary : AppTheme.border,
            width: selected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: selected ? AppTheme.primary : AppTheme.textSecondary,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                color: selected ? AppTheme.primary : AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
