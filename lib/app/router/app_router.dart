import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../../core/analytics/analytics_service.dart';
import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/pending_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/reset_password_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/money/domain/payout_repository.dart';
import '../../features/money/presentation/controllers/payout_detail_controller.dart';
import '../../features/money/presentation/screens/money_screen.dart';
import '../../features/money/presentation/screens/payout_detail_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/orders/domain/order_repository.dart';
import '../../features/orders/presentation/controllers/order_detail_controller.dart';
import '../../features/orders/presentation/screens/order_detail_screen.dart';
import '../../features/orders/presentation/screens/order_fulfil_screen.dart';
import '../../features/orders/presentation/screens/orders_screen.dart';
import '../../features/products/domain/product_repository.dart';
import '../../features/products/presentation/controllers/new_product_controller.dart';
import '../../features/products/presentation/controllers/product_detail_controller.dart';
import '../../features/products/presentation/screens/new_product_screen.dart';
import '../../features/products/presentation/screens/product_detail_screen.dart';
import '../../features/products/presentation/screens/products_screen.dart';
import '../../features/requests/domain/request_repository.dart';
import '../../features/requests/presentation/controllers/request_detail_controller.dart';
import '../../features/requests/presentation/screens/request_detail_screen.dart';
import '../../features/requests/presentation/screens/requests_screen.dart';
import '../../features/settings/presentation/screens/account_screen.dart';
import '../../features/settings/presentation/screens/devices_screen.dart';
import '../../features/settings/presentation/screens/password_screen.dart';
import '../../features/settings/presentation/screens/payout_account_screen.dart';
import '../../features/settings/presentation/screens/profile_screen.dart';
import '../../features/settings/presentation/screens/shipping_screen.dart';
import '../../features/settings/presentation/screens/store_details_screen.dart';
import '../../features/settings/presentation/screens/team_add_screen.dart';
import '../../features/settings/presentation/screens/team_screen.dart';
import '../../features/shell/main_shell.dart';
import '../../shared/utils/app_messenger.dart';
import '../../shared/widgets/app_app_bar.dart';
import 'app_routes.dart';

