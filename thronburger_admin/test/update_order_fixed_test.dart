import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:thronburger_admin/firebase_options.dart';

void main() {
  testWidgets('Update pending order status to preparing', (
    WidgetTester tester,
  ) async {
    // Correctly initialize binding for widget testing
    TestWidgetsFlutterBinding.ensureInitialized();

    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    final firestore = FirebaseFirestore.instance;

    // Target the specific order ID
    final orderId = 'l2KS5oNu77cGMAqTV3yo';
    print('Updating order $orderId to preparing...');

    try {
      await firestore.collection('orders').doc(orderId).update({
        'status': 'preparing',
      });
      print('SUCCESS: Order status updated to preparing');
    } catch (e) {
      print('ERROR updating order: $e');
    }
  });
}
