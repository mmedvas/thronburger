import 'package:equatable/equatable.dart';

/// Staff Role Enum
enum AppRole {
  admin('admin', 'Admin'),
  cashier('cashier', 'Cashier');

  final String value;
  final String label;

  const AppRole(this.value, this.label);

  static AppRole fromString(String value) {
    return AppRole.values.firstWhere(
      (e) => e.value == value,
      orElse: () => AppRole.cashier,
    );
  }
}

/// User Profile Model
/// Represents a staff user with their role
class UserProfile extends Equatable {
  final String id;
  final String? fullName;
  final AppRole role;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserProfile({
    required this.id,
    this.fullName,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Check if user is admin
  bool get isAdmin => role == AppRole.admin;

  /// Check if user is cashier
  bool get isCashier => role == AppRole.cashier;

  /// Create UserProfile from JSON
  factory UserProfile.fromJson(
    Map<String, dynamic> json, {
    String? roleValue,
    String? documentId,
  }) {
    // Handle Firestore Timestamp or String for dates
    DateTime parseDateTime(dynamic value) {
      if (value is String) {
        return DateTime.parse(value);
      } else if (value != null && value.toDate != null) {
        // Firestore Timestamp
        return value.toDate();
      }
      return DateTime.now();
    }

    return UserProfile(
      id: (json['id'] as String?) ?? documentId ?? '',
      fullName: json['full_name'] as String?,
      role: roleValue != null ? AppRole.fromString(roleValue) : AppRole.cashier,
      createdAt: parseDateTime(json['created_at']),
      updatedAt: parseDateTime(json['updated_at']),
    );
  }

  /// Convert UserProfile to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Copy with method
  UserProfile copyWith({
    String? id,
    String? fullName,
    AppRole? role,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [id, fullName, role, createdAt, updatedAt];
}
