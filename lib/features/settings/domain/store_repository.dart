import '../../../core/network/network_result.dart';
import '../../../shared/models/store.dart';

abstract class StoreRepository {
  Future<NetworkResult<Store>> getStore();

  /// Full replace per the API docs — `commission_rate`, `status` and
  /// `rating` are marketplace-controlled and silently ignored if sent.
  Future<NetworkResult<Store>> updateStore({
    required String name,
    String? storeEmail,
    String? phone,
    String? description,
    String? addressLine1,
    String? city,
    String? state,
    String? postcode,
    String? country,
    String? gstNumber,
    String? payoutMethod,
    String? bankAccountName,
    String? bankAccountNumber,
    String? bankIfsc,
  });
}
