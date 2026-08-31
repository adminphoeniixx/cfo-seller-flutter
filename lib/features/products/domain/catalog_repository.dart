import '../../../core/network/network_result.dart';
import '../../../shared/models/catalog.dart';

abstract class CatalogRepository {
  Future<NetworkResult<CatalogOptions>> getOptions();
}
