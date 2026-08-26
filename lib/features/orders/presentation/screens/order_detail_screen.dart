import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/utils/app_messenger.dart';
import '../../../../shared/widgets/widgets.dart';
import '../controllers/order_detail_controller.dart';

class OrderDetailScreen extends GetView<OrderDetailController> {
  const OrderDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final order = controller.order.value;
      return Scaffold(
        appBar: AppAppBar(
          title: order != null ? order.number : 'Order',
          subtitle: order != null
              ? '${_dateLabel(order.placedAt)}${order.paymentMethod != null ? " · Paid by ${order.paymentMethod}" : ""}'
              : null,
          showBack: true,
          onBack: () => Navigator.of(context).pop(),
        ),
        body: _body(context),
      );
    });
  }

  Widget _body(BuildContext context) {
    if (controller.isLoading.value) return const AppLoading();
    final order = controller.order.value;
    if (order == null) {
      return AppErrorState(
        message: controller.errorMessage.value ?? 'Order not found',
        onRetry: controller.load,
      );
    }

    final total = order.total;
    final commission = order.totals.commission;

    return AppScreen(
      children: [
        if (order.customerNote != null && order.customerNote!.isNotEmpty)
          AppBanner(text: order.customerNote!),
        const AppSectionHeader(title: 'Your items'),
        AppCard(
          flat: true,
          child: Column(
            children: [
              for (var i = 0; i < order.items.length; i++)
                AppListRow(
                  leading: AppThumb(emoji: order.items[i].emoji),
                  title: order.items[i].name,
                  subtitle:
                      '${order.items[i].sku} · Qty ${order.items[i].quantity}'
                      '${order.items[i].quantityFulfilled > 0 ? " · ${order.items[i].quantityFulfilled} packed" : ""}',
                  amount: CurrencyFormatter.short(order.items[i].total),
                  showDivider: i != order.items.length - 1,
                ),
            ],
          ),
        ),
        AppCard(
          child: Column(
            children: [
              AppMoneyRow(
                label: 'Items',
                value: CurrencyFormatter.money(total),
              ),
              AppMoneyRow(
                label: 'Commission',
                value: '−${CurrencyFormatter.money(commission)}',
              ),
              AppMoneyRow(
                label: 'You earn',
                value: CurrencyFormatter.money(order.totals.earning),
                total: true,
              ),
            ],
          ),
        ),
        if (order.trackingNumber != null) ...[
          const AppSectionHeader(title: 'Shipment'),
          AppCard(
            child: Column(
              children: [
                AppMoneyRow(label: 'Carrier', value: order.carrier ?? ''),
                AppMoneyRow(
                  label: 'Tracking',
                  value: order.trackingNumber ?? '',
                ),
              ],
            ),
          ),
        ],
        const AppSectionHeader(title: 'Deliver to'),
        AppCard(
          child: Builder(
            builder: (context) {
              final colors = context.colors;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.customer.name,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: colors.ink,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${order.shippingAddress.formatted}\n${order.customer.phone}',
                    style: TextStyle(
                      fontSize: 12,
                      color: colors.ink2,
                      height: 1.55,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        Text(
          "The buyer's email and order history aren't shared with sellers.",
          style: TextStyle(
            fontSize: 11.5,
            color: context.colors.ink3,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 4),
        if (order.needsPacking)
          AppButton(
            label: 'Pack & ship',
            onPressed: () => context.push(AppRoutes.orderFulfilPath(order.id)),
          )
        else
          AppButton.ghost(
            label: order.shippedAt != null
                ? 'Shipped ${_dateLabel(order.shippedAt)}'
                : 'Fulfilled',
            onPressed: null,
          ),
        AppButton.ghost(
          label: 'Add a note',
          onPressed: () => _showAddNoteSheet(context),
        ),
      ],
    );
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

  void _showAddNoteSheet(BuildContext context) {
    final textController = TextEditingController();
    Get.bottomSheet(
      Builder(
        builder: (context) {
          final colors = context.colors;
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppTextField(
                  label: 'Note',
                  placeholder: 'Packed and handed to the courier.',
                  controller: textController,
                ),
                const SizedBox(height: 12),
                Obx(
                  () => AppButton(
                    label: controller.isAddingNote.value
                        ? 'Adding…'
                        : 'Add note',
                    onPressed: controller.isAddingNote.value
                        ? null
                        : () async {
                            final ok = await controller.submitNote(
                              textController.text,
                            );
                            if (ok) {
                              Get.back();
                              AppMessenger.show('Note added to the order');
                            }
                          },
                  ),
                ),
              ],
            ),
          );
        },
      ),
      isScrollControlled: true,
    );
  }
}
