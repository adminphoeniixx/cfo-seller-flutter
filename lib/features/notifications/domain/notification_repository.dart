import '../../../core/network/network_result.dart';
import '../../../shared/models/app_notification.dart';

abstract class NotificationRepository {
  Future<NetworkResult<NotificationsPage>> getNotifications({
    String? filter,
    String? kind,
    int perPage = 25,
  });
  Future<NetworkResult<int>> getUnreadCount();
  Future<NetworkResult<int>> markAllRead();
  Future<NetworkResult<void>> markRead(int id);
  Future<NetworkResult<void>> delete(int id);
}
