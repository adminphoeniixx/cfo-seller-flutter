import '../../../core/network/network_result.dart';
import '../../../shared/models/seller.dart';
import 'auth_session.dart';

abstract class AuthRepository {
  Future<NetworkResult<AuthSession>> login({
    required String email,
    required String password,
    required String deviceName,
  });

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
  });

  Future<NetworkResult<void>> forgotPassword({required String email});

  Future<NetworkResult<void>> resetPassword({
    required String token,
    required String email,
    required String password,
    required String passwordConfirmation,
  });

  /// Bootstraps/refreshes the session from `GET /me` — the source of truth
  /// for `store.can_trade` and `sections` on every app resume.
  Future<NetworkResult<Seller>> me();

  Future<NetworkResult<Seller>> updateMe({
    required String name,
    required String email,
    String? phone,
  });

  Future<NetworkResult<void>> updatePassword({
    required String currentPassword,
    required String password,
    required String passwordConfirmation,
  });

  Future<NetworkResult<AuthSession>> refresh({String? deviceName});

  Future<NetworkResult<void>> logout();

  Future<NetworkResult<void>> logoutAll();
}
