import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:seller_app/app/app.dart';
import 'package:seller_app/app/bootstrap/app_bindings.dart';
import 'package:seller_app/core/analytics/analytics_service.dart';
import 'package:seller_app/app/router/app_router.dart';
import 'package:seller_app/app/router/app_routes.dart';
import 'package:seller_app/core/network/network_result.dart';
import 'package:seller_app/core/push/push_service.dart';
import 'package:seller_app/features/auth/domain/auth_repository.dart';
import 'package:seller_app/features/auth/domain/auth_session.dart';
import 'package:seller_app/features/home/domain/dashboard_repository.dart';
import 'package:seller_app/features/money/domain/payout_repository.dart';
import 'package:seller_app/features/notifications/domain/notification_repository.dart';
import 'package:seller_app/features/orders/domain/order_repository.dart';
import 'package:seller_app/features/products/domain/product_repository.dart';
import 'package:seller_app/features/requests/domain/request_repository.dart';
import 'package:seller_app/features/settings/domain/device_repository.dart';
import 'package:seller_app/features/settings/domain/shipping_repository.dart';
import 'package:seller_app/features/settings/domain/store_repository.dart';
import 'package:seller_app/features/settings/domain/team_repository.dart';
import 'package:seller_app/shared/models/app_notification.dart';
import 'package:seller_app/shared/models/dashboard.dart';
import 'package:seller_app/shared/models/device.dart';
import 'package:seller_app/shared/models/order.dart';
import 'package:seller_app/shared/models/payout.dart';
import 'package:seller_app/shared/models/product.dart';
import 'package:seller_app/shared/models/product_payload.dart';
import 'package:seller_app/shared/models/seller.dart';
import 'package:seller_app/shared/models/service_request.dart';
import 'package:seller_app/shared/models/shipping_rate.dart';
import 'package:seller_app/shared/models/store.dart';
import 'package:seller_app/shared/models/team_member.dart';

