import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/push/push_route_mapper.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/widgets.dart';
import '../controllers/notifications_controller.dart';

class NotificationsScreen extends GetView<NotificationsController> {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) return const AppLoading();
      if (controller.errorMessage.value != null) {
        return AppErrorState(
          message: controller.errorMessage.value!,
          onRetry: controller.load,
        );
      }

      final items = controller.notifications;

      return AppScreen(
        children: [
          if (items.isEmpty)
            const AppEmptyState(emoji: '🔔', message: "You're all caught up.")
          else
            AppCard(
              flat: true,
              child: Column(
                children: [
                  for (var i = 0; i < items.length; i++)
                    Builder(
                      builder: (context) {
                        final colors = context.colors;
                        final n = items[i];
                        return InkWell(
                          onTap: () {
                            if (!n.read) controller.markRead(n.id);
                            final path = PushRouteMapper.resolve(
                              url: n.url,
                              kind: n.kind,
                            );
                            if (path != null) context.push(path);
                          },
                          child: Container(
                            decoration: i != items.length - 1
                                ? BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: colors.lineSoft,
                                      ),
                                    ),
                                  )
                                : null,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 11,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Container(
                                    width: 7,
                                    height: 7,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: n.read
                                          ? Colors.transparent
                                          : colors.action,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        n.title,
                                        style: TextStyle(
                                          fontSize: 13.5,
                                          fontWeight: n.read
                                              ? FontWeight.w500
                                              : FontWeight.w600,
                                          color: colors.ink,
                                        ),
                                      ),
                                      const SizedBox(height: 1),
                                      Text(
                                        n.body,
                                        style: TextStyle(
                                          fontSize: 11.5,
                                          color: colors.ink3,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  n.when,
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    color: colors.ink3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          AppButton.ghost(
            label: 'Mark all read',
            onPressed: controller.markAllRead,
          ),
        ],
      );
    });
  }
}
