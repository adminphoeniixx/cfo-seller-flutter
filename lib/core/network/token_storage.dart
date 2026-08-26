import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Persists the Sanctum bearer token in the platform keychain/keystore via
/// `flutter_secure_storage`, with an in-memory cache so [ApiInterceptor] can
/// read it synchronously on every request without an async round trip.
/// Call [init] once at app startup (before any authenticated request) to
/// warm the cache from disk.
class TokenStorage {
  static const _key = 'seller_auth_token';
  final FlutterSecureStorage _storage;

  String? _cached;

  TokenStorage({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  /// Synchronous read for the interceptor — reflects the last value saved
  /// or loaded via [init]/[save]/[clear].
  String? get token => _cached;

  Future<void> init() async {
    _cached = await _storage.read(key: _key);
  }

  Future<void> save(String token) async {
    _cached = token;
    await _storage.write(key: _key, value: token);
  }

  Future<void> clear() async {
    _cached = null;
    await _storage.delete(key: _key);
  }

  bool get isSignedIn => _cached != null;
}
