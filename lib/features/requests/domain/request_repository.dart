import '../../../core/network/network_result.dart';
import '../../../shared/models/service_request.dart';

abstract class RequestRepository {
  /// Merges `GET /cancellations` and `GET /refunds` into one list, the way
  /// the app's single "Requests" screen presents them.
  Future<NetworkResult<List<ServiceRequest>>> getRequests();

  /// [routeId] is a [ServiceRequest.routeId] — decode it via
  /// [ServiceRequestKeyCodec] to know whether to hit `/cancellations/{id}`
  /// or `/refunds/{id}`.
  Future<NetworkResult<ServiceRequest>> getRequest(int routeId);

  /// `POST /cancellations/{id}/respond` or `POST /refunds/{id}/respond`
  /// depending on what [routeId] decodes to.
  Future<NetworkResult<ServiceRequest>> respond(int routeId, String message);
}
