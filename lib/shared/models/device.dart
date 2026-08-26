/// Shape verified via curl against the live QA store (id 13) on 2026-08-22:
/// `GET /devices` returns `{"data": [{id, name, last_used_at, created_at,
/// current}, ...]}`. `DELETE /devices/{id}` returns `{"message": "Device
/// signed out."}` (no body worth parsing).
///
/// The docs only promised `current: true` on the calling device; the live
/// payload confirms `name`, `created_at` and a nullable `last_used_at`
/// (null for a token that was issued but never yet used to make a call)
/// alongside it.
class Device {
  final int id;
  final String name;
  final bool current;
  final DateTime? createdAt;
  final DateTime? lastUsedAt;

  const Device({
    required this.id,
    required this.name,
    required this.current,
    this.createdAt,
    this.lastUsedAt,
  });

  factory Device.fromJson(Map<String, dynamic> json) => Device(
    id: json['id'] as int,
    name: json['name'] as String,
    current: json['current'] as bool? ?? false,
    createdAt: json['created_at'] != null
        ? DateTime.tryParse(json['created_at'] as String)
        : null,
    lastUsedAt: json['last_used_at'] != null
        ? DateTime.tryParse(json['last_used_at'] as String)
        : null,
  );
}
