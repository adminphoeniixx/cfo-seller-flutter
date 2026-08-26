/// Shape verified via curl against the live QA store (id 13) on 2026-08-22:
/// `GET /team` returns `{"data": [{id, name, email, phone, is_active,
/// is_you, created_at}, ...]}`. `POST`, `PUT` and `PATCH .../toggle` each
/// return `{"data": {...same shape...}}`. `DELETE` returns `{"deleted": true}`.
///
/// The docs described the caller flag as `is_you` and an active flag; the
/// live payload confirms both plus `phone` and `created_at`, which the
/// original prototype model didn't carry.
class TeamMember {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final bool isYou;
  final bool active;
  final DateTime? createdAt;

  const TeamMember({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.isYou,
    required this.active,
    this.createdAt,
  });

  factory TeamMember.fromJson(Map<String, dynamic> json) => TeamMember(
    id: json['id'] as int,
    name: json['name'] as String,
    email: json['email'] as String,
    phone: json['phone'] as String?,
    isYou: json['is_you'] as bool? ?? false,
    active: json['is_active'] as bool? ?? true,
    createdAt: json['created_at'] != null
        ? DateTime.tryParse(json['created_at'] as String)
        : null,
  );
}
