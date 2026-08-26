import '../../../core/network/network_result.dart';
import '../../../shared/models/shipping_rate.dart';

abstract class ShippingRepository {
  Future<NetworkResult<List<ShippingZone>>> getZones();
}
