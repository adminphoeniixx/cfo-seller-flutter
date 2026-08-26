import '../../../core/network/api_client.dart';
import '../../../core/network/network_result.dart';
import '../../../shared/models/seller.dart';
import '../domain/auth_repository.dart';
import '../domain/auth_session.dart';

/// Talks to the real `/api/seller` auth endpoints. Every response shape
/// here was verified against the live server on 2026-08-22 (see the
/// endpoint's own comment), not assumed from the docs alone.
class ApiAuthRepository implements AuthRepository {
  final ApiClient _client;

  ApiAuthRepository(this._client);

  @override
  Future<NetworkResult<AuthSession>> login({
    required String email,
    required String password,
    required String deviceName,
  }) {
    return _client.post(
      '/login',
      body: {'email': email, 'password': password, 'device_name': deviceName},
      // Top-level `{ token, seller }` — confirmed via curl, HTTP 200.
      parse: (json) => AuthSession.fromJson(json as Map<String, dynamic>),
    );
  }

  @override
  Future<NetworkResult<AuthSession>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    required String storeName,
    required String deviceName,
    String? phone,
    String? storeEmail,
    String? gstNumber,
  }) {
    return _client.post(
      '/register',
      body: {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
        'store_name': storeName,
        'device_name': deviceName,
        'phone': ?phone,
        'store_email': ?storeEmail,
        'gst_number': ?gstNumber,
      },
      // Same top-level `{ token, seller }` shape as login — confirmed via
      // curl, HTTP 201, store lands as status "pending" / can_trade false.
      parse: (json) => AuthSession.fromJson(json as Map<String, dynamic>),
    );
  }

  @override
  Future<NetworkResult<void>> forgotPassword({required String email}) {
    return _client.post(
      '/forgot-password',
      body: {'email': email},
      parse: (_) {},
    );
  }

  @override
  Future<NetworkResult<void>> resetPassword({
    required String token,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) {
    return _client.post(
      '/reset-password',
      body: {
        'token': token,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
      },
      parse: (_) {},
    );
  }

  @override
  Future<NetworkResult<Seller>> me() {
    return _client.get(
      '/me',
      // Wrapped in `{ "data": ... }` — confirmed via curl, unlike login's
      // top-level shape. Same inner `seller` object either way.
      parse: (json) => Seller.fromJson(
        (json as Map<String, dynamic>)['data'] as Map<String, dynamic>,
      ),
    );
  }

  @override
  Future<NetworkResult<Seller>> updateMe({
    required String name,
    required String email,
    String? phone,
  }) {
    return _client.put(
      '/me',
      body: {'name': name, 'email': email, 'phone': ?phone},
      // Wrapped in `{ "data": ... }` — confirmed via curl, HTTP 200.
      parse: (json) => Seller.fromJson(
        (json as Map<String, dynamic>)['data'] as Map<String, dynamic>,
      ),
    );
  }

  @override
  Future<NetworkResult<void>> updatePassword({
    required String currentPassword,
    required String password,
    required String passwordConfirmation,
  }) {
    return _client.put(
      '/me/password',
      body: {
        'current_password': currentPassword,
        'password': password,
        'password_confirmation': passwordConfirmation,
      },
      parse: (_) {},
    );
  }

  @override
  Future<NetworkResult<AuthSession>> refresh({String? deviceName}) {
    return _client.post(
      '/refresh',
      body: {'device_name': ?deviceName},
      // Same top-level `{ token, seller }` shape — confirmed via curl.
      parse: (json) => AuthSession.fromJson(json as Map<String, dynamic>),
    );
  }

  @override
  Future<NetworkResult<void>> logout() {
    return _client.post('/logout', parse: (_) {});
  }

  @override
  Future<NetworkResult<void>> logoutAll() {
    return _client.post('/logout-all', parse: (_) {});
  }
}
