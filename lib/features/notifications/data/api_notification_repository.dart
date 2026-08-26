import '../../../core/network/api_client.dart';
import '../../../core/network/network_result.dart';
import '../../../shared/models/app_notification.dart';
import '../domain/notification_repository.dart';

/// Talks to the real `/notifications` endpoints. List envelope and
/// `unread`-count shape verified via curl on 2026-08-22 (see
/// `NotificationsPage`'s own doc comment for the pagination-shape
/// discrepancy this uncovered). `read`/`delete` responses were not
/// independently verified — the QA account has no notifications to call
/// them against — so their result is discarded rather than parsed.
class ApiNotificationRepository implements NotificationRepository {
  final ApiClient _client;

  ApiNotificationRepository(this._client);

  @override
  Future<NetworkResult<NotificationsPage>> getNotifications({
    String? filter,
    String? kind,
    int perPage = 25,
  }) {
    return _client.get(
      '/notifications',
      query: {'per_page': perPage, 'filter': ?filter, 'kind': ?kind},
      parse: (json) => NotificationsPage.fromJson(json as Map<String, dynamic>),
    );
  }

  @override
  Future<NetworkResult<int>> getUnreadCount() {
    return _client.get(
      '/notifications/unread-count',
      parse: (json) => (json as Map<String, dynamic>)['unread'] as int,
    );
  }

  @override
  Future<NetworkResult<int>> markAllRead() {
    return _client.post(
      '/notifications/read-all',
      parse: (json) => (json as Map<String, dynamic>)['unread'] as int,
    );
  }

  @override
  Future<NetworkResult<void>> markRead(int id) {
    return _client.post('/notifications/$id/read', parse: (_) {});
  }

  @override
  Future<NetworkResult<void>> delete(int id) {
    return _client.delete('/notifications/$id', parse: (_) {});
  }
}
