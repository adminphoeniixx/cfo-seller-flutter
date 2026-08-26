import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/utils/app_messenger.dart';
import '../../../../shared/widgets/widgets.dart';
import '../controllers/order_detail_controller.dart';

class OrderFulfilScreen extends GetView<OrderDetailController> {
  const OrderFulfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final order = controller.order.value;
      return Scaffold(
        appBar: AppAppBar(
          title: 'Pack & ship',
          subtitle: order?.number,
          showBack: true,
          onBack: () => Navigator.of(context).pop(),
        ),
        body: _body(context),
      );
    });
  }

  Widget _body(BuildContext context) {
    final order = controller.order.value;
    if (controller.isLoading.value || order == null) return const AppLoading();

    final trackingController = TextEditingController(
      text: controller.tracking.value,
    );

    return AppScreen(
      children: [
        Text(
          "Set how many of each you're sending. Leave one at zero to ship it later.",
          style: TextStyle(
            fontSize: 11.5,
            color: context.colors.ink3,
            height: 1.5,
          ),
        ),
        AppCard(
          flat: true,
          child: Column(
            children: [
              for (var i = 0; i < order.items.length; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 11,
                  ),
                  child: Row(
                    children: [
                      AppThumb(emoji: order.items[i].emoji),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              order.items[i].name,
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                color: context.colors.ink,
                              ),
                            ),
                            const SizedBox(height: 1),
                            Text(
                              'Ordered ${order.items[i].quantity}',
                              style: TextStyle(
                                fontSize: 11.5,
                                color: context.colors.ink3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Obx(
                        () => AppQuantitySelector(
                          value:
                              controller.packedByItemId[order.items[i].id] ??
                              order.items[i].quantityFulfilled,
                          max: order.items[i].quantity,
                          onChanged: (v) => controller.setPacked(
                            order.items[i].id,
                            v,
                            order.items[i].quantity,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const AppSectionHeader(title: 'Shipment'),
        Obx(() {
          final partners = controller.deliveryPartners;
          if (partners.isEmpty) {
            // Docs require the carrier to come from GET /delivery-partners
            // (free-hand names leave tracking_url null); if the list ever
            // fails to load, fall back to a plain text field so the seller
            // isn't blocked.
            return AppTextField(
              label: 'Carrier',
              initialValue: controller.carrier.value,
              controller: TextEditingController(text: controller.carrier.value),
              onChanged: (v) => controller.carrier.value = v,
            );
          }
          return GestureDetector(
            onTap: () => _pickCarrier(context),
            child: AbsorbPointer(
              child: AppTextField(
                label: 'Carrier',
                placeholder: 'Choose a courier',
                controller: TextEditingController(
                  text: controller.carrier.value,
                ),
              ),
            ),
          );
        }),
        AppTextField(
          label: 'Tracking number',
          placeholder: 'TRK-00000',
          controller: trackingController,
          onChanged: (v) => controller.tracking.value = v,
        ),
        Obx(
          () => AppButton(
            label: controller.isSubmitting.value
                ? 'Marking as shipped…'
                : 'Mark as shipped',
            onPressed: controller.isSubmitting.value
                ? null
                : () async {
                    final updated = await controller.submitFulfilment();
                    if (updated != null && context.mounted) {
                      Navigator.of(context).pop();
                      AppMessenger.show(
                        !updated.needsPacking
                            ? 'Marked as shipped'
                            : 'Part of the order is on its way',
                      );
                    }
                  },
          ),
        ),
      ],
    );
  }

  void _pickCarrier(BuildContext context) {
    Get.bottomSheet(
      Builder(
        builder: (context) {
          final colors = context.colors;
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final partner in controller.deliveryPartners)
                  ListTile(
                    title: Text(
                      partner.name,
                      style: TextStyle(color: colors.ink),
                    ),
                    onTap: () {
                      controller.carrier.value = partner.name;
                      Get.back();
                    },
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
