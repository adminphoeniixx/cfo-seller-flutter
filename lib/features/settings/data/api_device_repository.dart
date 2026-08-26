import '../../../core/network/api_client.dart';
import '../../../core/network/network_result.dart';
import '../../../shared/models/device.dart';
import '../domain/device_repository.dart';

/// Talks to the real `/devices` endpoints. Verified via curl against the
/// live QA store (id 13) on 2026-08-22: logged in a second disposable
/// device (`agent-test-device`), confirmed `GET /devices` listed both it
/// and the main device with `current: true` on the caller, revoked the
/// disposable one with `DELETE /devices/{id}`, and confirmed a subsequent
/// authenticated call with its now-revoked token returned `401`. The QA
/// seller's other real devices were left untouched.
///
/// See `device.dart`'s doc comment for the response shape.
class ApiDeviceRepository implements DeviceRepository {
  final ApiClient _client;

  ApiDeviceRepository(this._client);

  @override
  Future<NetworkResult<List<Device>>> getDevices() {
    return _client.get(
      '/devices',
      parse: (json) => ((json as Map<String, dynamic>)['data'] as List)
          .map((e) => Device.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  Future<NetworkResult<void>> revokeDevice(int id) {
    return _client.delete('/devices/$id', parse: (_) {});
  }
}
