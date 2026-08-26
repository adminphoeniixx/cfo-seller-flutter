import '../../../core/network/network_result.dart';
import '../../../shared/models/device.dart';

abstract class DeviceRepository {
  /// `GET /devices` — tokens currently issued, with `current: true` on the
  /// one making the call.
  Future<NetworkResult<List<Device>>> getDevices();

  /// `DELETE /devices/{id}` — revokes one device's token. Verified via curl
  /// to 401 any further authenticated call made with that token.
  Future<NetworkResult<void>> revokeDevice(int id);
}
