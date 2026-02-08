import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import '../../config/theme.dart';
import '../../models/models.dart';
import '../../repositories/repositories.dart';

/// Menu Admin Screen
/// CRUD operations for menu items (Admin only)
class MenuAdminScreen extends StatefulWidget {
  const MenuAdminScreen({super.key});

  @override
  State<MenuAdminScreen> createState() => _MenuAdminScreenState();
}

class _MenuAdminScreenState extends State<MenuAdminScreen> {
  List<MenuItem> _menuItems = [];
  bool _isLoading = true;
  MenuCategory _selectedCategory = MenuCategory.all;

  @override
  void initState() {
    super.initState();
    _loadMenuItems();
  }

  Future<void> _loadMenuItems() async {
    setState(() => _isLoading = true);
    try {
      final menuRepo = context.read<MenuRepository>();
      final items = await menuRepo.getMenuItems();
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
    if (_selectedCategory == MenuCategory.all) return _menuItems;
    return _menuItems
        .where((item) => item.category == _selectedCategory.value)
        .toList();
  }

  Future<void> _toggleAvailability(MenuItem item) async {
    try {
      final menuRepo = context.read<MenuRepository>();
      await menuRepo.toggleAvailability(item.id, !item.isAvailable);
      _loadMenuItems();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update item: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  Future<void> _deleteItem(MenuItem item) async {
    final menuRepo = context.read<MenuRepository>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item'),
        content: Text('Are you sure you want to delete "${item.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await menuRepo.deleteMenuItem(item.id);
        _loadMenuItems();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Item deleted'),
              backgroundColor: AppTheme.success,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete item: $e'),
              backgroundColor: AppTheme.error,
            ),
          );
        }
      }
    }
  }

  void _showItemForm({MenuItem? item}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _MenuItemForm(
        item: item,
        onSaved: () {
          Navigator.pop(context);
          _loadMenuItems();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,###', 'en');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadMenuItems,
          ),
        ],
      ),
      body: Column(
        children: [
          // Category filter
          Container(
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 8,
                  ),
                  child: FilterChip(
                    selected: isSelected,
                    label: Text('${category.emoji} ${category.label}'),
                    onSelected: (_) {
                      setState(() => _selectedCategory = category);
                    },
                  ),
                );
              },
            ),
          ),
          // Items list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredItems.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = _filteredItems[index];
                      return _MenuItemTile(
                        item: item,
                        priceFormatted:
                            '${formatter.format(item.price.toInt())} IQD',
                        onEdit: () => _showItemForm(item: item),
                        onDelete: () => _deleteItem(item),
                        onToggleAvailability: () => _toggleAvailability(item),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showItemForm(),
        icon: const Icon(Icons.add),
        label: const Text('Add Item'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.restaurant_menu, size: 64, color: AppTheme.textMuted),
          const SizedBox(height: 16),
          Text(
            'No menu items',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 16),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () => _showItemForm(),
            icon: const Icon(Icons.add),
            label: const Text('Add First Item'),
          ),
        ],
      ),
    );
  }
}

class _MenuItemTile extends StatelessWidget {
  final MenuItem item;
  final String priceFormatted;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleAvailability;

  const _MenuItemTile({
    required this.item,
    required this.priceFormatted,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleAvailability,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            width: 60,
            height: 60,
            child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: item.imageUrl!,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => _buildPlaceholder(),
                    errorWidget: (context, url, error) => _buildPlaceholder(),
                  )
                : _buildPlaceholder(),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                item.name,
                style: TextStyle(
                  color: item.isAvailable
                      ? AppTheme.textPrimary
                      : AppTheme.textMuted,
                  decoration: item.isAvailable
                      ? null
                      : TextDecoration.lineThrough,
                ),
              ),
            ),
            Switch(
              value: item.isAvailable,
              onChanged: (_) => onToggleAvailability(),
              activeTrackColor: AppTheme.success,
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              priceFormatted,
              style: TextStyle(
                color: AppTheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.surfaceLight,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                item.category,
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'edit', child: Text('Edit')),
            const PopupMenuItem(
              value: 'delete',
              child: Text('Delete', style: TextStyle(color: AppTheme.error)),
            ),
          ],
          onSelected: (value) {
            if (value == 'edit') onEdit();
            if (value == 'delete') onDelete();
          },
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppTheme.surfaceLight,
      child: Icon(Icons.fastfood, color: AppTheme.textMuted),
    );
  }
}

class _MenuItemForm extends StatefulWidget {
  final MenuItem? item;
  final VoidCallback onSaved;

  const _MenuItemForm({this.item, required this.onSaved});

  @override
  State<_MenuItemForm> createState() => _MenuItemFormState();
}

