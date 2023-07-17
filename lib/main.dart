// ignore_for_file: use_build_context_synchronously

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:uresaxapp/controllers/sales.controller.dart';
import 'package:uresaxapp/models/user.dart';
import 'package:uresaxapp/pages/login_page.dart';
import 'package:window_manager/window_manager.dart';
import 'package:uresaxapp/pages/companies_page.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:uresaxapp/controllers/companies.controller.dart';
import 'package:uresaxapp/controllers/periods.controller.dart';
import 'package:uresaxapp/controllers/purchases.controller.dart';
import 'package:uresaxapp/controllers/session.controller.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    await windowManager.ensureInitialized();

    var c = Get.put(SessionController());
    
    Get.put(PurchasesController());

    Get.put(SalesController());

    Get.put(CompaniesController());

    Get.put(PeriodsController());
    
    try {
      var userData = await SessionManager().get('USER');
      User? user = User.fromMap(userData);
      user = await User.findUserById(user.id!);
      User.current = user;
      c.currentUser = Rx(user);
    } catch (_) {}

    WindowOptions windowOptions =
        const WindowOptions(size: Size(1280, 720), center: true, minimumSize: Size.fromWidth(500));

    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });

    runApp(const MyApp());
  } catch (e) {
    print(e);
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'URESAX',
      locale: const Locale('es'),
      debugShowCheckedModeBanner: false,
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      supportedLocales: const [Locale('es')],
      theme: ThemeData(
        primarySwatch: Colors.blue,
        colorScheme:
            ColorScheme.fromSwatch(errorColor: const Color(0xFFFA473B)),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: User.current != null ? CompaniesPage() : const LoginPage(),
    );
  }
}
