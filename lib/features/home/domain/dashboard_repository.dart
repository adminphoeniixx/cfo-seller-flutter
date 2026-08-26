import '../../../core/network/network_result.dart';
import '../../../shared/models/dashboard.dart';

abstract class DashboardRepository {
  Future<NetworkResult<Dashboard>> getDashboard({int days = 30});
  Future<NetworkResult<SalesSeries>> getSalesSeries({int days = 30});
}
