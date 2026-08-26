import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/models/payout.dart';
import '../../../../shared/widgets/widgets.dart';
import '../controllers/payout_detail_controller.dart';

class PayoutDetailScreen extends GetView<PayoutDetailController> {
  const PayoutDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final payout = controller.payout.value;
      return Scaffold(
        appBar: AppAppBar(
          title: payout?.reference ?? 'Payout',
          subtitle: payout != null
              ? '${payout.periodStart ?? '—'} → ${payout.periodEnd ?? '—'}'
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
    final payout = controller.payout.value;
    if (payout == null) {
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
            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colors.surface,
                border: Border.all(color: colors.line),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Column(
                children: [
                  Text(
                    'NET PAYOUT',
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.7,
                      color: colors.ink3,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    CurrencyFormatter.money(payout.net),
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1,
                      color: colors.ink,
                    ),
                  ),
                  const SizedBox(height: 4),
                  payout.status == PayoutStatus.paid
                      ? const AppStatusPill(
                          label: 'Paid',
                          variant: AppPillVariant.ok,
                        )
                      : payout.status == PayoutStatus.failed
                      ? const AppStatusPill(
                          label: 'Failed',
                          variant: AppPillVariant.crit,
                        )
                      : const AppStatusPill(
                          label: 'Processing',
                          variant: AppPillVariant.warn,
                        ),
                ],
              ),
            );
          },
        ),
        AppCard(
          child: Column(
            children: [
              AppMoneyRow(
                label: 'Gross sales',
                value: CurrencyFormatter.money(payout.grossSales),
              ),
              AppMoneyRow(
                label: 'Commission (10%)',
                value: '−${CurrencyFormatter.money(payout.commission)}',
              ),
              AppMoneyRow(
                label: 'Refunded to buyers',
                value: '−${CurrencyFormatter.money(payout.refunded)}',
              ),
              AppMoneyRow(
                label: 'Adjustments',
                value: CurrencyFormatter.money(0),
              ),
              AppMoneyRow(
                label: 'Net',
                value: CurrencyFormatter.money(payout.net),
                total: true,
              ),
            ],
          ),
        ),
        const AppSectionHeader(title: 'Covered'),
        AppCard(
          child: Column(
            children: [
              AppMoneyRow(
                label: 'Orders in this period',
                value: '${payout.ordersCount}',
              ),
              AppMoneyRow(
                label: 'Period',
                value:
                    '${payout.periodStart ?? '—'} – ${payout.periodEnd ?? '—'}',
              ),
            ],
          ),
        ),
      ],
    );
  }
}
