/// Owns the FCM client lifecycle: permission request, token registration
/// (+ rotation) with the seller API, foreground notification display, and
/// tap routing for all three states (foreground/background/terminated).
///
/// An interface — rather than depending on the concrete [FcmPushService]
/// directly — purely so `test/widget_test.dart` can substitute a no-op
/// fake the same way it already does for every `*Repository` (and
/// `AnalyticsService`): [FcmPushService]'s real implementation touches
/// `FirebaseMessaging.instance`, which requires a real
/// `Firebase.initializeApp()` call never made in the widget-test
/// environment.
///
/// See [FcmPushService]'s doc comment for the full design, including the
/// `seller-910c9` vs `cfo-hub-5e4fb` Firebase project note.
abstract class PushService {
  /// Call once, after successful sign-in — see `AuthController.signIn()`.
  Future<void> initializeAfterSignIn();

  /// Checked once, after app bootstrap — covers the terminated-app-tap
  /// case. See `main.dart`.
  Future<void> handleInitialMessage();

  /// Best-effort — called from `AuthController.signOut()`/
  /// `signOutAllDevices()` before local session state is cleared.
  Future<void> unregisterCurrentDevice();

  void dispose();
}
