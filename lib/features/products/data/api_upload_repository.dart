import '../../../core/network/api_client.dart';
import '../../../core/network/network_result.dart';
import '../../../shared/models/product.dart';
import '../domain/upload_repository.dart';

/// `POST /uploads` (multipart) — per `seller-app-product-form.md` §4, sends
/// the picked file plus a `folder` field, returns `{ path, url }`. The
/// caller keeps `path` on the product's `images[]`; `url` is signed and
/// time-limited so it's only ever used to render the preview, never
/// persisted (see the field-level warning in that section).
///
/// The upload microservice behind this endpoint was down (502, "Service is
/// not reachable") from 2026-08-22 through 2026-08-26, then came back up —
/// **curl-verified working end-to-end on 2026-08-27**: uploaded a file,
/// got back `{ path, url }` with no `data` wrapper (matching the `parse`
/// below), then created a scratch product (#59) with that `path` in
/// `images[]` and confirmed the server echoed back the full image object
/// (`id`, `path`, `url`, `alt`, `position`) — deleted after verification.
class ApiUploadRepository implements UploadRepository {
  final ApiClient _client;

  ApiUploadRepository(this._client);

  @override
  Future<NetworkResult<ProductImage>> upload(String filePath) {
    return _client.upload(
      '/uploads',
      filePath: filePath,
      fileFieldName: 'file',
      fields: const {'folder': 'products'},
      parse: (json) {
        final data = (json is Map && json['data'] is Map)
            ? (json as Map<String, dynamic>)['data'] as Map<String, dynamic>
            : json as Map<String, dynamic>;
        return ProductImage(path: data['path'] as String?, url: data['url'] as String?);
      },
    );
  }
}
