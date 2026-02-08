import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/models.dart';

/// Menu Repository
/// Handles menu item CRUD operations
class MenuRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  MenuRepository(this._firestore, this._storage);

  /// Get all menu items
  Future<List<MenuItem>> getMenuItems({bool onlyAvailable = false}) async {
    Query query = _firestore.collection('menu_items');

    if (onlyAvailable) {
      query = query.where('is_available', isEqualTo: true);
    }

    final snapshot = await query.orderBy('category').orderBy('name').get();

    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final createdAt = data['created_at'];
      final updatedAt = data['updated_at'];

      return MenuItem.fromJson({
        ...data,
        'id': doc.id,
        'created_at': createdAt is Timestamp
            ? createdAt.toDate().toIso8601String()
            : createdAt?.toString() ?? DateTime.now().toIso8601String(),
        'updated_at': updatedAt is Timestamp
            ? updatedAt.toDate().toIso8601String()
            : updatedAt?.toString() ?? DateTime.now().toIso8601String(),
      });
    }).toList();
  }

  /// Get menu items by category
  Future<List<MenuItem>> getMenuItemsByCategory(String category) async {
    final snapshot = await _firestore
        .collection('menu_items')
        .where('category', isEqualTo: category)
        .where('is_available', isEqualTo: true)
        .orderBy('name')
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      final createdAt = data['created_at'];
      final updatedAt = data['updated_at'];

      return MenuItem.fromJson({
        ...data,
        'id': doc.id,
        'created_at': createdAt is Timestamp
            ? createdAt.toDate().toIso8601String()
            : createdAt?.toString() ?? DateTime.now().toIso8601String(),
        'updated_at': updatedAt is Timestamp
            ? updatedAt.toDate().toIso8601String()
            : updatedAt?.toString() ?? DateTime.now().toIso8601String(),
      });
    }).toList();
  }

  /// Get single menu item by ID
  Future<MenuItem?> getMenuItem(String id) async {
    final doc = await _firestore.collection('menu_items').doc(id).get();

    if (!doc.exists) return null;

    final data = doc.data()!;
    final createdAt = data['created_at'];
    final updatedAt = data['updated_at'];

    return MenuItem.fromJson({
      ...data,
      'id': doc.id,
      'created_at': createdAt is Timestamp
          ? createdAt.toDate().toIso8601String()
          : createdAt?.toString() ?? DateTime.now().toIso8601String(),
      'updated_at': updatedAt is Timestamp
          ? updatedAt.toDate().toIso8601String()
          : updatedAt?.toString() ?? DateTime.now().toIso8601String(),
    });
  }

  /// Create menu item
  Future<MenuItem> createMenuItem(MenuItem item) async {
    final docRef = await _firestore.collection('menu_items').add({
      'name': item.name,
      'name_ku': item.nameKu,
      'name_ar': item.nameAr,
      'price': item.price,
      'category': item.category,
      'image_url': item.imageUrl,
      'is_available': item.isAvailable,
      'created_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    });

    final doc = await docRef.get();
    return MenuItem.fromJson({...doc.data()!, 'id': doc.id});
  }

  /// Update menu item
  Future<MenuItem> updateMenuItem(MenuItem item) async {
    await _firestore.collection('menu_items').doc(item.id).update({
      'name': item.name,
      'name_ku': item.nameKu,
      'name_ar': item.nameAr,
      'price': item.price,
      'category': item.category,
      'image_url': item.imageUrl,
      'is_available': item.isAvailable,
      'updated_at': FieldValue.serverTimestamp(),
    });

    return (await getMenuItem(item.id))!;
  }

  /// Toggle menu item availability
  Future<MenuItem> toggleAvailability(String itemId, bool isAvailable) async {
    await _firestore.collection('menu_items').doc(itemId).update({
      'is_available': isAvailable,
      'updated_at': FieldValue.serverTimestamp(),
    });

    return (await getMenuItem(itemId))!;
  }

  /// Delete menu item
  Future<void> deleteMenuItem(String id) async {
    await _firestore.collection('menu_items').doc(id).delete();
  }

  /// Upload menu item image
  Future<String> uploadImage(String fileName, List<int> bytes) async {
    final path = 'menu-images/$fileName';
    final ref = _storage.ref().child(path);

    await ref.putData(
      bytes as dynamic,
      SettableMetadata(contentType: 'image/jpeg'),
    );

    return await ref.getDownloadURL();
  }

  /// Subscribe to menu changes (real-time)
  Stream<List<MenuItem>> subscribeToMenuChanges() {
    return _firestore
        .collection('menu_items')
        .orderBy('category')
        .orderBy('name')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => MenuItem.fromJson({...doc.data(), 'id': doc.id}))
              .toList(),
        );
  }
}
