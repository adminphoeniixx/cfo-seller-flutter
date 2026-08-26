import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app/app.dart';
import 'app/bootstrap/app_bindings.dart';
import 'core/push/fcm_push_service.dart';
import 'core/push/push_service.dart';
import 'features/auth/presentation/controllers/auth_controller.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Route Flutter framework errors and otherwise-uncaught async errors to
  // Crashlytics. Standard Firebase-recommended setup — see
  // https://firebase.google.com/docs/crashlytics/get-started?platform=flutter
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  // Standard Firebase-recommended setup for background/terminated FCM
  // delivery — must be registered before runApp(), with a top-level
  // function (see push_service.dart for why). Wired against Firebase
  // project `seller-910c9` for now; see PushService's doc comment for the
  // planned swap to `cfo-hub-5e4fb`.
  FirebaseMessaging.onBackgroundMessage(firebasePushBackgroundHandler);

  AppBindings.init();
  // Confirms any on-disk token is still valid via GET /me before the first
  // frame renders, so a returning user lands directly on Home/Pending
  // instead of flashing the sign-in screen first.
  await Get.find<AuthController>().bootstrap();
  // Covers the case where the app was fully terminated and launched by
  // tapping a push notification — checked once, after bootstrap, so
  // AuthController/AppRouter are ready for the resulting navigation.
  unawaited(Get.find<PushService>().handleInitialMessage());
  runApp(const SellerApp());
}
