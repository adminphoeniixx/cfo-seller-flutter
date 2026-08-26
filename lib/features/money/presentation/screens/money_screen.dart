import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/models/payout.dart';
import '../../../../shared/widgets/widgets.dart';
import '../controllers/money_controller.dart';

class MoneyScreen extends GetView<MoneyController> {
  const MoneyScreen({super.key});

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

      final payouts = controller.payouts;

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
                      'NOT YET PAID OUT',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.7,
                        color: colors.ink3,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      CurrencyFormatter.money(controller.unsettled),
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1,
                        color: colors.ink,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Earned, but not on a payout yet',
                      style: TextStyle(fontSize: 11.5, color: colors.ink3),
                    ),
                  ],
                ),
              );
            },
          ),
          AppKpiGrid(
            children: [
              AppKpiCard(
                label: 'Paid out',
                value: CurrencyFormatter.short(controller.paidTotal),
                valueFontSize: 17,
              ),
              AppKpiCard(
                label: 'In progress',
                value: CurrencyFormatter.short(controller.inProgressTotal),
                valueFontSize: 17,
              ),
            ],
          ),
          AppCard(
            child: Column(
              children: [
                AppMoneyRow(
                  label: 'Lifetime sales',
                  value: CurrencyFormatter.money(controller.lifetimeGrossSales),
                ),
                AppMoneyRow(
                  label:
                      'Commission (${controller.commissionRate.toStringAsFixed(0)}%)',
                  value:
                      '−${CurrencyFormatter.money(controller.lifetimeCommission)}',
                ),
                AppMoneyRow(
                  label: 'Lifetime earnings',
                  value: CurrencyFormatter.money(controller.lifetimeEarning),
                  total: true,
                ),
              ],
            ),
          ),
          const AppSectionHeader(title: 'Payouts'),
          payouts.isEmpty
              ? const AppEmptyState(
                  emoji: '💸',
                  message:
                      'No payouts yet. The marketplace raises these on a fortnightly cycle.',
                )
              : AppCard(
                  flat: true,
                  child: Column(
                    children: [
                      for (var i = 0; i < payouts.length; i++)
                        AppListRow(
                          title: payouts[i].reference,
                          titleTrailing: payouts[i].status == PayoutStatus.paid
                              ? const AppStatusPill(
                                  label: 'Paid',
                                  variant: AppPillVariant.ok,
                                )
                              : payouts[i].status == PayoutStatus.failed
                              ? const AppStatusPill(
                                  label: 'Failed',
                                  variant: AppPillVariant.crit,
                                )
                              : const AppStatusPill(
                                  label: 'Processing',
                                  variant: AppPillVariant.warn,
                                ),
                          subtitle:
                              '${payouts[i].periodStart ?? '—'}–${payouts[i].periodEnd ?? '—'} · ${payouts[i].ordersCount} orders',
                          amount: CurrencyFormatter.short(payouts[i].net),
                          showDivider: i != payouts.length - 1,
                          onTap: () => context.push(
                            AppRoutes.payoutDetailPath(payouts[i].id),
                          ),
                        ),
                    ],
                  ),
                ),
          Text(
            "Payouts are raised by the marketplace on a fortnightly cycle. There's nothing to request.",
            style: TextStyle(
              fontSize: 11.5,
              color: context.colors.ink3,
              height: 1.5,
            ),
          ),
        ],
      );
    });
  }
}
