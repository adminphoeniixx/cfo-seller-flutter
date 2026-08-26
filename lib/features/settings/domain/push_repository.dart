import '../../../core/network/network_result.dart';

/// `GET /push` response shape — see the API docs' "Firebase push" section.
/// `firebase.enabled` must be checked before showing any push UI/toggle:
/// the server may have push wired up in general (`enabled`) without the
/// Firebase project side being configured yet.
class PushSettings {
  final bool enabled;
  final String? publicKey;
  final int devices;
  final bool firebaseEnabled;
  final String? firebaseProjectId;
  final int firebaseDevices;

  const PushSettings({
    required this.enabled,
    this.publicKey,
    required this.devices,
    required this.firebaseEnabled,
    this.firebaseProjectId,
    required this.firebaseDevices,
  });

  factory PushSettings.fromJson(Map<String, dynamic> json) {
    final firebase = json['firebase'] as Map<String, dynamic>?;
    return PushSettings(
      enabled: json['enabled'] as bool? ?? false,
      publicKey: json['public_key'] as String?,
      devices: json['devices'] as int? ?? 0,
      firebaseEnabled: firebase?['enabled'] as bool? ?? false,
      firebaseProjectId: firebase?['project_id'] as String?,
      firebaseDevices: firebase?['devices'] as int? ?? 0,
    );
  }
}

/// Seller-side FCM device registration — `/push/device` and `/push`, per
/// the API docs' "Firebase push" section (Postman folder "4 · Push").
abstract class PushRepository {
  /// `POST /push/device` — registers (or, if the token already exists,
  /// updates) this device's FCM token. [platform] defaults server-side to
  /// `android` if omitted.
  Future<NetworkResult<void>> registerDevice({
    required String token,
    String? platform,
    String? deviceName,
  });

  /// `DELETE /push/device` — call on sign-out so the server stops sending
  /// this device push after the session ends.
  Future<NetworkResult<void>> unregisterDevice(String token);

  /// `GET /push` — check `firebase.enabled` before showing any push UI.
  Future<NetworkResult<PushSettings>> getPushSettings();
}
