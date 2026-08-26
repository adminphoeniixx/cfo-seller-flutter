import '../../../core/network/api_client.dart';
import '../../../core/network/network_result.dart';
import '../../../shared/models/team_member.dart';
import '../domain/team_repository.dart';

/// Talks to the real `/team` endpoints. Full CRUD (list/add/update/toggle/
/// delete) verified via curl against the live QA store (id 13) on
/// 2026-08-22, including creating, updating, toggling and deleting a
/// disposable test login (`agent-test+teamphase@example.com`) end-to-end,
/// and confirming the documented `422` guard against deleting yourself.
/// See `team_member.dart`'s doc comment for the response shape.
class ApiTeamRepository implements TeamRepository {
  final ApiClient _client;

  ApiTeamRepository(this._client);

  @override
  Future<NetworkResult<List<TeamMember>>> getTeam() {
    return _client.get(
      '/team',
      parse: (json) => ((json as Map<String, dynamic>)['data'] as List)
          .map((e) => TeamMember.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  Future<NetworkResult<TeamMember>> addMember({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) {
    return _client.post(
      '/team',
      body: {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': password,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
      },
      parse: (json) => TeamMember.fromJson(
        (json as Map<String, dynamic>)['data'] as Map<String, dynamic>,
      ),
    );
  }

  @override
  Future<NetworkResult<TeamMember>> updateMember({
    required int id,
    required String name,
    required String email,
    String? phone,
  }) {
    return _client.put(
      '/team/$id',
      body: {
        'name': name,
        'email': email,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
      },
      parse: (json) => TeamMember.fromJson(
        (json as Map<String, dynamic>)['data'] as Map<String, dynamic>,
      ),
    );
  }

  @override
  Future<NetworkResult<TeamMember>> toggleMember(int id) {
    return _client.patch(
      '/team/$id/toggle',
      parse: (json) => TeamMember.fromJson(
        (json as Map<String, dynamic>)['data'] as Map<String, dynamic>,
      ),
    );
  }

  @override
  Future<NetworkResult<void>> removeMember(int id) {
    return _client.delete('/team/$id', parse: (_) {});
  }
}
