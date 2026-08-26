import '../../../core/network/network_result.dart';
import '../../../shared/models/payout.dart';

abstract class PayoutRepository {
  Future<NetworkResult<List<Payout>>> getPayouts({String? status});
  Future<NetworkResult<Payout>> getPayout(int id);
  Future<NetworkResult<Earnings>> getEarnings();
}
