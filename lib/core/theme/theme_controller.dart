import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Owns the app's light/dark/system theme choice via GetX's built-in
/// `Get.changeThemeMode()` — `GetMaterialApp` listens for that itself, so
/// switching modes doesn't require wrapping the app root in an `Obx`.
/// Defaults to dark per product direction: the prototype has no notion of
/// a default, but this app should open in dark mode regardless of device
/// setting, while still letting the user switch to light or follow system.
class ThemeController extends GetxController {
  final Rx<ThemeMode> mode = ThemeMode.dark.obs;

  void setDark() => _apply(ThemeMode.dark);
  void setLight() => _apply(ThemeMode.light);
  void setSystem() => _apply(ThemeMode.system);

  void _apply(ThemeMode next) {
    mode.value = next;
    Get.changeThemeMode(next);
  }
}
