import '../../../core/network/api_client.dart';
import '../../../core/network/network_result.dart';
import '../../../shared/models/store.dart';
import '../domain/store_repository.dart';

/// Talks to the real `GET/PUT /store`. Verified against the live server on
/// 2026-08-22 — response wrapped in `{ "data": <store> }`, and critically,
/// the store's own email field is sent as `store_email` in the request
/// body (not `email`) — confirmed by disambiguation, not assumed from the
/// docs' example payload alone.
class ApiStoreRepository implements StoreRepository {
  final ApiClient _client;

  ApiStoreRepository(this._client);

  @override
  Future<NetworkResult<Store>> getStore() {
    return _client.get(
      '/store',
      parse: (json) => Store.fromJson(
        (json as Map<String, dynamic>)['data'] as Map<String, dynamic>,
      ),
    );
  }

  @override
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
  }) {
    return _client.put(
      '/store',
      body: {
        'name': name,
        'store_email': ?storeEmail,
        'phone': ?phone,
        'description': ?description,
        'address_line1': ?addressLine1,
        'city': ?city,
        'state': ?state,
        'postcode': ?postcode,
        'country': ?country,
        'gst_number': ?gstNumber,
        'payout_method': ?payoutMethod,
        'bank_account_name': ?bankAccountName,
        'bank_account_number': ?bankAccountNumber,
        'bank_ifsc': ?bankIfsc,
      },
      parse: (json) => Store.fromJson(
        (json as Map<String, dynamic>)['data'] as Map<String, dynamic>,
      ),
    );
  }
}
