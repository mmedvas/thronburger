import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../l10n/app_localizations.dart';
import '../../config/theme.dart';
import '../../models/models.dart';
import '../../repositories/repositories.dart';
import '../../blocs/customer_cart/customer_cart_bloc.dart';
import '../../blocs/locale/locale_bloc.dart';

/// Menu Browse Screen
/// Full menu with category filtering and search
class MenuBrowseScreen extends StatefulWidget {
  final String? initialCategory;

  const MenuBrowseScreen({super.key, this.initialCategory});

  @override
  State<MenuBrowseScreen> createState() => _MenuBrowseScreenState();
}

class _MenuBrowseScreenState extends State<MenuBrowseScreen> {
  List<MenuItem> _allItems = [];
  List<MenuItem> _filteredItems = [];
  MenuCategory? _selectedCategory;
  String _searchQuery = '';
  bool _isLoading = true;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialCategory != null) {
      _selectedCategory = MenuCategory.values.firstWhere(
        (c) => c.value == widget.initialCategory,
        orElse: () => MenuCategory.burgers,
      );
    }
    _loadMenu();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadMenu() async {
    try {
      final menuRepo = context.read<MenuRepository>();
      final items = await menuRepo.getMenuItems();

      setState(() {
        _allItems = items.where((i) => i.isAvailable).toList();
        _applyFilters();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _applyFilters() {
    var items = _allItems;

    // Category filter
    if (_selectedCategory != null) {
      items = items
          .where((i) => i.category == _selectedCategory!.value)
          .toList();
    }

    // Search filter
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      items = items
          .where(
            (i) =>
                i.name.toLowerCase().contains(query) ||
                (i.nameKu?.toLowerCase().contains(query) ?? false) ||
                (i.nameAr?.toLowerCase().contains(query) ?? false),
          )
          .toList();
    }

    _filteredItems = items;
  }

  String _getCategoryLabel(BuildContext context, MenuCategory? category) {
    final l10n = AppLocalizations.of(context);
    if (category == null) return l10n.allCategories;
    switch (category) {
      case MenuCategory.all:
        return l10n.allCategories;
      case MenuCategory.burgers:
        return l10n.burgers;
      case MenuCategory.sides:
        return l10n.sides;
      case MenuCategory.drinks:
        return l10n.drinks;
      case MenuCategory.combos:
        return l10n.combos;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = context.watch<LocaleBloc>().state.locale;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.menu),
        backgroundColor: AppTheme.background,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '${l10n.menu}...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                            _applyFilters();
                          });
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                  _applyFilters();
                });
              },
            ),
          ),

          // Category Chips
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: FilterChip(
                    label: Text(_getCategoryLabel(context, null)),
                    selected: _selectedCategory == null,
                    onSelected: (_) {
                      setState(() {
                        _selectedCategory = null;
                        _applyFilters();
                      });
                    },
                    selectedColor: AppTheme.primary,
                    checkmarkColor: Colors.black,
                  ),
                ),
                ...MenuCategory.values.where((c) => c != MenuCategory.all).map((
                  category,
                ) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: FilterChip(
                      label: Text(_getCategoryLabel(context, category)),
                      selected: _selectedCategory == category,
                      onSelected: (_) {
                        setState(() {
                          _selectedCategory = category;
                          _applyFilters();
                        });
                      },
                      selectedColor: AppTheme.primary,
                      checkmarkColor: Colors.black,
                    ),
                  );
                }),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Menu Items
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredItems.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: AppTheme.textSecondary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No items found',
                          style: TextStyle(color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = _filteredItems[index];
                      return _MenuListItem(item: item, locale: locale);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _MenuListItem extends StatelessWidget {
  final MenuItem item;
  final Locale locale;

  const _MenuListItem({required this.item, required this.locale});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showItemDetail(context),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Image
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: item.imageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: item.imageUrl!,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => _placeholder(),
                        errorWidget: (context, url, error) => _placeholder(),
                      )
                    : _placeholder(),
              ),
              const SizedBox(width: 16),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.getLocalizedName(locale),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    // Show secondary name if different from localized name
                    if (locale.languageCode != 'en' &&
                        item.name != item.getLocalizedName(locale)) ...[
                      const SizedBox(height: 4),
                      Text(
                        item.name,
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 8),
                    Text(
                      '${item.price.toStringAsFixed(0)} IQD',
                      style: const TextStyle(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              // Add Button
              IconButton(
                onPressed: () {
                  final router = GoRouter.of(context);
                  final l10n = AppLocalizations.of(context);
                  context.read<CustomerCartBloc>().add(
                    CustomerCartItemAdded(menuItem: item),
                  );
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.itemAdded),
                      duration: const Duration(seconds: 3),
                      behavior: SnackBarBehavior.floating,
                      margin: const EdgeInsets.only(
                        bottom: 80,
                        left: 16,
                        right: 16,
                      ),
                      action: SnackBarAction(
                        label: l10n.viewCart,
                        onPressed: () => router.go('/customer/cart'),
                      ),
                    ),
                  );
                },
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.add, color: Colors.black, size: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      width: 80,
      height: 80,
      color: AppTheme.surface,
      child: const Icon(Icons.lunch_dining, color: AppTheme.primary),
    );
  }

  void _showItemDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _ItemDetailSheet(item: item, locale: locale),
    );
  }
}

