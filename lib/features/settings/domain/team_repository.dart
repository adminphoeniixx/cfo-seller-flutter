import '../../../core/network/network_result.dart';
import '../../../shared/models/team_member.dart';

abstract class TeamRepository {
  Future<NetworkResult<List<TeamMember>>> getTeam();

  /// `POST /team` — `name, email, password, password_confirmation`, optional
  /// `phone`. Creates a new login on the caller's store.
  Future<NetworkResult<TeamMember>> addMember({
    required String name,
    required String email,
    required String password,
    String? phone,
  });

  /// `PUT /team/{id}` — `name, email`, optional `phone`.
  Future<NetworkResult<TeamMember>> updateMember({
    required int id,
    required String name,
    required String email,
    String? phone,
  });

  /// `PATCH /team/{id}/toggle` — switches access off/on, revoking tokens.
  /// `422` if targeting yourself or the store's last active login.
  Future<NetworkResult<TeamMember>> toggleMember(int id);

  /// `DELETE /team/{id}`. Same `422` guards as toggle.
  Future<NetworkResult<void>> removeMember(int id);
}
