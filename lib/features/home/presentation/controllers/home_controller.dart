import 'package:get/get.dart';

import '../../../../shared/models/dashboard.dart';
import '../../domain/dashboard_repository.dart';

/// Home screen state — both calls come from `DashboardRepository`, backed
/// by the real `GET /dashboard` and `GET /analytics/sales`. Verified via
/// curl on 2026-08-22: `top_products` carries only `name`/`units`/`revenue`
/// (no product id), so — unlike the prototype's mock data — a best-seller
/// row cannot deep-link to that product's detail screen; the API simply
/// doesn't return one.
class HomeController extends GetxController {
  final DashboardRepository _repository;

  HomeController(this._repository);

  final isLoading = true.obs;
  final errorMessage = RxnString();
  final Rxn<Dashboard> dashboard = Rxn<Dashboard>();
  final Rxn<SalesSeries> salesSeries = Rxn<SalesSeries>();

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    errorMessage.value = null;

    final dashboardResult = await _repository.getDashboard(days: 30);
    final seriesResult = await _repository.getSalesSeries(days: 30);

    dashboardResult.when(
      success: (d) => dashboard.value = d,
      failure: (e) => errorMessage.value = e.message,
    );
    seriesResult.when(
      success: (s) => salesSeries.value = s,
      failure: (e) => errorMessage.value = e.message,
    );

    isLoading.value = false;
  }

  int get toPackCount => dashboard.value?.needsAttention.unfulfilledOrders ?? 0;
  int get lowStockCount =>
      dashboard.value?.needsAttention.lowStockProducts ?? 0;
  int get pendingRequestsCount =>
      (dashboard.value?.needsAttention.pendingCancellations ?? 0) +
      (dashboard.value?.needsAttention.pendingRefunds ?? 0);
  List<TopProduct> get bestSellers => dashboard.value?.topProducts ?? const [];

  /// Bar heights as a 0–100 percentage of the series' own peak, for the
  /// sales sparkline — mirrors the prototype's hand-picked bar heights but
  /// derived from real numbers instead.
  List<double> get sparkBarHeights {
    final points = salesSeries.value?.series ?? const [];
    if (points.isEmpty) return const [];
    final peak = points
        .map((p) => p.sales)
        .fold<double>(0, (a, b) => a > b ? a : b);
    if (peak == 0) {
      return points
          .map((_) => 4.0)
          .toList(); // flat baseline, not invisible bars
    }
    return points.map((p) => (p.sales / peak) * 100).toList();
  }
}
