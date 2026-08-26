import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/theme/app_theme.dart';
import '../shared/utils/app_messenger.dart';
import 'router/app_router.dart';

class SellerApp extends StatelessWidget {
  const SellerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = AppRouter.router;
    // Theme switching goes through GetX's own `Get.changeThemeMode()` (see
    // ThemeController) rather than an Obx wrapped around the whole app —
    // GetMaterialApp.router already listens for that internally, so it
    // rebuilds itself on a theme change without this widget re-running.
    return GetMaterialApp.router(
      title: 'Seller Centre',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      scaffoldMessengerKey: AppMessenger.scaffoldMessengerKey,
      routeInformationParser: router.routeInformationParser,
      routerDelegate: router.routerDelegate,
      routeInformationProvider: router.routeInformationProvider,
      backButtonDispatcher: router.backButtonDispatcher,
    );
  }
}
