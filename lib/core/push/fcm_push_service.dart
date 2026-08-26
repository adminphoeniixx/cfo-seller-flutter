import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../../features/settings/domain/push_repository.dart';
import '../../firebase_options.dart';
import '../utils/device_name_provider.dart';
import 'push_route_mapper.dart';
import 'push_service.dart';

/// Android channel id the API docs explicitly call out: Android 8+ (API 26)
/// silently drops any notification that doesn't declare a channel, so this
/// id must match whatever the backend puts in the FCM payload's Android
/// notification channel field.
const String kPushAndroidChannelId = 'cfo_alerts';

/// Owns the whole FCM client lifecycle: permission request, token
/// registration (+ rotation) with the seller API, foreground display via
/// `flutter_local_notifications`, and tap routing for all three states
/// (foreground/background/terminated) via [PushRouteMapper].
///
/// ---
/// ### Wired against `seller-910c9`, not `cfo-hub-5e4fb`
/// This app's Firebase project (`lib/firebase_options.dart`, via
/// `flutterfire configure`) is `seller-910c9` — the same project already
/// used for Analytics/Crashlytics. The API docs state the marketplace
/// SERVER sends seller push through a DIFFERENT Firebase project,
/// `cfo-hub-5e4fb`, which this user doesn't yet have CLI access to.
///
/// Per explicit instruction, this integration is built now, in full,
/// against `seller-910c9` — every piece below (permission request, token
/// registration, channel setup, tap routing) is real and exercises the
/// real `POST/DELETE /push/device` endpoints. The only thing that won't
/// work until the project is swapped is receiving an actual push FROM the
/// real backend, since it will be sending via `cfo-hub-5e4fb`'s server
/// key, which doesn't address a token minted against `seller-910c9`.
///
/// **To point this at the real project later:** run
/// `flutterfire configure --project=cfo-hub-5e4fb` to regenerate
/// `firebase_options.dart` (and `google-services.json` /
/// `GoogleService-Info.plist`). That's a config regeneration, not a code
/// change — nothing in this file, `ApiPushRepository`, or the bindings
/// below references `seller-910c9` by name.
class FcmPushService implements PushService {
  final PushRepository _repository;
  final DeviceNameProvider _deviceNameProvider;
  final FirebaseMessaging _messaging;
  final FlutterLocalNotificationsPlugin _localNotifications;

  FcmPushService(
    this._repository,
    this._deviceNameProvider, {
    FirebaseMessaging? messaging,
    FlutterLocalNotificationsPlugin? localNotifications,
  }) : _messaging = messaging ?? FirebaseMessaging.instance,
       _localNotifications =
           localNotifications ?? FlutterLocalNotificationsPlugin();

  StreamSubscription<String>? _tokenRefreshSub;
  StreamSubscription<RemoteMessage>? _onMessageSub;
  StreamSubscription<RemoteMessage>? _onMessageOpenedSub;
  bool _initialized = false;
  String? _lastRegisteredToken;

  /// Idempotent: re-entering this after a token refresh mid-session is a
  /// no-op past the first call other than the token-refresh listener,
  /// which is itself only attached once.
  @override
  Future<void> initializeAfterSignIn() async {
    if (_initialized) return;
    _initialized = true;

    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      // User declined — nothing further to do; no token to register, and
      // re-requesting on every sign-in would be annoying. `onTokenRefresh`
      // is still attached below in case they later flip it on in Settings
      // and the OS decides to hand us a token anyway.
    }

    await _createAndroidChannel();
    await _initLocalNotifications();

    unawaited(_registerCurrentToken());

    _tokenRefreshSub ??= _messaging.onTokenRefresh.listen((token) {
      unawaited(_registerToken(token));
    });

