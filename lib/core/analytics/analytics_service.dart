import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/widgets.dart' show NavigatorObserver;

/// Thin, centralized wrapper around [FirebaseAnalytics] for this app's
/// meaningful business events. Screens/controllers call methods here
/// rather than touching `FirebaseAnalytics.instance` directly, so event
/// names/params stay consistent and easy to audit in one place.
///
/// Registered as a permanent GetX singleton in `AppBindings.init()`.
/// Access via `Get.find<AnalyticsService>()`.
class AnalyticsService {
  final FirebaseAnalytics _analytics;

  AnalyticsService([FirebaseAnalytics? analytics])
    : _analytics = analytics ?? FirebaseAnalytics.instance;

  /// Attach to `GoRouter.observers` for automatic `screen_view` logging.
  /// Typed as the base [NavigatorObserver] (rather than the concrete
  /// `FirebaseAnalyticsObserver`) so a test double can override it with a
  /// plain no-op observer instead of needing a real `FirebaseAnalytics`
  /// instance, which requires `Firebase.initializeApp()` to have run.
  NavigatorObserver get navigatorObserver =>
      FirebaseAnalyticsObserver(analytics: _analytics);

  Future<void> logLogin() => _analytics.logLogin(loginMethod: 'email');

  Future<void> logSignUp() => _analytics.logSignUp(signUpMethod: 'email');

  Future<void> logOrderFulfilled({required int orderId}) => _analytics.logEvent(
    name: 'order_fulfilled',
    parameters: {'order_id': orderId},
  );

  Future<void> setUserId(String? id) => _analytics.setUserId(id: id);
}
