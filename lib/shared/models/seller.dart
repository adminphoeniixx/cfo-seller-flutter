import 'store.dart';

/// The marketplace's role-matrix section keys, as documented and verified
/// against the live `sections` array on `GET /me`. Gates which trading
/// screens this login may open — see `SellerSection` usage in
/// `AuthController.hasSection`.
enum SellerSection {
  analytics,
  orders,
  cancellations,
  refunds,
  products,
  shipping,
  payouts,
  team,
}

SellerSection? _sectionFromString(String s) {
  for (final section in SellerSection.values) {
    if (section.name == s) return section;
  }
  return null; // unknown/future section key — ignored, not crashed on
}

/// Matches the real `seller` object returned by `POST /login`,
/// `POST /register`, `POST /refresh` (top-level) and `GET /me` (under
/// `data`) — verified against the live API on 2026-08-22.
class Seller {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final Set<SellerSection> sections;
  final Store store;

  const Seller({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.sections,
    required this.store,
  });

  factory Seller.fromJson(Map<String, dynamic> json) => Seller(
    id: json['id'] as int,
    name: json['name'] as String,
    email: json['email'] as String,
    phone: json['phone'] as String?,
    sections: (json['sections'] as List)
        .map((s) => _sectionFromString(s as String))
        .whereType<SellerSection>()
        .toSet(),
    store: Store.fromJson(json['store'] as Map<String, dynamic>),
  );

  bool hasSection(SellerSection section) => sections.contains(section);
}
