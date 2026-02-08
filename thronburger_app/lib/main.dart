import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'firebase_options.dart';
import 'l10n/app_localizations.dart';
import 'blocs/customer_cart/customer_cart_bloc.dart';
import 'blocs/customer_auth/customer_auth_bloc.dart';
import 'blocs/locale/locale_bloc.dart';
import 'config/router.dart';
import 'config/theme.dart';
import 'repositories/repositories.dart';
import 'services/notification_service.dart';

void main() async {
  await runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Initialize Firebase
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

    // Initialize Crashlytics (only in release mode)
    if (!kDebugMode) {
      FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    }

    // Initialize Notifications
    await NotificationService().initialize();

    runApp(const ThronburgerApp());
  }, (error, stack) {
    // Catch errors outside of Flutter framework
    if (!kDebugMode) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    }
  });
}

class ThronburgerApp extends StatelessWidget {
  const ThronburgerApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Create Firebase instances
    final firebaseAuth = FirebaseAuth.instance;
    final firestore = FirebaseFirestore.instance;
    final storage = FirebaseStorage.instance;

    // Create repositories (customer-only app)
    final menuRepository = MenuRepository(firestore, storage);
    final orderRepository = OrderRepository(firestore);
    final customerRepository = CustomerRepository(firebaseAuth, firestore);

    // Create CustomerAuthBloc
    final customerAuthBloc = CustomerAuthBloc(
      customerRepository: customerRepository,
    );

    // Create LocaleBloc
    final localeBloc = LocaleBloc()..add(const LocaleLoaded());

    // Create router
    final appRouter = AppRouter();

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: menuRepository),
        RepositoryProvider.value(value: orderRepository),
        RepositoryProvider.value(value: customerRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider.value(value: customerAuthBloc),
          BlocProvider.value(value: localeBloc),
          BlocProvider(create: (_) => CustomerCartBloc()),
        ],
        child: BlocBuilder<LocaleBloc, LocaleState>(
          builder: (context, localeState) {
            return MaterialApp.router(
              title: 'Thronburger',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.darkTheme,
              routerConfig: appRouter.router,
              locale: localeState.locale,
              supportedLocales: LocaleBloc.supportedLocales,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
            );
          },
        ),
      ),
    );
  }
}
