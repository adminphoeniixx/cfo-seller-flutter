import 'package:get/get.dart';

import '../../core/analytics/analytics_service.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_interceptor.dart';
import '../../core/network/token_storage.dart';
import '../../core/push/fcm_push_service.dart';
import '../../core/push/push_service.dart';
import '../../core/theme/theme_controller.dart';
import '../../core/utils/device_name_provider.dart';
import '../../features/auth/data/api_auth_repository.dart';
import '../../features/auth/domain/auth_repository.dart';
import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../../features/home/data/api_dashboard_repository.dart';
import '../../features/home/domain/dashboard_repository.dart';
import '../../features/home/presentation/controllers/home_controller.dart';
import '../../features/money/data/api_payout_repository.dart';
import '../../features/money/domain/payout_repository.dart';
import '../../features/money/presentation/controllers/money_controller.dart';
import '../../features/notifications/data/api_notification_repository.dart';
import '../../features/notifications/domain/notification_repository.dart';
import '../../features/notifications/presentation/controllers/notifications_controller.dart';
import '../../features/orders/data/api_order_repository.dart';
import '../../features/orders/domain/order_repository.dart';
import '../../features/orders/presentation/controllers/orders_controller.dart';
import '../../features/products/data/api_catalog_repository.dart';
import '../../features/products/data/api_product_repository.dart';
import '../../features/products/data/api_upload_repository.dart';
import '../../features/products/domain/catalog_repository.dart';
import '../../features/products/domain/product_repository.dart';
import '../../features/products/domain/upload_repository.dart';
import '../../features/products/presentation/controllers/products_controller.dart';
import '../../features/requests/data/api_request_repository.dart';
import '../../features/requests/domain/request_repository.dart';
import '../../features/requests/presentation/controllers/requests_controller.dart';
import '../../features/settings/data/api_device_repository.dart';
import '../../features/settings/data/api_push_repository.dart';
import '../../features/settings/data/api_shipping_repository.dart';
import '../../features/settings/data/api_store_repository.dart';
import '../../features/settings/data/api_team_repository.dart';
import '../../features/settings/domain/device_repository.dart';
import '../../features/settings/domain/push_repository.dart';
import '../../features/settings/domain/shipping_repository.dart';
import '../../features/settings/domain/store_repository.dart';
import '../../features/settings/domain/team_repository.dart';
import '../../features/settings/presentation/controllers/device_controller.dart';
import '../../features/settings/presentation/controllers/shipping_controller.dart';
import '../../features/settings/presentation/controllers/store_controller.dart';
import '../../features/settings/presentation/controllers/team_controller.dart';

/// Registers every singleton the app needs at startup.
///
/// Every repository below is wired to the REAL seller API (Auth through
/// Devices, Phases 1–11 of the integration) — each `Api*Repository` was
/// verified against the live server via curl before being wired in.
/// `PushRepository`/`PushService` (Phase 12) are wired for real too, but
/// against Firebase project `seller-910c9`, not the `cfo-hub-5e4fb` project
/// the marketplace server actually sends push through — see
/// `PushService`'s doc comment.
///
/// Repositories are permanent singletons; list/detail controllers are
/// `lazyPut(fenix: true)` so they instantiate (and hit their repository's
/// `onInit` load) only when their screen is first reached, not at app
/// startup — see the widget_test regression this guarded against.
class AppBindings {
  const AppBindings._();

  /// [authRepository]/[storeRepository] let tests substitute a fake before
  /// any controller is constructed — replacing the registration with
  /// `Get.put` *after* `init()` doesn't work, because `AuthController`
  /// already captured whatever was registered at its own construction time
  /// a few lines below.
  static void init({
    AuthRepository? authRepository,
    StoreRepository? storeRepository,
    DashboardRepository? dashboardRepository,
    AnalyticsService? analyticsService,
    PushService? pushService,
  }) {
    Get.put(ThemeController(), permanent: true);
    Get.put(analyticsService ?? AnalyticsService(), permanent: true);

    // --- Real network stack ---
    final tokenStorage = TokenStorage();
    Get.put(tokenStorage, permanent: true);
    Get.put(DeviceNameProvider(), permanent: true);
    Get.put(ApiInterceptor(tokenStorage), permanent: true);
    Get.put(ApiClient(interceptor: Get.find()), permanent: true);

    // --- Auth + Store + Dashboard + Notifications + Orders + Products +
    // Money/Payouts + Requests (cancellations/refunds): real API ---
    Get.put<AuthRepository>(
      authRepository ?? ApiAuthRepository(Get.find()),
      permanent: true,
    );
    Get.put<StoreRepository>(
      storeRepository ?? ApiStoreRepository(Get.find()),
      permanent: true,
    );
    Get.put<DashboardRepository>(
      dashboardRepository ?? ApiDashboardRepository(Get.find()),
      permanent: true,
    );
    Get.put<OrderRepository>(ApiOrderRepository(Get.find()), permanent: true);
    Get.put<ProductRepository>(
      ApiProductRepository(Get.find()),
      permanent: true,
    );
    Get.put<CatalogRepository>(
      ApiCatalogRepository(Get.find()),
      permanent: true,
    );
    Get.put<UploadRepository>(
      ApiUploadRepository(Get.find()),
      permanent: true,
    );
    Get.put<PayoutRepository>(ApiPayoutRepository(Get.find()), permanent: true);
    Get.put<RequestRepository>(
      ApiRequestRepository(Get.find()),
      permanent: true,
    );
    Get.put<NotificationRepository>(
      ApiNotificationRepository(Get.find()),
      permanent: true,
    );

    // --- Shipping + Team + Devices: real API ---
    Get.put<TeamRepository>(ApiTeamRepository(Get.find()), permanent: true);
    Get.put<ShippingRepository>(
      ApiShippingRepository(Get.find()),
      permanent: true,
    );
    Get.put<DeviceRepository>(ApiDeviceRepository(Get.find()), permanent: true);

    // --- Push (FCM): real API, wired against Firebase project
    // `seller-910c9` for now — see PushService's doc comment for the
    // planned swap to the marketplace's actual push project, `cfo-hub-5e4fb`.
    Get.put<PushRepository>(ApiPushRepository(Get.find()), permanent: true);
    Get.put<PushService>(
      pushService ?? FcmPushService(Get.find(), Get.find()),
      permanent: true,
    );

    // Eager: needed immediately for the router's `redirect` guard.
    Get.put(
      AuthController(Get.find(), Get.find(), Get.find()),
      permanent: true,
    );

    // Lazy: these hit the network on `onInit`, so they must not spin up
    // until their screen is actually reached post sign-in.
    Get.lazyPut(() => OrdersController(Get.find()), fenix: true);
    Get.lazyPut(() => HomeController(Get.find()), fenix: true);
    Get.lazyPut(() => ProductsController(Get.find()), fenix: true);
    Get.lazyPut(() => MoneyController(Get.find()), fenix: true);
    Get.lazyPut(() => RequestsController(Get.find()), fenix: true);
    Get.lazyPut(() => NotificationsController(Get.find()), fenix: true);
    Get.lazyPut(() => TeamController(Get.find()), fenix: true);
    Get.lazyPut(() => ShippingController(Get.find()), fenix: true);
    Get.lazyPut(() => DeviceController(Get.find()), fenix: true);
    Get.lazyPut(() => StoreController(Get.find(), Get.find()), fenix: true);
  }
}
