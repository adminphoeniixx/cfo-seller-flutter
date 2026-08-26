import '../../../core/network/api_client.dart';
import '../../../core/network/network_result.dart';
import '../../../shared/models/service_request.dart';
import '../domain/request_repository.dart';

/// Talks to the real `/cancellations` and `/refunds` endpoints, merging
/// both into the single "Requests" list the UI shows — see
/// `service_request.dart`'s doc comment for the full curl-verification
/// note and the discrepancies found (both list endpoints confirmed real
/// but empty; a real `POST /cancellations` 422'd for real against the
/// QA account's only order/item, which is fully shipped; individual
/// resource/`respond` shapes are inferred, not curl-verified).
class ApiRequestRepository implements RequestRepository {
  final ApiClient _client;

  ApiRequestRepository(this._client);

  @override
  Future<NetworkResult<List<ServiceRequest>>> getRequests() async {
    final cancellations = await _client.get(
      '/cancellations',
      parse: (json) => ServiceRequestsPage.fromJson(
        json as Map<String, dynamic>,
        RequestKind.cancellation,
      ),
    );
    final refunds = await _client.get(
      '/refunds',
      parse: (json) => ServiceRequestsPage.fromJson(
        json as Map<String, dynamic>,
        RequestKind.refund,
      ),
    );

    // Both calls are independent; surface either real failure rather than
    // silently dropping half the list. If one succeeds and the other
    // fails, prefer showing the failure so a real error isn't hidden
    // behind a partial, misleadingly-quiet list.
    return cancellations.when(
      success: (cPage) => refunds.when(
        success: (rPage) {
          final merged = [...cPage.data, ...rPage.data]
            ..sort(
              (a, b) => (b.createdAt ?? DateTime(0)).compareTo(
                a.createdAt ?? DateTime(0),
              ),
            );
          return Success(merged);
        },
        failure: (e) => Failure(e),
      ),
      failure: (e) => Failure(e),
    );
  }

  @override
  Future<NetworkResult<ServiceRequest>> getRequest(int routeId) {
    final (kind, id) = ServiceRequestKeyCodec.decode(routeId);
    final path = kind == RequestKind.refund
        ? '/refunds/$id'
        : '/cancellations/$id';
    return _client.get(
      path,
      parse: (json) => ServiceRequest.fromJson(
        (json as Map<String, dynamic>)['data'] as Map<String, dynamic>? ?? json,
        kind,
      ),
    );
  }

  @override
  Future<NetworkResult<ServiceRequest>> respond(int routeId, String message) {
    final (kind, id) = ServiceRequestKeyCodec.decode(routeId);
    final path = kind == RequestKind.refund
        ? '/refunds/$id/respond'
        : '/cancellations/$id/respond';
    return _client.post(
      path,
      body: {'note': message},
      parse: (json) => ServiceRequest.fromJson(
        (json as Map<String, dynamic>)['data'] as Map<String, dynamic>? ?? json,
        kind,
      ),
    );
  }
}