    _onMessageSub ??= FirebaseMessaging.onMessage.listen(
      _handleForegroundMessage,
    );
    _onMessageOpenedSub ??= FirebaseMessaging.onMessageOpenedApp.listen(
      _handleMessageTap,
    );
  }

  /// Checked once, after app bootstrap — covers the case where the app was
  /// fully terminated and launched by tapping a push notification.
  @override
  Future<void> handleInitialMessage() async {
    final message = await _messaging.getInitialMessage();
    if (message != null) _handleMessageTap(message);
  }

  /// Best-effort — called from `AuthController.signOut()`/
  /// `signOutAllDevices()` BEFORE local session state is cleared. Never
  /// blocks/fails sign-out: a stale device registration on the server is
  /// harmless (it just keeps getting push it can't act on until the
  /// backend's own token-invalid cleanup catches it), whereas blocking
  /// sign-out on this network call would make a device-flaky user unable
  /// to sign out at all.
  @override
  Future<void> unregisterCurrentDevice() async {
    try {
      final token = _lastRegisteredToken ?? await _messaging.getToken();
      if (token == null) return;
      await _repository.unregisterDevice(token);
    } catch (_) {
      // best-effort, per above
    }
    _lastRegisteredToken = null;
  }

  Future<void> _registerCurrentToken() async {
    try {
      final token = await _messaging.getToken();
      if (token != null) await _registerToken(token);
    } catch (_) {
      // Token fetch can fail (e.g. no network, APNs not yet available on
      // iOS simulator) — `onTokenRefresh` will retry when one becomes
      // available; nothing else to do here.
    }
  }

  Future<void> _registerToken(String token) async {
    final deviceName = await _deviceNameProvider.get();
    final result = await _repository.registerDevice(
      token: token,
      platform: _platform,
      deviceName: deviceName,
    );
    result.when(success: (_) => _lastRegisteredToken = token, failure: (_) {});
  }

  String get _platform {
    if (kIsWeb) return 'web';
    if (Platform.isIOS) return 'ios';
    return 'android';
  }

  Future<void> _createAndroidChannel() async {
    if (kIsWeb || !Platform.isAndroid) return;
    const channel = AndroidNotificationChannel(
      kPushAndroidChannelId,
      'Alerts',
      description: 'Order, store and account alerts',
      importance: Importance.high,
    );
    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  Future<void> _initLocalNotifications() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    const macosInit = DarwinInitializationSettings();
    await _localNotifications.initialize(
      settings: const InitializationSettings(
        android: androidInit,
        iOS: iosInit,
        macOS: macosInit,
      ),
      onDidReceiveNotificationResponse: (response) {
        final url = response.payload;
        if (url != null) _navigateTo(url);
      },
    );
  }

  /// `FirebaseMessaging.onMessage` — firebase_messaging does NOT show a
  /// visible notification for foreground messages on its own (that's iOS
  /// and Android's default behavior: only background/terminated messages
  /// auto-display via the OS). This shows one manually via
  /// `flutter_local_notifications` on the `cfo_alerts` channel so a
  /// foregrounded seller isn't silently missing alerts.
  void _handleForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;
    final url = message.data['url'] as String?;
    _localNotifications.show(
      id: message.hashCode,
      title: notification.title,
      body: notification.body,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          kPushAndroidChannelId,
          'Alerts',
          channelDescription: 'Order, store and account alerts',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
        macOS: DarwinNotificationDetails(),
      ),
      payload: url,
    );
  }

  /// Shared by `onMessageOpenedApp` (background tap) and
  /// `getInitialMessage()` (terminated-app tap).
  void _handleMessageTap(RemoteMessage message) {
    final url = message.data['url'] as String?;
    final kind = message.data['kind'] as String?;
    _navigateTo(PushRouteMapper.resolve(url: url, kind: kind));
  }

  void _navigateTo(String? path) {
    if (path == null) return;
    final context = Get.context;
    if (context == null) return;
    GoRouter.of(context).push(path);
  }

  @override
  void dispose() {
    _tokenRefreshSub?.cancel();
    _onMessageSub?.cancel();
    _onMessageOpenedSub?.cancel();
  }
}

/// Top-level, `@pragma('vm:entry-point')` background handler — required by
/// `firebase_messaging` for background/terminated delivery. Runs in a
/// separate isolate with no access to this app's existing `Firebase.app()`
/// instance, so it must initialize Firebase itself. Registered via
/// `FirebaseMessaging.onBackgroundMessage(firebasePushBackgroundHandler)`
/// in `main.dart`, before `runApp()`, per Firebase's standard Flutter
/// setup.
///
/// Deliberately does nothing beyond the mandatory `Firebase.initializeApp`
/// — actual handling (routing, marking read, etc.) happens on tap via
/// `onMessageOpenedApp`/`getInitialMessage` once the app is foregrounded;
/// this handler exists only so the OS delivers the background notification
/// at all.
@pragma('vm:entry-point')
Future<void> firebasePushBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}
