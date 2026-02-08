import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/cart/cart_bloc.dart';
import '../../config/theme.dart';
import '../../models/models.dart';
import '../../repositories/repositories.dart';
import 'widgets/menu_grid.dart';
import 'widgets/cart_panel.dart';
import 'widgets/receipt_dialog.dart';

/// POS Screen
/// Point of Sale interface for creating orders
class PosScreen extends StatefulWidget {
  const PosScreen({super.key});

  @override
  State<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends State<PosScreen> {
  MenuCategory _selectedCategory = MenuCategory.all;
  List<MenuItem> _menuItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMenuItems();
  }

  Future<void> _loadMenuItems() async {
    setState(() => _isLoading = true);
    try {
      final menuRepo = context.read<MenuRepository>();
      final items = await menuRepo.getMenuItems(onlyAvailable: true);
      setState(() {
        _menuItems = items;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load menu: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  List<MenuItem> get _filteredItems {
    if (_selectedCategory == MenuCategory.all) {
      return _menuItems;
    }
    return _menuItems
        .where((item) => item.category == _selectedCategory.value)
        .toList();
  }

  Future<void> _onCompleteOrder() async {
    final cartState = context.read<CartBloc>().state;
    if (cartState.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cart is empty'),
          backgroundColor: AppTheme.warning,
        ),
      );
      return;
    }

    final authState = context.read<AuthBloc>().state;
    if (authState.user == null) return;

    try {
      final orderRepo = context.read<OrderRepository>();
      final order = await orderRepo.createOrder(
        staffId: authState.user!.uid,
        items: cartState.items,
      );

      // Clear cart
      if (mounted) {
        context.read<CartBloc>().add(const CartCleared());
      }

      // Show receipt dialog
      if (mounted) {
        showDialog(
          context: context,
          builder: (_) => ReceiptDialog(order: order),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create order: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWideScreen = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Point of Sale'),
        actions: [
          // Category filter chips for narrow screens
          if (!isWideScreen)
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: () => _showCategoryFilter(context),
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadMenuItems,
          ),
          // Logout button
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        context.read<AuthBloc>().add(
                          const AuthLogoutRequested(),
                        );
                      },
                      child: const Text(
                        'Logout',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : isWideScreen
          ? _buildWideLayout()
          : _buildNarrowLayout(),
      // Show cart FAB on narrow screens
      floatingActionButton: isWideScreen
          ? null
          : BlocBuilder<CartBloc, CartState>(
              builder: (context, state) {
                if (state.isEmpty) return const SizedBox.shrink();
                return FloatingActionButton.extended(
                  onPressed: () => _showCartSheet(context),
                  icon: const Icon(Icons.shopping_cart),
                  label: Text(
                    '${state.itemCount} items • ${_formatPrice(state.totalPrice)}',
                  ),
                );
              },
            ),
    );
  }

  Widget _buildWideLayout() {
    return Row(
      children: [
        // Menu section (2/3)
        Expanded(
          flex: 2,
          child: Column(
            children: [
              _buildCategoryTabs(),
              Expanded(
                child: MenuGrid(
                  items: _filteredItems,
                  onItemTap: (item) {
                    context.read<CartBloc>().add(CartItemAdded(item));
                  },
                ),
              ),
            ],
          ),
        ),
        // Divider
        const VerticalDivider(width: 1),
        // Cart section (1/3)
        SizedBox(
          width: 350,
          child: CartPanel(onCompleteOrder: _onCompleteOrder),
        ),
      ],
    );
  }

  Widget _buildNarrowLayout() {
    return Column(
      children: [
        _buildCategoryTabs(),
        Expanded(
          child: MenuGrid(
            items: _filteredItems,
            onItemTap: (item) {
              context.read<CartBloc>().add(CartItemAdded(item));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Added ${item.name} to cart'),
                  duration: const Duration(seconds: 1),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryTabs() {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border(bottom: BorderSide(color: AppTheme.border)),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: MenuCategory.values.length,
        itemBuilder: (context, index) {
          final category = MenuCategory.values[index];
          final isSelected = category == _selectedCategory;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: FilterChip(
              selected: isSelected,
              label: Text('${category.emoji} ${category.label}'),
              onSelected: (_) {
                setState(() => _selectedCategory = category);
              },
              backgroundColor: AppTheme.surfaceLight,
              selectedColor: AppTheme.primary,
              labelStyle: TextStyle(
                color: isSelected ? Colors.black : AppTheme.textPrimary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          );
        },
      ),
    );
  }

  void _showCategoryFilter(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filter by Category',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: MenuCategory.values.map((category) {
                return FilterChip(
                  selected: category == _selectedCategory,
                  label: Text('${category.emoji} ${category.label}'),
                  onSelected: (_) {
                    setState(() => _selectedCategory = category);
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showCartSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        expand: false,
        builder: (context, scrollController) => CartPanel(
          scrollController: scrollController,
          onCompleteOrder: () {
            Navigator.pop(context);
            _onCompleteOrder();
          },
        ),
      ),
    );
  }

  String _formatPrice(double price) {
    final formatter = NumberFormat('#,###', 'en');
    return '${formatter.format(price.toInt())} IQD';
  }
}
