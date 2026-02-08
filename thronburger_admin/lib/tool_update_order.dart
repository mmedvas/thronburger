import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  print('Updating order l2KS5oNu77cGMAqTV3yo to preparing...');

  try {
    await FirebaseFirestore.instance
        .collection('orders')
        .doc('l2KS5oNu77cGMAqTV3yo')
        .update({'status': 'preparing'});
    print('SUCCESS: Order status updated to preparing');
  } catch (e) {
    print('ERROR: $e');
  }

  print('Exiting...');
  // Force exit since this will run as an app
  // output confirmation is enough for us to kill it
}