/// `pumpAndSettle()` never returns while an `AppLoading` (indeterminate
/// `CircularProgressIndicator`) is on screen — its animation never settles.
/// Every mock repository call has an artificial delay to simulate a network
/// round trip, so screens always show that spinner briefly. Pump a fixed
/// duration past the longest mock delay instead.
Future<void> settlePastLoading(WidgetTester tester) async {
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

/// `TokenStorage`/`DeviceNameProvider` go through `flutter_secure_storage`,
/// which has no platform implementation in the widget-test environment —
/// without this, its method channel call never returns and `signIn()`
/// hangs forever. Backs it with an in-memory map instead, scoped per test
/// via `setUp`/`tearDown` so no state leaks between tests.
void _mockSecureStorage() {
  const channel = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
  final memory = <String, String>{};
  TestWidgetsFlutterBinding.ensureInitialized().defaultBinaryMessenger
      .setMockMethodCallHandler(channel, (call) async {
        switch (call.method) {
          case 'read':
            return memory[call.arguments['key']];
          case 'write':
            memory[call.arguments['key'] as String] =
                call.arguments['value'] as String;
            return null;
          case 'delete':
            memory.remove(call.arguments['key']);
            return null;
          case 'readAll':
            return memory;
          case 'deleteAll':
            memory.clear();
            return null;
          case 'containsKey':
            return memory.containsKey(call.arguments['key']);
          default:
            return null;
        }
      });
}

/// This is the EXACT JSON returned by the live `POST /login` endpoint —
/// captured via curl against the QA environment on 2026-08-22 (see
/// ApiAuthRepository's own doc comments for the same verification). Widget
/// tests use a fake repository built from this real shape rather than
/// hitting the network directly, so they stay fast and deterministic while
/// still parsing genuine server data through the real `Seller.fromJson`.
const _realLoginJson = {
  'token': '2|rSxYvmlO2prJVhBsdq0R55gw8J1O8rUdv2A3tv1Kb10d6506',
  'seller': {
    'id': 3,
    'name': 'QA Seller',
    'email': 'qa-seller@cfomarketplace.test',
    'phone': '9000000001',
    'sections': [
      'analytics',
      'orders',
      'cancellations',
      'refunds',
      'products',
      'shipping',
      'payouts',
      'team',
    ],
    'store': {
      'id': 13,
      'name': 'QA Test Store',
      'slug': 'qa-test-store-ffkj',
      'status': 'approved',
      'can_trade': true,
      'email': 'qa@teststore.test',
      'phone': '9000000001',
      'logo_url': null,
      'description': null,
      'contact_name': 'QA Seller',
      'address': {
        'line1': null,
        'line2': null,
        'city': null,
        'state': null,
        'postcode': null,
        'country': 'IN',
      },
      'gst_number': '33AAPFU0939F1ZV',
      'commission_rate': 10,
      'rating': 0,
      'payout': {
        'method': 'bank',
        'account_name': null,
        'account_number': null,
        'ifsc': null,
      },
      'approved_at': '2026-08-07T07:35:48+00:00',
      'created_at': '2026-08-07T07:18:30+00:00',
    },
  },
};

class _FakeStoreRepository implements StoreRepository {
  @override
  Future<NetworkResult<Store>> getStore() async => Success(
    Store.fromJson(
      (_realLoginJson['seller']! as Map<String, dynamic>)['store']
          as Map<String, dynamic>,
    ),
  );

  @override
  Future<NetworkResult<Store>> updateStore({
    required String name,
    String? storeEmail,
    String? phone,
    String? description,
    String? addressLine1,
    String? city,
    String? state,
    String? postcode,
    String? country,
    String? gstNumber,
    String? payoutMethod,
    String? bankAccountName,
    String? bankAccountNumber,
    String? bankIfsc,
  }) async => Success(
    Store.fromJson(
      (_realLoginJson['seller']! as Map<String, dynamic>)['store']
          as Map<String, dynamic>,
    ),
  );
}

/// Real `GET /dashboard?days=30` and `GET /analytics/sales?days=7` bodies —
/// captured via curl against the QA environment on 2026-08-22.
const _realDashboardJson = {
  'range_days': 30,
  'totals': {'sales': 9998, 'earning': 8998.2, 'orders': 1, 'units': 2},
  'needs_attention': {
    'unfulfilled_orders': 0,
    'pending_cancellations': 0,
    'pending_refunds': 0,
    'low_stock_products': 0,
  },
  'top_products': [
    {'name': 'QA TEST — Kanchipuram silk saree', 'units': 2, 'revenue': 9998},
  ],
};

const _realSalesSeriesJson = {
  'from': '2026-08-16',
  'to': '2026-08-22',
  'days': 7,
  'totals': {'sales': 0, 'earning': 0, 'orders': 0, 'units': 0},
  'series': [
    {'date': '2026-08-16', 'sales': 0, 'earning': 0, 'orders': 0, 'units': 0},
    {'date': '2026-08-17', 'sales': 0, 'earning': 0, 'orders': 0, 'units': 0},
    {'date': '2026-08-18', 'sales': 0, 'earning': 0, 'orders': 0, 'units': 0},
    {'date': '2026-08-19', 'sales': 0, 'earning': 0, 'orders': 0, 'units': 0},
    {'date': '2026-08-20', 'sales': 0, 'earning': 0, 'orders': 0, 'units': 0},
    {'date': '2026-08-21', 'sales': 0, 'earning': 0, 'orders': 0, 'units': 0},
    {'date': '2026-08-22', 'sales': 0, 'earning': 0, 'orders': 0, 'units': 0},
  ],
};

class _FakeDashboardRepository implements DashboardRepository {
  @override
  Future<NetworkResult<Dashboard>> getDashboard({int days = 30}) async =>
      Success(Dashboard.fromJson(_realDashboardJson));

  @override
  Future<NetworkResult<SalesSeries>> getSalesSeries({int days = 30}) async =>
      Success(SalesSeries.fromJson(_realSalesSeriesJson));
}

class _FakeAuthRepository implements AuthRepository {
  @override
  Future<NetworkResult<AuthSession>> login({
    required String email,
    required String password,
    required String deviceName,
  }) async {
    return Success(AuthSession.fromJson(_realLoginJson));
  }

  @override
  Future<NetworkResult<Seller>> me() async => Success(
    Seller.fromJson(_realLoginJson['seller'] as Map<String, dynamic>),
  );

  @override
  Future<NetworkResult<AuthSession>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    required String storeName,
    required String deviceName,
    String? phone,
    String? storeEmail,
    String? gstNumber,
  }) async => Success(AuthSession.fromJson(_realLoginJson));

  @override
  Future<NetworkResult<void>> forgotPassword({required String email}) async =>
      const Success(null);

  @override
  Future<NetworkResult<void>> resetPassword({
    required String token,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async => const Success(null);

  @override
  Future<NetworkResult<AuthSession>> refresh({String? deviceName}) async =>
      Success(AuthSession.fromJson(_realLoginJson));

  @override
  Future<NetworkResult<void>> logout() async => const Success(null);

  @override
  Future<NetworkResult<void>> logoutAll() async => const Success(null);

  @override
  Future<NetworkResult<Seller>> updateMe({
    required String name,
    required String email,
    String? phone,
  }) async => Success(
    Seller.fromJson(_realLoginJson['seller'] as Map<String, dynamic>),
  );

  @override
  Future<NetworkResult<void>> updatePassword({
    required String currentPassword,
    required String password,
    required String passwordConfirmation,
  }) async => const Success(null);
}

class _FakeNotificationRepository implements NotificationRepository {
  @override
  Future<NetworkResult<NotificationsPage>> getNotifications({
    String? filter,
    String? kind,
    int perPage = 25,
  }) async => const Success(
    NotificationsPage(
      data: [],
      currentPage: 1,
      lastPage: 1,
      total: 0,
      unreadCount: 0,
    ),
  );

  @override
  Future<NetworkResult<int>> getUnreadCount() async => const Success(0);

  @override
  Future<NetworkResult<int>> markAllRead() async => const Success(0);

  @override
  Future<NetworkResult<void>> markRead(int id) async => const Success(null);

  @override
  Future<NetworkResult<void>> delete(int id) async => const Success(null);
}

/// The EXACT JSON returned by the live `GET /orders/{id}` (order #161) —
/// captured via curl against the QA environment on 2026-08-22, see
/// `ApiOrderRepository`'s doc comment for the full verification notes.
/// `quantity_fulfilled` is set to `0` here (the live order was fully
/// packed by the time this test was written) purely so the fixture
/// exercises the "needs packing" / fulfil flow — every other field is the
/// real captured shape, parsed through the real `Order.fromJson`.
const _realOrderJson = {
  'id': 161,
  'number': '#1161',
  'status': 'processing',
  'payment_status': 'paid',
  'fulfillment_status': 'unfulfilled',
  'payment_method': 'UPI',
  'shipping_method': null,
  'carrier': null,
  'tracking_number': null,
  'tracking_url': null,
  'customer': {'name': 'QA Buyer', 'phone': '9000000009'},
  'shipping_address': {
    'first_name': 'QA',
    'last_name': 'Buyer',
    'address_line1': '42 Beach Road',
    'city': 'Chennai',
    'state': 'Tamil Nadu',
    'postcode': '600090',
    'country': 'IN',
    'phone': '9000000009',
  },
  'customer_note': 'QA TEST ORDER — safe to delete',
  'items': [
    {
      'id': 395,
      'product_id': 48,
      'product_variant_id': null,
      'name': 'QA TEST — Kanchipuram silk saree',
      'sku': 'QATEST-1',
      'image_url': null,
      'options': null,
      'unit_price': 4999,
      'quantity': 2,
      'quantity_cancelled': 0,
      'quantity_refunded': 0,
      'quantity_fulfilled': 0,
      'fulfillment_status': 'unfulfilled',
      'tax_amount': 0,
      'total': 9998,
      'commission_rate': 10,
      'commission_amount': 999.8,
      'earning': 8998.2,
    },
  ],
  'totals': {'items': 9998, 'tax': 0, 'commission': 999.8, 'earning': 8998.2},
  'placed_at': '2026-08-07T10:29:25+00:00',
  'shipped_at': null,
  'created_at': '2026-08-07T10:29:25+00:00',
};

class _FakeOrderRepository implements OrderRepository {
  @override
  Future<NetworkResult<OrdersPage>> getOrders({
    String? status,
    bool? needsPacking,
    String? search,
    int page = 1,
  }) async => Success(
    OrdersPage.fromJson({
      'data': [_realOrderJson],
      'meta': {'current_page': 1, 'last_page': 1, 'total': 1},
    }),
  );

  @override
  Future<NetworkResult<OrdersSummary>> getSummary() async => const Success(
    OrdersSummary(statuses: {'pending': 0, 'processing': 1}, unfulfilled: 1),
  );

  @override
  Future<NetworkResult<Order>> getOrder(int id) async =>
      Success(Order.fromJson(_realOrderJson));

  @override
  Future<NetworkResult<Order>> fulfilOrder(
    int id, {
    required Map<int, int> quantityByItemId,
    required String carrier,
    required String tracking,
  }) async => Success(Order.fromJson(_realOrderJson));

  @override
  Future<NetworkResult<void>> addNote(int id, String note) async =>
      const Success(null);

  @override
  Future<NetworkResult<List<DeliveryPartner>>> getDeliveryPartners() async =>
      Success([
        DeliveryPartner.fromJson({
          'id': 1,
          'name': 'Delhivery',
          'has_tracking': true,
        }),
      ]);
}

// Real `GET /shipping/zones` and `GET /shipping/rates` shapes, captured
// 2026-08-22 against the live QA store (see `shipping_rate.dart`'s doc
// comment). The QA store had configured no rates of its own, so every rate
// is the marketplace's fallback (`is_marketplace: true, editable: false`).
const _realShippingZonesJson = [
  {
    'id': 1,
    'name': 'Domestic – India',
    'description': 'All PIN codes across India.',
    'countries': ['IN'],
    'states': [],
  },
  {
    'id': 2,
    'name': 'Metro cities',
    'description': 'Faster network in tier-1 metros.',
    'countries': ['IN'],
    'states': [
      'Delhi',
      'Maharashtra',
      'Karnataka',
      'Tamil Nadu',
      'Telangana',
      'West Bengal',
    ],
  },
];
const _realShippingRatesJson = [
  {
    'id': 1,
    'zone': {'id': 1, 'name': 'Domestic – India'},
    'name': 'Standard delivery',
    'type': 'flat',
    'rate': 59,
    'per_item_rate': 0,
    'per_kg_rate': 0,
    'min_order_amount': null,
    'max_order_amount': null,
    'free_above_amount': 999,
    'delivery_days': {'min': 4, 'max': 7},
    'is_active': true,
    'position': 0,
    'is_marketplace': true,
    'editable': false,
  },
];

class _FakeShippingRepository implements ShippingRepository {
  @override
  Future<NetworkResult<List<ShippingZone>>> getZones() async {
    final zones = _realShippingZonesJson
        .map((e) => ShippingZone.fromJson(e))
        .toList();
    final rates = _realShippingRatesJson
        .map((e) => ShippingRate.fromJson(e))
        .toList();
    return Success(ShippingZone.merge(zones, rates));
  }
}

// Real `GET /products/48` shape, captured 2026-08-22 against the live QA
// store (see `product.dart`'s doc comment).
const _realProductJson = {
  'id': 48,
  'name': 'QA TEST — Kanchipuram silk saree',
  'slug': 'qa-test-kanchipuram-silk-saree',
  'sku': 'QATEST-1',
  'barcode': null,
  'type': 'simple',
  'status': 'active',
  'is_featured': false,
  'brand': null,
  'short_description': null,
  'description': null,
  'price': 4999,
  'compare_at_price': null,
  'cost_price': null,
  'inventory': {
    'tracked': true,
    'quantity': 20,
    'low_stock_threshold': 3,
    'allow_backorder': false,
    'status': 'in_stock',
  },
  'shipping': {
    'required': true,
    'weight': 0,
    'length': null,
    'width': null,
    'height': null,
  },
  'category_id': null,
  'tax_class_id': null,
  'category_ids': [],
  'attribute_ids': [],
  'tags': [],
  'seo': {'title': null, 'description': null},
  'images': [],
  'variants': [],
  'published_at': '2026-08-07T10:29:24+00:00',
  'created_at': '2026-08-07T10:29:24+00:00',
  'updated_at': '2026-08-07T10:29:24+00:00',
};

class _FakeProductRepository implements ProductRepository {
  @override
  Future<NetworkResult<ProductsPage>> getProducts({
    String? status,
    String? search,
    bool? lowStock,
    int page = 1,
  }) async => Success(
    ProductsPage.fromJson({
      'data': [_realProductJson],
      'meta': {'current_page': 1, 'last_page': 1, 'total': 1},
    }),
  );

  @override
  Future<NetworkResult<Product>> getProduct(int id) async =>
      Success(Product.fromJson(_realProductJson));

  @override
  Future<NetworkResult<Product>> toggleStatus(
    int id, {
    required bool active,
  }) async => Success(Product.fromJson(_realProductJson));

  @override
  Future<NetworkResult<void>> deleteProduct(int id) async =>
      const Success(null);

  @override
  Future<NetworkResult<Product>> createProduct(ProductPayload payload) async =>
      Success(Product.fromJson(_realProductJson));

  @override
  Future<NetworkResult<Product>> updateProduct(
    int id,
    ProductPayload payload,
  ) async => Success(Product.fromJson(_realProductJson));

  @override
  Future<NetworkResult<Product>> updateStock(
    int id, {
    required int stock,
    int? lowStockThreshold,
  }) async => Success(Product.fromJson(_realProductJson));
}

/// `GET /payouts/earnings` is CURL-VERIFIED against the live QA seller on
/// 2026-08-22 — this is the exact captured body (see `ApiPayoutRepository`'s
/// doc comment). The individual payout below (`_realPayoutJson`) is NOT
/// curl-verified: the QA seller has no payout on record yet (its one
/// lifetime order hasn't been raised into a payout by the marketplace), so
/// `GET /payouts` genuinely returns an empty page. This fixture is a
/// best-effort stand-in built from `Payout.fromJson`'s documented field
/// inference, used only so the money/payout-detail screens have something
/// to render in tests — see `shared/models/payout.dart` for the full
/// discrepancy note and what to re-verify once a real payout exists.
const _realEarningsJson = {
  'lifetime': {
    'gross_sales': 9998,
    'commission': 999.8,
    'earning': 8998.2,
    'orders': 1,
  },
  'payouts': {'paid': 0, 'in_progress': 0, 'unsettled': 8998.2},
  'commission_rate': 10,
};

const _realPayoutJson = {
  'id': 42,
  'reference': 'PAY-00042',
  'status': 'paid',
  'period_start': '1 Jul',
  'period_end': '15 Jul',
  'orders_count': 24,
  'gross_sales': 47000,
  'commission': 4700,
  'refunded': 0,
  'earning': 42300,
};

class _FakePayoutRepository implements PayoutRepository {
  @override
  Future<NetworkResult<List<Payout>>> getPayouts({String? status}) async =>
      Success([Payout.fromJson(_realPayoutJson)]);

  @override
  Future<NetworkResult<Payout>> getPayout(int id) async =>
      Success(Payout.fromJson(_realPayoutJson));

  @override
  Future<NetworkResult<Earnings>> getEarnings() async =>
      Success(Earnings.fromJson(_realEarningsJson));
}

/// `GET /cancellations` and `GET /refunds` are CURL-VERIFIED against the
/// live QA seller on 2026-08-22 — both genuinely returned `{"data": [], ...}`
/// (the QA account's only order/item is fully shipped, so nothing is
/// eligible to cancel or refund). The single cancellation fixture below is
/// NOT curl-verified: no real cancellation/refund resource body was ever
/// returned to inspect, so this is a best-effort stand-in built from
/// `ServiceRequest.fromJson`'s documented field inference, used only so
/// the requests list/detail screens have something to render in tests —
/// see `shared/models/service_request.dart` for the full discrepancy note.
const _realCancellationJson = {
  'id': 17,
  'order_id': 161,
  'status': 'pending',
  'created_at': '2026-08-05T10:00:00+00:00',
  'reason': 'out_of_stock',
  'reason_label': 'Out of stock',
  'requested_by': 'vendor',
  'note': 'Stock count was wrong — please cancel before packing.',
  'items': [
    {
      'order_item_id': 395,
      'name': 'QA TEST — Kanchipuram silk saree',
      'sku': 'QATEST-1',
      'quantity': 1,
      'unit_price': 4999,
      'total': 4999,
    },
  ],
  'refund_requested': true,
  'restock': false,
  'amount': 4999,
};

class _FakeRequestRepository implements RequestRepository {
  @override
  Future<NetworkResult<List<ServiceRequest>>> getRequests() async => Success([
    ServiceRequest.fromJson(_realCancellationJson, RequestKind.cancellation),
  ]);

  @override
  Future<NetworkResult<ServiceRequest>> getRequest(int routeId) async =>
      Success(
        ServiceRequest.fromJson(
          _realCancellationJson,
          RequestKind.cancellation,
        ),
      );

  @override
  Future<NetworkResult<ServiceRequest>> respond(
    int routeId,
    String message,
  ) async => Success(
    ServiceRequest.fromJson(_realCancellationJson, RequestKind.cancellation),
  );
}

const _realTeamMemberJson = {
  'id': 3,
  'name': 'QA Seller',
  'email': 'qa-seller@cfomarketplace.test',
  'phone': '9000000001',
  'is_you': true,
  'is_active': true,
  'created_at': '2026-08-07T07:18:30+00:00',
};

class _FakeTeamRepository implements TeamRepository {
  @override
  Future<NetworkResult<List<TeamMember>>> getTeam() async =>
      Success([TeamMember.fromJson(_realTeamMemberJson)]);

  @override
  Future<NetworkResult<TeamMember>> addMember({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async => Success(TeamMember.fromJson(_realTeamMemberJson));

  @override
  Future<NetworkResult<TeamMember>> updateMember({
    required int id,
    required String name,
    required String email,
    String? phone,
  }) async => Success(TeamMember.fromJson(_realTeamMemberJson));

  @override
  Future<NetworkResult<TeamMember>> toggleMember(int id) async =>
      Success(TeamMember.fromJson(_realTeamMemberJson));

  @override
  Future<NetworkResult<void>> removeMember(int id) async => const Success(null);
}

// Real `GET /devices` shape, captured 2026-08-22 against the live QA store:
// two devices, `current: true` on the one making the call, a nullable
// `last_used_at` for a token issued but never yet used (see
// `shared/models/device.dart`'s doc comment).
const _realDevicesJson = [
  {
    'id': 14,
    'name': 'agent-main-device',
    'last_used_at': '2026-08-22T08:56:37+00:00',
    'created_at': '2026-08-22T08:56:26+00:00',
    'current': true,
  },
  {
    'id': 13,
    'name': 'agent-test',
    'last_used_at': '2026-08-22T08:33:01+00:00',
    'created_at': '2026-08-22T08:32:18+00:00',
    'current': false,
  },
];

class _FakeDeviceRepository implements DeviceRepository {
  @override
  Future<NetworkResult<List<Device>>> getDevices() async =>
      Success(_realDevicesJson.map((e) => Device.fromJson(e)).toList());

  @override
  Future<NetworkResult<void>> revokeDevice(int id) async => const Success(null);
}

/// `AnalyticsService` wraps `FirebaseAnalytics.instance`, which requires a
/// real `Firebase.initializeApp()` call — never made in the widget-test
/// environment (no platform channel to back it). This fake no-ops every
/// event method and hands back a plain `NavigatorObserver` (rather than a
/// `FirebaseAnalyticsObserver`, which would need a real `FirebaseAnalytics`
/// instance) so nothing here ever touches Firebase.
class _FakeAnalyticsService implements AnalyticsService {
  @override
  Future<void> logLogin() async {}

  @override
  Future<void> logSignUp() async {}

  @override
  Future<void> logOrderFulfilled({required int orderId}) async {}

  @override
  Future<void> setUserId(String? id) async {}

  @override
  NavigatorObserver get navigatorObserver => NavigatorObserver();
}

/// `FcmPushService` wraps `FirebaseMessaging.instance`, which — like
/// `FirebaseAnalytics.instance` above — requires a real
/// `Firebase.initializeApp()` call never made in the widget-test
/// environment. `AuthController.signIn()`/`signOut()` call into
/// `PushService` directly, so this no-op fake is injected via
/// `AppBindings.init()`'s `pushService` param the same way
/// `_FakeAnalyticsService` is, rather than relying on `Get.find` picking up
/// a real `FcmPushService` that would throw the moment a test taps "Sign
/// in".
class _FakePushService implements PushService {
  @override
  Future<void> initializeAfterSignIn() async {}

  @override
  Future<void> handleInitialMessage() async {}

  @override
  Future<void> unregisterCurrentDevice() async {}

  @override
  void dispose() {}
}

void main() {
  setUp(_mockSecureStorage);

  testWidgets('App boots to the sign-in screen', (WidgetTester tester) async {
    AppBindings.init(
      authRepository: _FakeAuthRepository(),
      storeRepository: _FakeStoreRepository(),
      dashboardRepository: _FakeDashboardRepository(),
      analyticsService: _FakeAnalyticsService(),
      pushService: _FakePushService(),
    );
    await tester.pumpWidget(const SellerApp());
    await tester.pumpAndSettle();

    expect(find.text('Sign in'), findsWidgets);
  });

  // One continuous test: `AppRouter.router` is a `static final` singleton,
  // constructed once per isolate and reused across every `pumpWidget` call
  // in this file. A second `pumpWidget(SellerApp())` in a fresh testWidgets
  // block pairs a brand-new AuthController with that stale, already-
  // navigated router and hangs — so everything stays in one test.
  testWidgets('Signed-in user can reach every tab and key detail screens', (
    WidgetTester tester,
  ) async {
    AppBindings.init(
      authRepository: _FakeAuthRepository(),
      storeRepository: _FakeStoreRepository(),
      dashboardRepository: _FakeDashboardRepository(),
      analyticsService: _FakeAnalyticsService(),
      pushService: _FakePushService(),
    );
    // NotificationsController is `lazyPut(fenix: true)`, so a post-hoc
    // `Get.put` here (before it's first constructed) is sufficient —
    // unlike the eagerly-built AuthController, which needs its fake
    // injected via `AppBindings.init()`'s named params instead.
    // `AppBindings.init()` already registered the real `ApiNotificationRepository`
    // as `permanent: true` (in test 1, since this suite shares one isolate);
    // a plain `Get.put` does not override an existing permanent registration,
    // so it must be deleted first.
    await Get.delete<NotificationRepository>(force: true);
    Get.put<NotificationRepository>(
      _FakeNotificationRepository(),
      permanent: true,
    );
    // Same story for OrderRepository: `AppBindings.init()` already put the
    // real `ApiOrderRepository` (permanent), so it must be deleted first.
    await Get.delete<OrderRepository>(force: true);
    Get.put<OrderRepository>(_FakeOrderRepository(), permanent: true);
    // Same story for ProductRepository: `AppBindings.init()` already put
    // the real `ApiProductRepository` (permanent), so it must be deleted
    // first.
    await Get.delete<ProductRepository>(force: true);
    Get.put<ProductRepository>(_FakeProductRepository(), permanent: true);
    // Same story for PayoutRepository: `AppBindings.init()` already put the
    // real `ApiPayoutRepository` (permanent), so it must be deleted first.
    await Get.delete<PayoutRepository>(force: true);
    Get.put<PayoutRepository>(_FakePayoutRepository(), permanent: true);
    // Same story for RequestRepository: `AppBindings.init()` already put
    // the real `ApiRequestRepository` (permanent), so it must be deleted
    // first.
    await Get.delete<RequestRepository>(force: true);
    Get.put<RequestRepository>(_FakeRequestRepository(), permanent: true);
    // Same story for ShippingRepository: `AppBindings.init()` already put
    // the real `ApiShippingRepository` (permanent), so it must be deleted
    // first.
    await Get.delete<ShippingRepository>(force: true);
    Get.put<ShippingRepository>(_FakeShippingRepository(), permanent: true);
    // Same story for TeamRepository: `AppBindings.init()` already put the
    // real `ApiTeamRepository` (permanent), so it must be deleted first.
    await Get.delete<TeamRepository>(force: true);
    Get.put<TeamRepository>(_FakeTeamRepository(), permanent: true);
    // Same story for DeviceRepository: `AppBindings.init()` already put the
    // real `ApiDeviceRepository` (permanent), so it must be deleted first.
    await Get.delete<DeviceRepository>(force: true);
    Get.put<DeviceRepository>(_FakeDeviceRepository(), permanent: true);
    await tester.pumpWidget(const SellerApp());
    await tester.pumpAndSettle();

    // Real tap on the actual Sign in button — exercises the widget tree,
    // hit-testing, and the app-bar/navigation wiring a real tap would. The
    // fake repository behind it returns the REAL verified `/login` shape.
    await tester.enterText(
      find.byType(TextField).at(0),
      'qa-seller@cfomarketplace.test',
    );
    await tester.enterText(find.byType(TextField).at(1), 'secret-password');
    await tester.tap(find.text('Sign in'));
    await settlePastLoading(tester);
    expect(
      find.text('SALES'),
      findsOneWidget,
    ); // Home KPI label (rendered uppercase)
    expect(
      find.text('QA Test Store'),
      findsOneWidget,
    ); // app bar title = real store name

    final router = AppRouter.router;

    router.go(AppRoutes.orders);
    await settlePastLoading(tester);
    expect(
      find.text('1 to pack'),
      findsOneWidget,
    ); // reactive subtitle, not hardcoded
    expect(find.text('#1161'), findsOneWidget);

    router.go(AppRoutes.products);
    await settlePastLoading(tester);
    expect(find.text('1 listed'), findsOneWidget);
    expect(find.text('Add a product'), findsOneWidget);

    router.go(AppRoutes.money);
    await settlePastLoading(tester);
    expect(
      find.text('PAYOUTS'),
      findsOneWidget,
    ); // AppSectionHeader renders uppercase
    expect(find.text('PAY-00042'), findsOneWidget);

    // Regression check for the nested-shell-route double-app-bar bug:
    // exactly one Scaffold means the shell's tab bar was fully replaced,
    // not stacked behind the detail screen's own app bar.
    router.push(AppRoutes.payoutDetailPath(42));
    await settlePastLoading(tester);
    expect(find.byType(Scaffold), findsOneWidget);
    expect(
      find.text('PAY-00042'),
      findsOneWidget,
    ); // now the dynamic app-bar title
    expect(find.text('COVERED'), findsOneWidget);

    router.go(AppRoutes.orders);
    await settlePastLoading(tester);
    router.push(AppRoutes.orderDetailPath(161));
    await settlePastLoading(tester);
    expect(find.byType(Scaffold), findsOneWidget);
    expect(find.text('#1161'), findsOneWidget);
    expect(find.text('Pack & ship'), findsOneWidget);

    router.push(AppRoutes.orderFulfilPath(161));
    await settlePastLoading(tester);
    expect(find.text('Mark as shipped'), findsOneWidget);
    expect(find.byType(Scaffold), findsOneWidget);

    router.go(AppRoutes.products);
    await settlePastLoading(tester);
    router.push(AppRoutes.productDetailPath(48));
    await settlePastLoading(tester);
    expect(find.byType(Scaffold), findsOneWidget);
    expect(
      find.text('MINE-1'),
      findsNothing,
    ); // sanity: real product 48 sku is QATEST-1, not MINE-1
    expect(find.text('QATEST-1'), findsOneWidget); // dynamic app-bar subtitle
    expect(find.text('Delete this product'), findsOneWidget);

    router.push(AppRoutes.newProduct);
    await settlePastLoading(tester);
    // The form now has a single Save action (status is a form field, not a
    // second save button) — see `NewProductScreen`'s doc comment.
    expect(find.text('New product'), findsOneWidget);
    expect(find.text('Save'), findsOneWidget);

    router.push(AppRoutes.notifications);
    await settlePastLoading(tester);
    // The real API's item-level shape is unverified (no sample obtainable),
    // so the fake repository returns an empty page — assert the empty state.
    expect(find.text("You're all caught up."), findsOneWidget);
    expect(find.text('Mark all read'), findsOneWidget);

    router.push(AppRoutes.requests);
    await settlePastLoading(tester);
    expect(find.text('CAN-00017'), findsOneWidget);
    router.push(AppRoutes.requestDetailPath(17));
    await settlePastLoading(tester);
    expect(find.text('Send response'), findsOneWidget);

    router.push(AppRoutes.account);
    await settlePastLoading(tester);
    expect(find.text('Sign out'), findsOneWidget);
    expect(
      find.text('APPEARANCE'),
      findsOneWidget,
    ); // AppTapField label renders uppercase
    expect(
      find.text('Approved'),
      findsOneWidget,
    ); // real store.status, not hardcoded

    router.push(AppRoutes.team);
    await settlePastLoading(tester);
    expect(find.text('QA Seller'), findsOneWidget);
    expect(find.text('Add a login'), findsOneWidget);

    router.push(AppRoutes.shipping);
    await settlePastLoading(tester);
    expect(
      find.text('DOMESTIC – INDIA'),
      findsOneWidget,
    ); // AppSectionHeader renders uppercase; real zone name
    expect(
      find.text('Marketplace'),
      findsOneWidget,
    ); // non-editable rate pill (QA store has no rates of its own)

    router.push(AppRoutes.storeDetails);
    await settlePastLoading(tester);
    expect(
      find.text('QA Test Store'),
      findsOneWidget,
    ); // real GET /store data via StoreController
    expect(find.text('Save'), findsOneWidget);

    router.push(AppRoutes.devices);
    await settlePastLoading(tester);
    expect(find.text('agent-main-device'), findsOneWidget);
    expect(
      find.text('This device'),
      findsOneWidget,
    ); // pill on the current: true device
    expect(find.text('agent-test'), findsOneWidget);
    expect(
      find.text('Sign out'),
      findsOneWidget,
    ); // per-device revoke on the non-current row
    expect(find.text('Sign out everywhere'), findsOneWidget);
  });
}
