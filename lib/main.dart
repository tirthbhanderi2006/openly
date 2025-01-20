import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:mithc_koko_chat_app/auth/auth_gate.dart';
import 'package:mithc_koko_chat_app/pages/home_page.dart';
import 'package:mithc_koko_chat_app/pages/splash_screen.dart';
import 'package:mithc_koko_chat_app/services/local_notification_services.dart';
import 'package:mithc_koko_chat_app/services/notification_services.dart';
import 'package:mithc_koko_chat_app/themes/theme_provider.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';




final navigatorKey=GlobalKey<NavigatorState>();
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseNotificationServices().initNotification();
  NotificationService().init();
  runApp(ChangeNotifierProvider(create: (context) => ThemeProvider(),
  child: const MyApp(),)
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: Provider.of<ThemeProvider>(context).themeData,
      // home: AuthGate(),
        home: SplashScreen(),
      routes: {
        'home_page':(context)=>const HomePage()
      }
    );
  }
}