class _ItemDetailSheet extends StatefulWidget {
  final MenuItem item;
  final Locale locale;

  const _ItemDetailSheet({required this.item, required this.locale});

  @override
  State<_ItemDetailSheet> createState() => _ItemDetailSheetState();
}

class _ItemDetailSheetState extends State<_ItemDetailSheet> {
  int _quantity = 1;
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final localizedName = widget.item.getLocalizedName(widget.locale);

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.85,
      expand: false,
      builder: (context, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.textSecondary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Name & Price
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      localizedName,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Text(
                    l10n.priceFormat(widget.item.price.toStringAsFixed(0)),
                    style: const TextStyle(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Show English name as secondary if not English
              if (widget.locale.languageCode != 'en' &&
                  widget.item.name != localizedName)
                Text(
                  widget.item.name,
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
              const SizedBox(height: 20),

              // Notes
              TextField(
                controller: _notesController,
                decoration: InputDecoration(
                  labelText: l10n.itemNotes,
                  hintText: l10n.itemNotesHint,
                ),
              ),
              const SizedBox(height: 24),

              // Quantity
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton.filled(
                    onPressed: _quantity > 1
                        ? () => setState(() => _quantity--)
                        : null,
                    icon: const Icon(Icons.remove),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      '$_quantity',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton.filled(
                    onPressed: () => setState(() => _quantity++),
                    icon: const Icon(Icons.add),
                    style: IconButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Add Button
              ElevatedButton(
                onPressed: () {
                  final router = GoRouter.of(context);
                  final scaffoldMessenger = ScaffoldMessenger.of(context);
                  context.read<CustomerCartBloc>().add(
                    CustomerCartItemAdded(
                      menuItem: widget.item,
                      quantity: _quantity,
                      notes: _notesController.text.isNotEmpty
                          ? _notesController.text
                          : null,
                    ),
                  );
                  Navigator.pop(context);
                  scaffoldMessenger.hideCurrentSnackBar();
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text(l10n.itemAdded),
                      duration: const Duration(seconds: 3),
                      behavior: SnackBarBehavior.floating,
                      margin: const EdgeInsets.only(
                        bottom: 80,
                        left: 16,
                        right: 16,
                      ),
                      action: SnackBarAction(
                        label: l10n.viewCart,
                        onPressed: () => router.go('/customer/cart'),
                      ),
                    ),
                  );
                },
                child: Text(
                  '${l10n.addToCart} • ${l10n.priceFormat((widget.item.price * _quantity).toStringAsFixed(0))}',
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
