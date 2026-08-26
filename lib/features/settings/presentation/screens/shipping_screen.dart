import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/utils/app_messenger.dart';
import '../../../../shared/widgets/widgets.dart';
import '../controllers/shipping_controller.dart';

class ShippingScreen extends GetView<ShippingController> {
  const ShippingScreen({super.key});

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

      final zones = controller.zones;

      return AppScreen(
        children: [
          for (final zone in zones) ...[
            AppSectionHeader(title: zone.zone),
            AppCard(
              flat: true,
              child: Column(
                children: [
                  for (var i = 0; i < zone.rates.length; i++)
                    AppListRow(
                      title: zone.rates[i].name,
                      titleTrailing: zone.rates[i].editable
                          ? null
                          : const AppStatusPill(
                              label: 'Marketplace',
                              variant: AppPillVariant.mute,
                            ),
                      subtitle: zone.rates[i].detail,
                      amount: zone.rates[i].rate == 0
                          ? 'Free'
                          : CurrencyFormatter.short(zone.rates[i].rate),
                      showChevron: zone.rates[i].editable,
                      showDivider: i != zone.rates.length - 1,
                      onTap: zone.rates[i].editable
                          ? () => AppMessenger.show(
                              'Not part of this preview yet',
                            )
                          : null,
                    ),
                ],
              ),
            ),
          ],
          Text(
            "Rates marked Marketplace are the marketplace's own fallback — they apply where you haven't set your own, and you can't change them.",
            style: TextStyle(
              fontSize: 11.5,
              color: context.colors.ink3,
              height: 1.5,
            ),
          ),
          AppButton(
            label: 'Add a rate',
            onPressed: () => AppMessenger.show('Not part of this preview yet'),
          ),
        ],
      );
    });
  }
}
