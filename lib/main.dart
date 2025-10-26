// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:uresaxapp/controllers/companies.controller.dart';
import 'package:uresaxapp/controllers/ncfs.override.controller.dart';
import 'package:uresaxapp/controllers/permissions.controller.dart';
import 'package:uresaxapp/controllers/sales.controller.dart';
import 'package:uresaxapp/controllers/ux.controller.dart';
import 'package:uresaxapp/models/user.dart';
import 'package:uresaxapp/pages/companies_page.dart';
import 'package:uresaxapp/pages/login_page.dart';
import 'package:uresaxapp/utils/consts.dart';
import 'package:uresaxapp/utils/extra.dart';
import 'package:uresaxapp/widgets/layout.with.bar.widget.dart';
import 'package:window_manager/window_manager.dart';
import 'package:uresaxapp/controllers/session.controller.dart';
import 'package:uresaxapp/controllers/periods.controller.dart';
import 'package:uresaxapp/controllers/purchases.controller.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:flutter_platform_alert/flutter_platform_alert.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:package_info_plus/package_info_plus.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    packageInfo = await PackageInfo.fromPlatform();

   hostName = Platform.environment['DATABASE_HOSTNAME'];
   dbPort = Platform.environment['DATABASE_PORT'];
   dbName = Platform.environment['DATABASE_NAME'];
   dbUsername = Platform.environment['DATABASE_USERNAME'];
   dbSecret = Platform.environment['DATABASE_SECRET'];
   dirUresaxPath = Platform.environment['URESAX_STATIC_LOCAL_SERVER_PATH'];

   print(dirUresaxPath);

    if (hostName == null ||
        dbPort == null ||
        dbName == null ||
        dbUsername == null ||
        dbSecret == null || 
        dirUresaxPath == null) {
      'Las variables de entorno de la base de datos no están configuradas correctamente.';
    }

    await windowManager.ensureInitialized();

    Get.put(UxController());

    Get.put(PermissionsController());

    Get.put(PurchasesController());

    Get.put(SalesController());

    Get.put(NcfsOverrideController());

    Get.put(PeriodsController());

    try {
      var userData = await SessionManager().get('USER');

      User? user = User.fromMap(userData ?? {});
      user = await User.findUserById(user.id ?? 'x');
      User.current = user;
    } catch (e) {
      rethrow;
    }

    Size sizeWindow = const Size(1000, 600);

    runApp(const MyApp());

    doWhenWindowReady(() {
      var initialSize = sizeWindow;
      appWindow.minSize = Size(500, sizeWindow.height);
      appWindow.size = initialSize;
      appWindow.alignment = Alignment.center;
      appWindow.title = 'URESAX';
      appWindow.show();
      windowManager.setMaximizable(true);
      windowManager.setMinimizable(true);
    });
  } catch (e) {
    await FlutterPlatformAlert.playAlertSound();
    await FlutterPlatformAlert.showAlert(
      windowTitle: 'ALERTA',
      text: e.toString(),
      alertStyle: AlertButtonStyle.ok,
      iconStyle: IconStyle.error,
    );
    windowManager.close();
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Widget get content {
    if (sessionController.loading.value) {
      return loaderWidget(context);
    }

    if (sessionController.currentUser?.value == null) {
      return LoginPage();
    }

    if (sessionController.currentUser?.value != null) {
      return CompaniesPage();
    }
    return Container();
  }

  Widget loaderWidget(BuildContext context) {
    return LayoutWithBar(
        child: Container(
            width: double.infinity,
            color: kPrimaryColor,
            child: Center(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SvgPicture.asset('assets/svgs/URESAXLOGO.SVG',
                    width: 100, height: 100),
                SizedBox(height: kDefaultPadding),
                const CircularProgressIndicator(color: Colors.white)
              ],
            ))));
  }

  @override
  Widget build(BuildContext context) {
    Get.put(CompaniesController());
    sessionController = Get.put(SessionController());
    return PlatformMenuBar(
        menus: [],
        child: GetMaterialApp(
            title: 'URESAX',
            locale: const Locale('es'),
            debugShowCheckedModeBanner: false,
            localizationsDelegates: GlobalMaterialLocalizations.delegates,
            supportedLocales: const [Locale('es')],
            theme: ThemeData(
                primaryColor: kPrimaryColor,
                useMaterial3: false,
                dialogTheme: DialogThemeData(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                popupMenuTheme: PopupMenuThemeData(
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadiusGeometry.circular(kDefaultPadding))),
                textTheme: TextTheme(
                    headlineLarge: TextStyle(fontSize: 26),
                    headlineMedium: TextStyle(fontSize: 24),
                    headlineSmall: TextStyle(fontSize: 22),
                    displayLarge:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
                    displayMedium: TextStyle(fontSize: 18),
                    displaySmall: TextStyle(fontSize: 15)),
                appBarTheme: AppBarTheme(
                  centerTitle: false,
                  toolbarHeight: kToolbarHeight + kDefaultPadding,
                ),
                floatingActionButtonTheme: FloatingActionButtonThemeData(
                    backgroundColor: kPrimaryColor),
                snackBarTheme: SnackBarThemeData(actionTextColor: Colors.white),
                colorScheme: ColorScheme.fromSeed(
                    seedColor: kPrimaryColor,
                    primary: kPrimaryColor,
                    secondary: const Color(0xFF1CA565),
                    error: kErrorColor),
                visualDensity: VisualDensity.adaptivePlatformDensity),
            home: Obx(() => content)));
  }
}
