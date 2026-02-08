import 'dart:ui';

import 'package:equatable/equatable.dart';

/// Menu Item Model
/// Represents a menu item with trilingual support
class MenuItem extends Equatable {
  final String id;
  final String name;
  final String? nameKu;
  final String? nameAr;
  final double price;
  final String category;
  final String? imageUrl;
  final bool isAvailable;
  final DateTime createdAt;
  final DateTime updatedAt;

  const MenuItem({
    required this.id,
    required this.name,
    this.nameKu,
    this.nameAr,
    required this.price,
    required this.category,
    this.imageUrl,
    this.isAvailable = true,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create MenuItem from JSON
  factory MenuItem.fromJson(Map<String, dynamic> json, {String? documentId}) {
    // Handle Firestore Timestamp or String for dates
    DateTime parseDateTime(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is String) {
        return DateTime.parse(value);
      } else if (value.toDate != null) {
        // Firestore Timestamp
        return value.toDate();
      }
      return DateTime.now();
    }

    return MenuItem(
      id: (json['id'] as String?) ?? documentId ?? '',
      name: (json['name'] as String?) ?? 'Unknown Item',
      nameKu: json['name_ku'] as String?,
      nameAr: json['name_ar'] as String?,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      category: (json['category'] as String?) ?? 'unknown',
      imageUrl: json['image_url'] as String?,
      isAvailable: json['is_available'] as bool? ?? true,
      createdAt: parseDateTime(json['created_at']),
      updatedAt: parseDateTime(json['updated_at']),
    );
  }

  /// Convert MenuItem to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'name_ku': nameKu,
      'name_ar': nameAr,
      'price': price,
      'category': category,
      'image_url': imageUrl,
      'is_available': isAvailable,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Create MenuItem for insert (without id and timestamps)
  Map<String, dynamic> toInsertJson() {
    return {
      'name': name,
      'name_ku': nameKu,
      'name_ar': nameAr,
      'price': price,
      'category': category,
      'image_url': imageUrl,
      'is_available': isAvailable,
    };
  }

  /// Copy with method
  MenuItem copyWith({
    String? id,
    String? name,
    String? nameKu,
    String? nameAr,
    double? price,
    String? category,
    String? imageUrl,
    bool? isAvailable,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MenuItem(
      id: id ?? this.id,
      name: name ?? this.name,
      nameKu: nameKu ?? this.nameKu,
      nameAr: nameAr ?? this.nameAr,
      price: price ?? this.price,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      isAvailable: isAvailable ?? this.isAvailable,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Get localized name based on locale
  String getLocalizedName(Locale locale) {
    switch (locale.languageCode) {
      case 'ar':
        return nameAr ?? name;
      case 'ku':
        return nameKu ?? name;
      default:
        return name;
    }
  }

  @override
  List<Object?> get props => [
    id,
    name,
    nameKu,
    nameAr,
    price,
    category,
    imageUrl,
    isAvailable,
    createdAt,
    updatedAt,
  ];
}

/// Menu Categories
enum MenuCategory {
  all('all', 'All', '🍽️'),
  burgers('burgers', 'Burgers', '🍔'),
  sides('sides', 'Sides', '🍟'),
  drinks('drinks', 'Drinks', '🥤'),
  combos('combos', 'Combos', '🎁');

  final String value;
  final String label;
  final String emoji;

  const MenuCategory(this.value, this.label, this.emoji);

  static MenuCategory fromString(String value) {
    return MenuCategory.values.firstWhere(
      (e) => e.value == value,
      orElse: () => MenuCategory.all,
    );
  }
}
