import 'package:get/get.dart';

import '../../../../shared/models/app_notification.dart';
import '../../domain/notification_repository.dart';

class NotificationsController extends GetxController {
  final NotificationRepository _repository;

  NotificationsController(this._repository);

  final isLoading = true.obs;
  final errorMessage = RxnString();
  final notifications = <AppNotification>[].obs;
  final unreadCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    errorMessage.value = null;
    final result = await _repository.getNotifications();
    result.when(
      success: (page) {
        notifications.assignAll(page.data);
        unreadCount.value = page.unreadCount;
      },
      failure: (e) => errorMessage.value = e.message,
    );
    isLoading.value = false;
  }

  /// Cheap enough to call on every app resume, per the docs — used by
  /// `MainShell` for the bell badge without loading the full list.
  Future<void> refreshUnreadCount() async {
    final result = await _repository.getUnreadCount();
    result.when(success: (n) => unreadCount.value = n, failure: (_) {});
  }

  Future<void> markAllRead() async {
    final result = await _repository.markAllRead();
    result.when(
      success: (n) {
        notifications.assignAll(
          notifications.map((x) => x.copyWith(read: true)),
        );
        unreadCount.value = n;
      },
      failure: (e) => errorMessage.value = e.message,
    );
  }

  Future<void> markRead(int id) async {
    final result = await _repository.markRead(id);
    result.when(
      success: (_) {
        final index = notifications.indexWhere((n) => n.id == id);
        if (index != -1 && !notifications[index].read) {
          notifications[index] = notifications[index].copyWith(read: true);
          if (unreadCount.value > 0) unreadCount.value--;
        }
      },
      failure: (_) {},
    );
  }

  Future<void> delete(int id) async {
    final result = await _repository.delete(id);
    result.when(
      success: (_) => notifications.removeWhere((n) => n.id == id),
      failure: (e) => errorMessage.value = e.message,
    );
  }
}
