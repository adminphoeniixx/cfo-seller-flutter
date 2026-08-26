import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_controller.dart';
import '../../../../shared/models/store.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';

class AccountScreen extends GetView<AuthController> {
  const AccountScreen({super.key});

  static String _statusLabel(StoreStatus s) => switch (s) {
    StoreStatus.approved => 'Approved',
    StoreStatus.pending => 'Pending',
    StoreStatus.suspended => 'Suspended',
    StoreStatus.rejected => 'Rejected',
    StoreStatus.unknown => 'Unknown',
  };

  static AppPillVariant _statusVariant(StoreStatus s) => switch (s) {
    StoreStatus.approved => AppPillVariant.ok,
    StoreStatus.pending => AppPillVariant.warn,
    StoreStatus.suspended || StoreStatus.rejected => AppPillVariant.crit,
    StoreStatus.unknown => AppPillVariant.mute,
  };

  static String _commissionLabel(double rate) =>
      rate % 1 == 0 ? '${rate.toInt()}%' : '${rate.toStringAsFixed(1)}%';

  static String _maskedAccount(String? number) {
    if (number == null || number.length < 4) return 'Add';
    return '••••${number.substring(number.length - 4)}';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Obx(() {
      final store = controller.store;

      return AppScreen(
        children: [
          AppCard(
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: colors.surface2,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: const Text('🧵', style: TextStyle(fontSize: 20)),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        store?.name ?? '',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: colors.ink,
                        ),
                      ),
                      Text(
                        store?.email ?? '',
                        style: TextStyle(fontSize: 11.5, color: colors.ink3),
                      ),
                    ],
                  ),
                ),
                if (store != null)
                  AppStatusPill(
                    label: _statusLabel(store.status),
                    variant: _statusVariant(store.status),
                  ),
              ],
            ),
          ),
          const AppSectionHeader(title: 'Store'),
          AppCard(
            flat: true,
            child: Column(
              children: [
                AppListRow(
                  title: 'Store details',
                  showChevron: true,
                  onTap: () => context.push(AppRoutes.storeDetails),
                ),
                AppListRow(
                  title: 'Payout account',
                  subtitle: _maskedAccount(store?.payout.accountNumber) == 'Add'
                      ? null
                      : _maskedAccount(store?.payout.accountNumber),
                  trailing: _maskedAccount(store?.payout.accountNumber) == 'Add'
                      ? const AppStatusPill(
                          label: 'Add',
                          variant: AppPillVariant.warn,
                        )
                      : null,
                  showChevron: true,
                  onTap: () => context.push(AppRoutes.payoutAccount),
                ),
                AppListRow(
                  title: 'Delivery charges',
                  subtitle: 'Your rates per zone',
                  showChevron: true,
                  onTap: () => context.push(AppRoutes.shipping),
                ),
                AppListRow(
                  title: 'Team',
                  subtitle: 'Logins on this store',
                  showChevron: true,
                  onTap: () => context.push(AppRoutes.team),
                ),
                AppListRow(
                  title: 'Commission',
                  subtitle: 'Set by the marketplace',
                  amount: store != null
                      ? _commissionLabel(store.commissionRate)
                      : null,
                  showDivider: false,
                ),
              ],
            ),
          ),
          const AppSectionHeader(title: 'Preferences'),
          Obx(() {
            final theme = Get.find<ThemeController>();
            String label(ThemeMode m) => switch (m) {
              ThemeMode.dark => 'Dark',
              ThemeMode.light => 'Light',
              ThemeMode.system => 'System',
            };
            return AppTapField(
              label: 'Appearance',
              value: label(theme.mode.value),
              onTap: () {
                switch (theme.mode.value) {
                  case ThemeMode.dark:
                    theme.setLight();
                    break;
                  case ThemeMode.light:
                    theme.setSystem();
                    break;
                  case ThemeMode.system:
                    theme.setDark();
                    break;
                }
              },
            );
          }),
          const AppSectionHeader(title: 'You'),
          AppCard(
            flat: true,
            child: Column(
              children: [
                AppListRow(
                  title: 'Name, phone, email',
                  showChevron: true,
                  onTap: () => context.push(AppRoutes.profile),
                ),
                AppListRow(
                  title: 'Change password',
                  showChevron: true,
                  onTap: () => context.push(AppRoutes.password),
                ),
                AppListRow(
                  title: 'Signed-in devices',
                  showChevron: true,
                  showDivider: false,
                  onTap: () => context.push(AppRoutes.devices),
                ),
              ],
            ),
          ),
          AppButton.ghost(
            label: 'Sign out',
            onPressed: () async {
              await controller.signOut();
              if (context.mounted) context.go(AppRoutes.login);
            },
          ),
        ],
      );
    });
  }
}
