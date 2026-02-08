import 'package:flutter_test/flutter_test.dart';
import 'package:thronburger_admin/models/models.dart';

void main() {
  group('Order Parsing', () {
    test('parses valid order json', () {
      final json = {
        'id': 'order_123',
        'order_number': 1001,
        'staff_id': 'staff_1',
        'customer_id': 'cust_1',
        'customer_name': 'John Doe',
        'customer_phone': '1234567890',
        'customer_location': 'Location A',
        'customer_address': 'Address 1',
        'notes': 'No onions',
        'order_type': 'dine_in',
        'status': 'pending',
        'total_amount': 5000.0,
        'created_at': '2023-10-27T10:00:00.000Z',
        'updated_at': '2023-10-27T10:00:00.000Z',
        'order_items': [
          {
            'id': 'item_1',
            'order_id': 'order_123',
            'menu_item_id': 'menu_1',
            'quantity': 2,
            'unit_price': 2500.0,
            'created_at': '2023-10-27T10:00:00.000Z',
            'menu_items': {
              'id': 'menu_1',
              'name': 'Burger',
              'price': 2500.0,
              'category': 'burgers',
              'created_at': '2023-10-27T10:00:00.000Z',
              'updated_at': '2023-10-27T10:00:00.000Z',
            },
          },
        ],
      };

      final order = Order.fromJson(json);
      expect(order.id, 'order_123');
      expect(order.items.length, 1);
      expect(order.items.first.menuItem?.name, 'Burger');
    });

    test('parses order with missing optional fields', () {
      final json = {
        'id': 'order_124',
        'order_number': 1002,
        'order_type': 'pickup',
        'status': 'ready',
        'total_amount': 2500.0,
        'created_at': '2023-10-27T11:00:00.000Z',
        'updated_at': '2023-10-27T11:00:00.000Z',
      };

      final order = Order.fromJson(json);
      expect(order.id, 'order_124');
      expect(order.items, isEmpty);
      expect(order.customerName, isNull);
    });

    test('parses order with minimal item data', () {
      final json = {
        'id': 'order_125',
        'order_number': 1003,
        'order_type': 'dine_in',
        'status': 'pending',
        'total_amount': 1000.0,
        'created_at': '2023-10-27T10:00:00.000Z',
        'updated_at': '2023-10-27T10:00:00.000Z',
        'order_items': [
          {
            'id': 'item_2',
            'order_id': 'order_125',
            'menu_item_id': 'menu_2',
            'quantity': 1,
            'unit_price': 1000.0,
            'created_at': '2023-10-27T10:00:00.000Z',
            // menu_items missing
          },
        ],
      };

      final order = Order.fromJson(json);
      expect(order.items.length, 1);
      expect(order.items.first.menuItem, isNull);
    });

    test('parses order with null menu_item name', () {
      final json = {
        'id': 'order_126',
        'order_number': 1004,
        'order_type': 'dine_in',
        'status': 'pending',
        'total_amount': 1000.0,
        'created_at': '2023-10-27T10:00:00.000Z',
        'updated_at': '2023-10-27T10:00:00.000Z',
        'order_items': [
          {
            'id': 'item_3',
            'order_id': 'order_126',
            'menu_item_id': 'menu_3',
            'quantity': 1,
            'unit_price': 1000.0,
            'created_at': '2023-10-27T10:00:00.000Z',
            'menu_items': {
              'id': 'menu_3',
              'name': 'Unknown', // Explicitly Unknown
              'price': 0,
              'category': 'unknown',
              'created_at': '2023-10-27T10:00:00.000Z',
              'updated_at': '2023-10-27T10:00:00.000Z',
            },
          },
        ],
      };

      final order = Order.fromJson(json);
      expect(order.items.length, 1);
      expect(order.items.first.menuItem?.name, 'Unknown');
    });
  });
}
