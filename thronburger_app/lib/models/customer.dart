import 'package:equatable/equatable.dart';
import 'address.dart';

/// Customer Model
/// Represents a customer who orders via mobile app
class Customer extends Equatable {
  final String id;
  final String phone;
  final String? name;
  final String? email;
  final List<Address> addresses;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Customer({
    required this.id,
    required this.phone,
    this.name,
    this.email,
    this.addresses = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  /// Get default address
  Address? get defaultAddress {
    try {
      return addresses.firstWhere((a) => a.isDefault);
    } catch (_) {
      return addresses.isNotEmpty ? addresses.first : null;
    }
  }

  /// Display name (phone if no name)
  String get displayName => name ?? phone;

  /// Parse a date value that could be a String, Firestore Timestamp, or null
  static DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is String) return DateTime.parse(value);
    // Handle Firestore Timestamp objects without importing cloud_firestore
    try {
      return (value as dynamic).toDate();
    } catch (_) {
      return DateTime.now();
    }
  }

  factory Customer.fromJson(Map<String, dynamic> json) {
    // Supabase returns 'customer_addresses' for the table join
    final addressList =
        json['customer_addresses'] as List<dynamic>? ??
        json['addresses'] as List<dynamic>?;
    return Customer(
      id: (json['id'] as String?) ?? '',
      phone: (json['phone'] as String?) ?? '',
      name: json['name'] as String?,
      email: json['email'] as String?,
      addresses: addressList != null
          ? addressList
                .map((a) => Address.fromJson(a as Map<String, dynamic>))
                .toList()
          : [],
      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at']),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone': phone,
      'name': name,
      'email': email,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Copy with
  Customer copyWith({
    String? id,
    String? phone,
    String? name,
    String? email,
    List<Address>? addresses,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Customer(
      id: id ?? this.id,
      phone: phone ?? this.phone,
      name: name ?? this.name,
      email: email ?? this.email,
      addresses: addresses ?? this.addresses,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    phone,
    name,
    email,
    addresses,
    createdAt,
    updatedAt,
  ];
}
