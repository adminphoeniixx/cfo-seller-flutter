import 'dart:async';

import 'package:get/get.dart';

import '../../../../core/analytics/analytics_service.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/token_storage.dart';
import '../../../../core/push/push_service.dart';
import '../../../../core/utils/device_name_provider.dart';
import '../../../../shared/models/seller.dart';
import '../../../../shared/models/store.dart';
import '../../domain/auth_repository.dart';

/// Owns sign-in/register/session state. Screens call methods here; nothing
/// in the presentation layer talks to [AuthRepository] or [TokenStorage]
/// directly.
class AuthController extends GetxController {
  final AuthRepository _repository;
  final TokenStorage _tokenStorage;
  final DeviceNameProvider _deviceNameProvider;

  AuthController(
    this._repository,
    this._tokenStorage,
    this._deviceNameProvider,
  );

  final isSignedIn = false.obs;
  final isLoading = false.obs;
  final isBootstrapping = true.obs;
  final errorMessage = RxnString();
  final fieldErrors = <String, String>{}.obs;
  final Rxn<Seller> seller = Rxn<Seller>();

  Store? get store => seller.value?.store;

  /// Authoritative trading gate — `store.can_trade`, not `status ==
  /// approved` (a suspended/rejected store is also non-pending).
  bool get isApproved => store?.canTrade ?? false;

  bool hasSection(SellerSection section) =>
      seller.value?.hasSection(section) ?? false;

  String? fieldError(String key) => fieldErrors[key];

  void _clearErrors() {
    errorMessage.value = null;
    fieldErrors.clear();
  }

  void _setError(AppException e) {
    errorMessage.value = e.message;
    if (e is ValidationException) {
      fieldErrors.assignAll(
        e.fieldErrors.map(
          (key, value) =>
              MapEntry(key, value.isEmpty ? e.message : value.first),
        ),
      );
    }
  }

  /// Called once at app start: if a token is already on disk, confirms it's
  /// still valid via `GET /me` before landing on Home/Pending instead of
  /// the sign-in screen.
  Future<void> bootstrap() async {
    isBootstrapping.value = true;
    await _tokenStorage.init();
    if (_tokenStorage.isSignedIn) {
      final result = await _repository.me();
      result.when(
        success: (s) {
          seller.value = s;
          isSignedIn.value = true;
        },
        failure: (_) async {
          // Token missing/expired/revoked server-side — 401 is the only
          // case that should clear the session; other failures (network)
          // leave the token in place so bootstrap can retry next launch.
          await _tokenStorage.clear();
          isSignedIn.value = false;
        },
      );
    }
    isBootstrapping.value = false;
  }

  Future<bool> signIn({required String email, required String password}) async {
    isLoading.value = true;
    _clearErrors();
    final deviceName = await _deviceNameProvider.get();
    final result = await _repository.login(
      email: email,
      password: password,
      deviceName: deviceName,
    );
    isLoading.value = false;
    return result.when(
      success: (session) async {
        await _tokenStorage.save(session.token);
        seller.value = session.seller;
        isSignedIn.value = true;
        unawaited(Get.find<AnalyticsService>().logLogin());
        unawaited(Get.find<PushService>().initializeAfterSignIn());
        return true;
      },
      failure: (e) {
        _setError(e);
        return false;
      },
    );
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    required String storeName,
    String? phone,
    String? storeEmail,
    String? gstNumber,
  }) async {
    isLoading.value = true;
    _clearErrors();
    final deviceName = await _deviceNameProvider.get();
    final result = await _repository.register(
      name: name,
      email: email,
      password: password,
      passwordConfirmation: passwordConfirmation,
      storeName: storeName,
      deviceName: deviceName,
      phone: phone,
      storeEmail: storeEmail,
      gstNumber: gstNumber,
    );
    isLoading.value = false;
    return result.when(
      success: (session) async {
        await _tokenStorage.save(session.token);
        seller.value = session.seller;
        isSignedIn.value = true;
        unawaited(Get.find<AnalyticsService>().logSignUp());
        unawaited(Get.find<PushService>().initializeAfterSignIn());
        return true;
      },
      failure: (e) {
        _setError(e);
        return false;
      },
    );
  }

  Future<bool> forgotPassword({required String email}) async {
    isLoading.value = true;
    _clearErrors();
    final result = await _repository.forgotPassword(email: email);
    isLoading.value = false;
    return result.when(
      success: (_) => true,
      failure: (e) {
        _setError(e);
        return false;
      },
    );
  }

  Future<bool> resetPassword({
    required String token,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    isLoading.value = true;
    _clearErrors();
    final result = await _repository.resetPassword(
      token: token,
      email: email,
      password: password,
      passwordConfirmation: passwordConfirmation,
    );
    isLoading.value = false;
    return result.when(
      success: (_) => true,
      failure: (e) {
        _setError(e);
        return false;
      },
    );
  }

  Future<bool> updateProfile({
    required String name,
    required String email,
    String? phone,
  }) async {
    isLoading.value = true;
    _clearErrors();
    final result = await _repository.updateMe(
      name: name,
      email: email,
      phone: phone,
    );
    isLoading.value = false;
    return result.when(
      success: (s) {
        seller.value = s;
        return true;
      },
      failure: (e) {
        _setError(e);
        return false;
      },
    );
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String password,
    required String passwordConfirmation,
  }) async {
    isLoading.value = true;
    _clearErrors();
    final result = await _repository.updatePassword(
      currentPassword: currentPassword,
      password: password,
      passwordConfirmation: passwordConfirmation,
    );
    isLoading.value = false;
    return result.when(
      success: (_) => true,
      failure: (e) {
        _setError(e);
        return false;
      },
    );
  }

  /// Re-fetches `/me` — used by the Pending screen's "Check again" action,
  /// since approval happens on the marketplace side, not something the
  /// seller can trigger themselves.
  Future<void> refreshMe() async {
    final result = await _repository.me();
    result.when(success: (s) => seller.value = s, failure: _setError);
  }

  Future<void> signOut() async {
    // Best-effort, and deliberately BEFORE the local session is cleared —
    // see PushService.unregisterCurrentDevice()'s doc comment for why this
    // never blocks/fails sign-out.
    await Get.find<PushService>().unregisterCurrentDevice();
    await _repository.logout();
    await _tokenStorage.clear();
    isSignedIn.value = false;
    seller.value = null;
  }

  Future<void> signOutAllDevices() async {
    await Get.find<PushService>().unregisterCurrentDevice();
    await _repository.logoutAll();
    await _tokenStorage.clear();
    isSignedIn.value = false;
    seller.value = null;
  }
}
