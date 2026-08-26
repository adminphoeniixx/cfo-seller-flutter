import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_icons.dart';
import '../../shared/widgets/app_app_bar.dart';
import '../../shared/widgets/app_bottom_navigation.dart';
import '../auth/presentation/controllers/auth_controller.dart';
import '../notifications/presentation/controllers/notifications_controller.dart';
import '../orders/presentation/controllers/orders_controller.dart';
import '../products/presentation/controllers/products_controller.dart';

const _tabs = [
  AppTabItem(label: 'Home', iconAsset: AppIcons.homeAsset),
  AppTabItem(label: 'Orders', iconAsset: AppIcons.ordersAsset),
  AppTabItem(label: 'Products', iconAsset: AppIcons.productsAsset),
  AppTabItem(label: 'Money', iconAsset: AppIcons.moneyAsset),
];

/// Hosts the 4-tab bottom navigation (Home/Orders/Products/Money) plus the
/// shared dark chrome app bar with bell + account actions — reproduces the
/// prototype's `chrome: 'main'` screens sharing one `.tabbar`. Title and
/// subtitle per tab mirror `screens.home/orders/products/money()` in the
/// prototype (store name + "Last 30 days", "N to pack", "N listed", none).
class MainShell extends StatelessWidget {
  final int currentIndex;
  final Widget child;
  final ValueChanged<int> onTabTap;
  final VoidCallback onBell;
  final VoidCallback onAccount;

  const MainShell({
    super.key,
    required this.currentIndex,
    required this.child,
    required this.onTabTap,
    required this.onBell,
    required this.onAccount,
  });

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    final orders = Get.find<OrdersController>();
    final products = Get.find<ProductsController>();
    final notifications = Get.find<NotificationsController>();

    return Obx(() {
      String title;
      String? subtitle;
      switch (currentIndex) {
        case 0:
          title = auth.store?.name ?? '';
          subtitle = 'Last 30 days';
          break;
        case 1:
          title = 'Orders';
          subtitle = '${orders.toPackCount} to pack';
          break;
        case 2:
          title = 'Products';
          subtitle = '${products.totalCount.value} listed';
          break;
        default:
          title = 'Money';
          subtitle = null;
      }

      return Scaffold(
        backgroundColor: context.colors.ground,
        appBar: AppAppBar(
          title: title,
          subtitle: subtitle,
          showBell: true,
          unreadCount: notifications.unreadCount.value,
          onBell: onBell,
          showAccount: true,
          onAccount: onAccount,
        ),
        body: child,
        bottomNavigationBar: AppBottomNavigation(
          items: _tabs,
          currentIndex: currentIndex,
          onTap: onTabTap,
        ),
      );
    });
  }
}
