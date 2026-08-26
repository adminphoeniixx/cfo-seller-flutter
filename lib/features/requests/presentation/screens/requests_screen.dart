import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/models/service_request.dart';
import '../../../../shared/widgets/widgets.dart';
import 'package:get/get.dart';
import '../controllers/requests_controller.dart';

class RequestsScreen extends GetView<RequestsController> {
  const RequestsScreen({super.key});

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

      final requests = controller.requests;

      return AppScreen(
        children: [
          Text(
            'Marketplace staff approve or reject these. You can add your side of the story.',
            style: TextStyle(
              fontSize: 11.5,
              color: context.colors.ink3,
              height: 1.5,
            ),
          ),
          if (requests.isEmpty)
            const AppEmptyState(
              emoji: '📋',
              message: 'No cancellation or refund requests.',
            )
          else
            AppCard(
              flat: true,
              child: Column(
                children: [
                  for (var i = 0; i < requests.length; i++)
                    AppListRow(
                      title: requests[i].number,
                      titleTrailing: requests[i].status == RequestStatus.pending
                          ? const AppStatusPill(
                              label: 'Needs reply',
                              variant: AppPillVariant.warn,
                            )
                          : const AppStatusPill(
                              label: 'Approved',
                              variant: AppPillVariant.ok,
                            ),
                      subtitle:
                          '${requests[i].kind == RequestKind.refund ? "Refund" : "Cancellation"} · #${requests[i].orderId} · ${_dateLabel(requests[i].createdAt)}',
                      amount: CurrencyFormatter.short(requests[i].amount),
                      showDivider: i != requests.length - 1,
                      onTap: () => context.push(
                        AppRoutes.requestDetailPath(requests[i].routeId),
                      ),
                    ),
                ],
              ),
            ),
        ],
      );
    });
  }

  static String _dateLabel(DateTime? dt) {
    if (dt == null) return '';
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${dt.day} ${months[dt.month - 1]}';
  }
}
