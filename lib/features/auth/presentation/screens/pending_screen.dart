import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../shared/widgets/widgets.dart';
import '../controllers/auth_controller.dart';

class PendingScreen extends GetView<AuthController> {
  const PendingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Obx(() {
      final storeName = controller.store?.name ?? 'your store';

      return Scaffold(
        backgroundColor: colors.ground,
        appBar: AppAppBar(title: storeName, subtitle: 'Awaiting approval'),
        body: AppScreen(
          children: [
            AppCard(
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  Container(
                    width: 62,
                    height: 62,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: colors.warnBg,
                      borderRadius: AppRadius.rXl,
                    ),
                    child: Text(
                      '⏳',
                      style: TextStyle(fontSize: 27, color: colors.warnInk),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    "We're reviewing your store",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: colors.ink,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "You'll be able to add products and take orders as soon as an admin approves $storeName.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: colors.ink2,
                      height: 1.55,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
            const AppSectionHeader(title: 'Get ready'),
            AppCard(
              flat: true,
              child: Column(
                children: [
                  AppListRow(
                    title: 'Store details',
                    subtitle: 'Address, logo, description',
                    showChevron: true,
                    onTap: () => context.push(AppRoutes.storeDetails),
                  ),
                  AppListRow(
                    title: 'Payout account',
                    subtitle: 'Where we send your money',
                    trailing: const AppStatusPill(
                      label: 'Add',
                      variant: AppPillVariant.warn,
                    ),
                    onTap: () => context.push(AppRoutes.payoutAccount),
                  ),
                  AppListRow(
                    title: 'Your profile',
                    subtitle: 'Name, phone, password',
                    showChevron: true,
                    showDivider: false,
                    onTap: () => context.push(AppRoutes.profile),
                  ),
                ],
              ),
            ),
            // Approval happens on the marketplace side — there is no
            // seller-facing "approve" endpoint. This re-checks `/me` for a
            // status change instead of faking one.
            AppButton.ghost(
              label: 'Check again',
              onPressed: () async {
                await controller.refreshMe();
                if (context.mounted && controller.isApproved) {
                  context.go(AppRoutes.home);
                }
              },
            ),
            AppButton.danger(
              label: 'Sign out',
              onPressed: () async {
                await controller.signOut();
                if (context.mounted) context.go(AppRoutes.login);
              },
            ),
          ],
        ),
      );
    });
  }
}