/// Every non-tab screen (order/product/payout/request detail, notifications,
/// account and its sub-screens) is a TOP-LEVEL route — a sibling of the
/// StatefulShellRoute, not nested inside one of its branches. Nesting them
/// inside a branch was tried first and produced a double app bar: the
/// shell's persistent chrome plus the detail screen's own, because the
/// prototype's `chrome: 'back'` screens replace the ENTIRE chrome (tab bar
/// included), not just the body. Top-level routes push onto the root
/// Navigator, so the shell (and its tab bar) is fully covered, matching
/// `render()` in the prototype swapping the whole `.screen` including
/// `chrome`.
class AppRouter {
  const AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.login,
    observers: [Get.find<AnalyticsService>().navigatorObserver],
    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.resetPassword,
        builder: (context, state) => ResetPasswordScreen(
          initialEmail: state.uri.queryParameters['email'],
          initialToken: state.uri.queryParameters['token'],
        ),
      ),
      GoRoute(
        path: AppRoutes.pending,
        builder: (context, state) => const PendingScreen(),
      ),

      GoRoute(
        path: AppRoutes.notifications,
        builder: (context, state) => const _SimpleScaffold(
          title: 'Notifications',
          child: NotificationsScreen(),
        ),
      ),

      GoRoute(
        path: AppRoutes.requests,
        builder: (context, state) => const _SimpleScaffold(
          title: 'Requests',
          subtitle: 'Cancellations & refunds',
          child: RequestsScreen(),
        ),
        routes: [
          GoRoute(
            path: 'request/:id',
            builder: (context, state) {
              final id = int.parse(state.pathParameters['id']!);
              Get.put(
                RequestDetailController(Get.find<RequestRepository>(), id),
              );
              return const RequestDetailScreen();
            },
          ),
        ],
      ),

      GoRoute(
        path: AppRoutes.account,
        builder: (context, state) =>
            const _SimpleScaffold(title: 'Account', child: AccountScreen()),
        routes: [
          // Owns its own Scaffold/AppAppBar/Save wiring — it calls the real
          // PUT /store, so a generic _SimpleScaffold "Save" that just pops
          // and shows a toast (no API call) would be a fake success.
          GoRoute(
            path: 'store-details',
            builder: (context, state) => const StoreDetailsScreen(),
          ),
          GoRoute(
            path: 'payout-account',
            builder: (context, state) => const PayoutAccountScreen(),
          ),
          GoRoute(
            path: 'shipping',
            builder: (context, state) => const _SimpleScaffold(
              title: 'Delivery charges',
              subtitle: 'Your rates per zone',
              child: ShippingScreen(),
            ),
          ),
          GoRoute(
            path: 'team',
            builder: (context, state) => const _SimpleScaffold(
              title: 'Team',
              subtitle: 'Logins on this store',
              child: TeamScreen(),
            ),
            routes: [
              GoRoute(
                path: 'add',
                builder: (context, state) => const _SimpleScaffold(
                  title: 'Add a login',
                  showSave: true,
                  closeStyle: true,
                  child: TeamAddScreen(),
                ),
              ),
            ],
          ),
          GoRoute(
            path: 'profile',
            builder: (context, state) => const _SimpleScaffold(
              title: 'Your profile',
              showSave: true,
              child: ProfileScreen(),
            ),
          ),
          GoRoute(
            path: 'password',
            builder: (context, state) => const _SimpleScaffold(
              title: 'Change password',
              child: PasswordScreen(),
            ),
          ),
          GoRoute(
            path: 'devices',
            builder: (context, state) => const _SimpleScaffold(
              title: 'Signed-in devices',
              child: DevicesScreen(),
            ),
          ),
        ],
      ),

      // These four own their app bar directly (title depends on data that
      // loads asynchronously after the route builds — e.g. "#338908", a
      // product's name, a payout number — so a static _SimpleScaffold
      // title wouldn't update once the controller finishes loading).
      GoRoute(
        path: '/orders/order/:id',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          Get.put(OrderDetailController(Get.find<OrderRepository>(), id));
          return const OrderDetailScreen();
        },
        routes: [
          GoRoute(
            path: 'fulfil',
            builder: (context, state) => const OrderFulfilScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/products/product/:id',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          Get.put(ProductDetailController(Get.find<ProductRepository>(), id));
          return const ProductDetailScreen();
        },
      ),
      GoRoute(
        path: '/money/payout/:id',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          Get.put(PayoutDetailController(Get.find<PayoutRepository>(), id));
          return const PayoutDetailScreen();
        },
      ),

      GoRoute(
        path: '/products/new',
        builder: (context, state) {
          Get.put(NewProductController(Get.find<ProductRepository>()));
          return const _SimpleScaffold(
            title: 'New product',
            showSave: true,
            closeStyle: true,
            child: NewProductScreen(),
          );
        },
      ),

      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) {
          return MainShell(
            currentIndex: shell.currentIndex,
            onTabTap: shell.goBranch,
            onBell: () => context.push(AppRoutes.notifications),
            onAccount: () => context.push(AppRoutes.account),
            child: shell,
          );
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.orders,
                builder: (context, state) => const OrdersScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.products,
                builder: (context, state) => const ProductsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.money,
                builder: (context, state) => const MoneyScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
    redirect: (context, state) {
      final auth = Get.find<AuthController>();
      final signedIn = auth.isSignedIn.value;
      final atAuthScreen =
          state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.register ||
          state.matchedLocation == AppRoutes.forgotPassword ||
          state.matchedLocation == AppRoutes.resetPassword;

      if (!signedIn && !atAuthScreen) return AppRoutes.login;
      if (signedIn && atAuthScreen) {
        return auth.isApproved ? AppRoutes.home : AppRoutes.pending;
      }
      return null;
    },
    refreshListenable: _AuthListenable(),
  );
}

/// Bridges GetX's reactive `isSignedIn` to GoRouter's `Listenable`-based
/// refresh so sign-in/sign-out immediately re-evaluates `redirect`.
class _AuthListenable extends ChangeNotifier {
  _AuthListenable() {
    ever(Get.find<AuthController>().isSignedIn, (_) => notifyListeners());
  }
}

/// Lightweight `chrome: 'back'` / `chrome: 'back-save'` / `chrome: 'close-save'`
/// wrapper for every top-level detail/settings route, reproducing the
/// prototype's dark app bar consistently and — critically — replacing the
/// shell's chrome entirely (no bottom tab bar) as the prototype does.
class _SimpleScaffold extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;
  final bool showSave;
  final bool closeStyle;

  const _SimpleScaffold({
    required this.title,
    this.subtitle,
    required this.child,
    this.showSave = false,
    this.closeStyle = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppAppBar(
        title: title,
        subtitle: subtitle,
        showBack: true,
        closeStyle: closeStyle,
        onBack: () => Navigator.of(context).pop(),
        showSave: showSave,
        onSave: showSave
            ? () {
                Navigator.of(context).pop();
                AppMessenger.show('Saved');
              }
            : null,
      ),
      body: child,
    );
  }
}
