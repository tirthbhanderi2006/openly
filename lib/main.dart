import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_remix/flutter_remix.dart';
import 'package:get/get_core/get_core.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mithc_koko_chat_app/pages/home_page.dart';
import 'package:mithc_koko_chat_app/pages/splash_screen.dart';
import 'package:mithc_koko_chat_app/services/network/network_despondency.dart';
import 'package:mithc_koko_chat_app/services/notification_services/local_notification_services.dart';
import 'package:mithc_koko_chat_app/services/notification_services/notification_services.dart';
import 'package:mithc_koko_chat_app/utils/themes/theme_provider.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();
final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  DependencyInjection.init();

  await GetStorage.init();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseNotificationServices().initNotification();
  NotificationService().init();

  await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);

  // Pass all uncaught "fatal" errors from the framework to Crashlytics
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  FlutterError.onError = (errordetails) {
    Get.snackbar("App crash",
        "error is crshed due to ${errordetails.exceptionAsString()}",
        colorText: Colors.red,
        backgroundColor: Colors.black,
        icon: Icon(
          FlutterRemix.error_warning_line,
          color: Colors.red,
        ));
  };
  // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  runApp(ChangeNotifierProvider(
    create: (context) => ThemeProvider(),
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
        navigatorObservers: [routeObserver],
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        theme: Provider.of<ThemeProvider>(context).themeData,
        // home: AuthGate(),
        home: SplashScreen(),
        routes: {'home_page': (context) => const HomePage()});
  }
}
