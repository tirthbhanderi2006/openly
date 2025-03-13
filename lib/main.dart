import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_remix/flutter_remix.dart';
import 'package:get/get_core/get_core.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mithc_koko_chat_app/pages/home_page.dart';
import 'package:mithc_koko_chat_app/pages/splash_screen.dart';
import 'package:mithc_koko_chat_app/services/network/network_despondency.dart';
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

  await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);

  FlutterError.onError = (errorDetails) {
    if (errorDetails.exception.toString().contains("A RenderFlex overflowed")) {
      // Ignore the error and prevent crash notification
      return;
    }
    // Ensure UI updates are done safely
    SchedulerBinding.instance.addPostFrameCallback((_) {
      Get.snackbar(
        "App crash",
        "Error: ${errorDetails.exceptionAsString()}",
        colorText: Colors.red,
        backgroundColor: Colors.black,
        icon: Icon(FlutterRemix.error_warning_line, color: Colors.red),
      );
    });
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    });
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
        title: 'Openly',
        debugShowCheckedModeBanner: false,
        theme: Provider.of<ThemeProvider>(context).getThemeWithFont(),
        home: SplashScreen(),
        routes: {'home_page': (context) => const HomePage()});
  }
}
