import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/models/service_request.dart';
import '../../../../shared/utils/app_messenger.dart';
import '../../../../shared/widgets/widgets.dart';
import '../controllers/request_detail_controller.dart';

class RequestDetailScreen extends GetView<RequestDetailController> {
  const RequestDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final responseCtrl = TextEditingController();

    return Obx(() {
      final r = controller.request.value;
      return Scaffold(
        appBar: AppAppBar(
          title: r?.number ?? 'Request',
          subtitle: r != null
              ? '${r.kind == RequestKind.refund ? "Refund" : "Cancellation"} · ${r.status == RequestStatus.pending ? "Pending review" : "Approved"}'
              : null,
          showBack: true,
          onBack: () => Navigator.of(context).pop(),
        ),
        body: _body(context, responseCtrl),
      );
    });
  }

  Widget _body(BuildContext context, TextEditingController responseCtrl) {
    return Obx(() {
      if (controller.isLoading.value) return const AppLoading();
      final r = controller.request.value;
      if (r == null) {
        return AppErrorState(
          message: controller.errorMessage.value ?? 'Not found',
          onRetry: controller.load,
        );
      }

      return AppScreen(
        children: [
          Builder(
            builder: (context) {
              final colors = context.colors;
              // A `Border` can't mix per-side colors with `borderRadius` in
              // Flutter (paint-time assertion failure), so the warning-color
              // left edge is drawn as a separate strip inside a ClipRRect
              // rather than as part of a single non-uniform Border.
              return ClipRRect(
                borderRadius: BorderRadius.circular(13),
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: colors.surface,
                        border: Border.all(color: colors.line),
                      ),
                      padding: const EdgeInsets.fromLTRB(13, 13, 13, 13),
                      margin: const EdgeInsets.only(left: 3),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            r.reason,
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                              color: colors.ink,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            '"${r.note}"',
                            style: TextStyle(
                              fontSize: 12,
                              color: colors.ink2,
                              height: 1.55,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Requested by ${r.requestedBy} · Order #${r.orderId} · ${_dateLabel(r.createdAt)}',
                            style: TextStyle(fontSize: 11, color: colors.ink3),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      left: 0,
                      top: 0,
                      bottom: 0,
                      width: 3,
                      child: ColoredBox(color: colors.warnInk),
                    ),
                  ],
                ),
              );
            },
          ),
          const AppSectionHeader(title: 'Items affected'),
          AppCard(
            flat: true,
            child: Column(
              children: [
                for (var i = 0; i < r.items.length; i++)
                  AppListRow(
                    leading: AppThumb(emoji: r.items[i].emoji),
                    title: r.items[i].name,
                    subtitle: 'Qty ${r.items[i].quantity}',
                    amount: CurrencyFormatter.short(r.items[i].amount),
                    showDivider: i != r.items.length - 1,
                  ),
              ],
            ),
          ),
          AppCard(
            child: r.breakdown != null
                ? Column(
                    children: [
                      AppMoneyRow(
                        label: 'Items',
                        value: CurrencyFormatter.money(r.breakdown!.items),
                      ),
                      AppMoneyRow(
                        label: 'Shipping',
                        value: CurrencyFormatter.money(r.breakdown!.shipping),
                      ),
                      AppMoneyRow(
                        label: 'Refund total',
                        value: CurrencyFormatter.money(r.breakdown!.total),
                        total: true,
                      ),
                    ],
                  )
                : Column(
                    children: [
                      AppMoneyRow(
                        label: 'Refund requested',
                        value: r.refundRequested ? 'Yes' : 'No',
                      ),
                      AppMoneyRow(
                        label: 'Restock',
                        value: r.restock ? 'Yes' : 'No',
                      ),
                      AppMoneyRow(
                        label: 'Amount',
                        value: CurrencyFormatter.money(r.amount),
                        total: true,
                      ),
                    ],
                  ),
          ),
          if (r.status == RequestStatus.pending) ...[
            AppTextField(
              label: 'Your response',
              controller: responseCtrl,
              placeholder: 'Already packed — can we ship instead?',
            ),
            Obx(
              () => AppButton(
                label: controller.isSubmitting.value
                    ? 'Sending…'
                    : 'Send response',
                onPressed: controller.isSubmitting.value
                    ? null
                    : () async {
                        final ok = await controller.respond(responseCtrl.text);
                        if (ok && context.mounted) {
                          Navigator.of(context).pop();
                          AppMessenger.show('Response sent to the marketplace');
                        }
                      },
              ),
            ),
          ] else
            const AppBanner(
              text:
                  'Staff approved this on 4 Aug. The amount is deducted from your next payout.',
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