class _MenuItemFormState extends State<_MenuItemForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _nameKuController;
  late TextEditingController _nameArController;
  late TextEditingController _priceController;
  String _category = 'burgers';
  bool _isAvailable = true;
  bool _isSaving = false;
  bool _isUploading = false;

  // Image handling
  String? _imageUrl;
  Uint8List? _selectedImageBytes;
  String? _selectedImageName;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item?.name);
    _nameKuController = TextEditingController(text: widget.item?.nameKu);
    _nameArController = TextEditingController(text: widget.item?.nameAr);
    _priceController = TextEditingController(
      text: widget.item?.price.toInt().toString(),
    );
    _imageUrl = widget.item?.imageUrl;
    _category = widget.item?.category ?? 'burgers';
    _isAvailable = widget.item?.isAvailable ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameKuController.dispose();
    _nameArController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.bytes != null) {
          setState(() {
            _selectedImageBytes = file.bytes;
            _selectedImageName = file.name;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  Future<String?> _uploadImage() async {
    if (_selectedImageBytes == null || _selectedImageName == null) {
      return _imageUrl;
    }

    setState(() => _isUploading = true);

    try {
      final menuRepo = context.read<MenuRepository>();
      // Generate unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = _selectedImageName!.split('.').last;
      final fileName = 'menu_$timestamp.$extension';

      final url = await menuRepo.uploadImage(
        fileName,
        _selectedImageBytes!.toList(),
      );
      return url;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload image: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
      return null;
    } finally {
      setState(() => _isUploading = false);
    }
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSaving = true);

    try {
      // Upload image if a new one was selected
      String? finalImageUrl = _imageUrl;
      if (_selectedImageBytes != null) {
        finalImageUrl = await _uploadImage();
        if (finalImageUrl == null && _selectedImageBytes != null) {
          // Upload failed, stop saving
          setState(() => _isSaving = false);
          return;
        }
      }

      final menuRepo = context.read<MenuRepository>();
      final item = MenuItem(
        id: widget.item?.id ?? '',
        name: _nameController.text.trim(),
        nameKu: _nameKuController.text.trim().isEmpty
            ? null
            : _nameKuController.text.trim(),
        nameAr: _nameArController.text.trim().isEmpty
            ? null
            : _nameArController.text.trim(),
        price: double.parse(_priceController.text),
        category: _category,
        imageUrl: finalImageUrl,
        isAvailable: _isAvailable,
        createdAt: widget.item?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (widget.item == null) {
        await menuRepo.createMenuItem(item);
      } else {
        await menuRepo.updateMenuItem(item);
      }

      widget.onSaved();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Widget _buildImagePreview() {
    if (_isUploading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 8),
            Text('Uploading...'),
          ],
        ),
      );
    }

    // Show selected image (not yet uploaded)
    if (_selectedImageBytes != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.memory(_selectedImageBytes!, fit: BoxFit.cover),
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.info,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'New',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Show existing image from URL
    if (_imageUrl != null && _imageUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: CachedNetworkImage(
          imageUrl: _imageUrl!,
          fit: BoxFit.cover,
          placeholder: (context, url) =>
              const Center(child: CircularProgressIndicator()),
          errorWidget: (context, url, error) => _buildEmptyImageState(),
        ),
      );
    }

    // No image
    return _buildEmptyImageState();
  }

  Widget _buildEmptyImageState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_photo_alternate_outlined,
            size: 48,
            color: AppTheme.textMuted,
          ),
          const SizedBox(height: 8),
          Text(
            'Tap to add photo',
            style: TextStyle(color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      expand: false,
      builder: (context, scrollController) => Container(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: ListView(
            controller: scrollController,
            children: [
              // Header
              Row(
                children: [
                  Text(
                    widget.item == null ? 'Add Menu Item' : 'Edit Menu Item',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Name (English)
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name (English) *',
                  hintText: 'Enter item name',
                ),
                validator: (v) =>
                    v?.isEmpty ?? true ? 'Name is required' : null,
              ),
              const SizedBox(height: 16),

              // Name (Kurdish)
              TextFormField(
                controller: _nameKuController,
                decoration: const InputDecoration(
                  labelText: 'Name (Kurdish)',
                  hintText: 'ناوی کوردی',
                ),
                textDirection: TextDirection.rtl,
              ),
              const SizedBox(height: 16),

              // Name (Arabic)
              TextFormField(
                controller: _nameArController,
                decoration: const InputDecoration(
                  labelText: 'Name (Arabic)',
                  hintText: 'الاسم بالعربية',
                ),
                textDirection: TextDirection.rtl,
              ),
              const SizedBox(height: 16),

              // Price
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Price (IQD) *',
                  hintText: 'Enter price',
                  suffixText: 'IQD',
                ),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v?.isEmpty ?? true) return 'Price is required';
                  if (double.tryParse(v!) == null) return 'Invalid price';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Category
              DropdownButtonFormField<String>(
                initialValue: _category,
                decoration: const InputDecoration(labelText: 'Category *'),
                items: MenuCategory.values
                    .where((c) => c != MenuCategory.all)
                    .map(
                      (c) => DropdownMenuItem(
                        value: c.value,
                        child: Text('${c.emoji} ${c.label}'),
                      ),
                    )
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _category = v);
                },
              ),
              const SizedBox(height: 16),

              // Image Upload
              const Text(
                'Item Photo',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: AppTheme.surfaceLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.border),
                ),
                child: InkWell(
                  onTap: _isUploading ? null : _pickImage,
                  borderRadius: BorderRadius.circular(12),
                  child: _buildImagePreview(),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _isUploading ? null : _pickImage,
                      icon: const Icon(Icons.photo_library),
                      label: Text(
                        _selectedImageBytes != null ||
                                (_imageUrl != null && _imageUrl!.isNotEmpty)
                            ? 'Change Photo'
                            : 'Select Photo',
                      ),
                    ),
                  ),
                  if (_selectedImageBytes != null ||
                      (_imageUrl != null && _imageUrl!.isNotEmpty)) ...[
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: _isUploading
                          ? null
                          : () {
                              setState(() {
                                _selectedImageBytes = null;
                                _selectedImageName = null;
                                _imageUrl = null;
                              });
                            },
                      icon: const Icon(Icons.delete_outline),
                      color: AppTheme.error,
                      tooltip: 'Remove photo',
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 16),

              // Availability
              SwitchListTile(
                title: const Text('Available'),
                subtitle: Text(
                  _isAvailable
                      ? 'Item is visible to customers'
                      : 'Item is hidden from menu',
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
                value: _isAvailable,
                onChanged: (v) => setState(() => _isAvailable = v),
                activeTrackColor: AppTheme.success,
              ),
              const SizedBox(height: 32),

              // Save button
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _save,
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(widget.item == null ? 'Add Item' : 'Save Changes'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
