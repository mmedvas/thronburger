import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'firebase_options.dart';
import 'blocs/auth/auth_bloc.dart';
import 'blocs/cart/cart_bloc.dart';
import 'config/router.dart';
import 'config/theme.dart';
import 'repositories/repositories.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const ThronburgerAdminApp());
}

class ThronburgerAdminApp extends StatelessWidget {
  const ThronburgerAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Create Firebase instances
    final firebaseAuth = FirebaseAuth.instance;
    final firestore = FirebaseFirestore.instance;
    final storage = FirebaseStorage.instance;

    // Create repositories
    final authRepository = AuthRepository(firebaseAuth, firestore);
    final menuRepository = MenuRepository(firestore, storage);
    final orderRepository = OrderRepository(firestore);

    // Create AuthBloc
    final authBloc = AuthBloc(authRepository: authRepository);

    // Create router
    final appRouter = AppRouter(authBloc: authBloc);

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: authRepository),
        RepositoryProvider.value(value: menuRepository),
        RepositoryProvider.value(value: orderRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider.value(value: authBloc),
          BlocProvider(create: (_) => CartBloc()),
        ],
        child: MaterialApp.router(
          title: 'Thronburger Admin',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.darkTheme,
          routerConfig: appRouter.router,
        ),
      ),
    );
  }
}
