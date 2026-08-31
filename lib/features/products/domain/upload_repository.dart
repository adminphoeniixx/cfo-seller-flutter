import '../../../core/network/network_result.dart';
import '../../../shared/models/product.dart';

abstract class UploadRepository {
  Future<NetworkResult<ProductImage>> upload(String filePath);
}
