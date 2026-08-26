import 'package:get/get.dart';

import '../../../../shared/models/team_member.dart';
import '../../../../shared/utils/app_messenger.dart';
import '../../domain/team_repository.dart';

class TeamController extends GetxController {
  final TeamRepository _repository;

  TeamController(this._repository);

  final isLoading = true.obs;
  final errorMessage = RxnString();
  final team = <TeamMember>[].obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    errorMessage.value = null;
    final result = await _repository.getTeam();
    result.when(
      success: (data) => team.assignAll(data),
      failure: (e) => errorMessage.value = e.message,
    );
    isLoading.value = false;
  }

  Future<bool> addMember({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    final result = await _repository.addMember(
      name: name,
      email: email,
      password: password,
      phone: phone,
    );
    return result.when(
      success: (m) {
        team.add(m);
        return true;
      },
      failure: (e) {
        AppMessenger.show(e.message);
        return false;
      },
    );
  }

  Future<bool> updateMember({
    required int id,
    required String name,
    required String email,
    String? phone,
  }) async {
    final result = await _repository.updateMember(
      id: id,
      name: name,
      email: email,
      phone: phone,
    );
    return result.when(
      success: (m) {
        final i = team.indexWhere((t) => t.id == id);
        if (i != -1) team[i] = m;
        return true;
      },
      failure: (e) {
        AppMessenger.show(e.message);
        return false;
      },
    );
  }

  Future<bool> toggleMember(int id) async {
    final result = await _repository.toggleMember(id);
    return result.when(
      success: (m) {
        final i = team.indexWhere((t) => t.id == id);
        if (i != -1) team[i] = m;
        return true;
      },
      failure: (e) {
        AppMessenger.show(e.message);
        return false;
      },
    );
  }

  Future<bool> removeMember(int id) async {
    final result = await _repository.removeMember(id);
    return result.when(
      success: (_) {
        team.removeWhere((t) => t.id == id);
        return true;
      },
      failure: (e) {
        AppMessenger.show(e.message);
        return false;
      },
    );
  }
}
