import 'package:equatable/equatable.dart';

/// Address Model
/// Represents a delivery address for customers
class Address extends Equatable {
  final String id;
  final String customerId;
  final String label; // e.g., "Home", "Work", "Other"
  final String area;
  final String street;
  final String? building;
  final String? apartment;
  final String? landmark;
  final String? notes;
  final bool isDefault;
  final DateTime createdAt;

  const Address({
    required this.id,
    required this.customerId,
    required this.label,
    required this.area,
    required this.street,
    this.building,
    this.apartment,
    this.landmark,
    this.notes,
    this.isDefault = false,
    required this.createdAt,
  });

  /// Full address string
  String get fullAddress {
    final parts = <String>[area, street];
    if (building != null && building!.isNotEmpty) {
      parts.add('Bldg: $building');
    }
    if (apartment != null && apartment!.isNotEmpty) {
      parts.add('Apt: $apartment');
    }
    return parts.join(', ');
  }

  /// Create from JSON
  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'] as String,
      customerId: json['customer_id'] as String,
      label: json['label'] as String? ?? 'Home',
      area: json['area'] as String,
      street: json['street'] as String,
      building: json['building'] as String?,
      apartment: json['apartment'] as String?,
      landmark: json['landmark'] as String?,
      notes: json['notes'] as String?,
      isDefault: json['is_default'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_id': customerId,
      'label': label,
      'area': area,
      'street': street,
      'building': building,
      'apartment': apartment,
      'landmark': landmark,
      'notes': notes,
      'is_default': isDefault,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// For insert (without id and timestamps)
  Map<String, dynamic> toInsertJson() {
    return {
      'customer_id': customerId,
      'label': label,
      'area': area,
      'street': street,
      'building': building,
      'apartment': apartment,
      'landmark': landmark,
      'notes': notes,
      'is_default': isDefault,
    };
  }

  /// Copy with
  Address copyWith({
    String? id,
    String? customerId,
    String? label,
    String? area,
    String? street,
    String? building,
    String? apartment,
    String? landmark,
    String? notes,
    bool? isDefault,
    DateTime? createdAt,
  }) {
    return Address(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      label: label ?? this.label,
      area: area ?? this.area,
      street: street ?? this.street,
      building: building ?? this.building,
      apartment: apartment ?? this.apartment,
      landmark: landmark ?? this.landmark,
      notes: notes ?? this.notes,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    customerId,
    label,
    area,
    street,
    building,
    apartment,
    landmark,
    notes,
    isDefault,
    createdAt,
  ];
}
