import '../../../core/network/api_client.dart';
import '../../../core/network/network_result.dart';
import '../domain/push_repository.dart';

/// Talks to the real `/push` endpoints (API docs' "Firebase push" section).
///
/// NOT independently curl-verified against a live server the way most other
/// `Api*Repository` classes in this codebase are (see e.g.
/// `ApiDeviceRepository`'s doc comment) — the seller-side push endpoints
/// exist on the real backend per the docs/Postman collection, but this repo
/// is currently registered against Firebase project `seller-910c9` (the
/// project already wired up for Analytics/Crashlytics via `flutterfire
/// configure`), NOT the `cfo-hub-5e4fb` project the marketplace server
/// actually sends push through. Registration calls below are real HTTP
/// calls to the real backend — only the Firebase project backing the FCM
/// token itself is the "wrong" one for now, so real inbound notifications
/// won't arrive until the project is swapped (see `PushService`'s doc
/// comment for what that swap involves).
class ApiPushRepository implements PushRepository {
  final ApiClient _client;

  ApiPushRepository(this._client);

  @override
  Future<NetworkResult<void>> registerDevice({
    required String token,
    String? platform,
    String? deviceName,
  }) {
    return _client.post(
      '/push/device',
      body: {'token': token, 'platform': ?platform, 'device_name': ?deviceName},
      parse: (_) {},
    );
  }

  @override
  Future<NetworkResult<void>> unregisterDevice(String token) {
    return _client.delete(
      '/push/device',
      body: {'token': token},
      parse: (_) {},
    );
  }

  @override
  Future<NetworkResult<PushSettings>> getPushSettings() {
    return _client.get(
      '/push',
      parse: (json) => PushSettings.fromJson(json as Map<String, dynamic>),
    );
  }
}
