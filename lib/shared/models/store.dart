/// Matches the real `store` object nested in `GET /me`, `POST /login`,
/// `POST /register` and `POST /refresh` responses — verified against the
/// live API on 2026-08-22, not guessed from the docs alone.
enum StoreStatus { pending, approved, suspended, rejected, unknown }

StoreStatus _storeStatusFromString(String s) {
  switch (s) {
    case 'pending':
      return StoreStatus.pending;
    case 'approved':
      return StoreStatus.approved;
    case 'suspended':
      return StoreStatus.suspended;
    case 'rejected':
      return StoreStatus.rejected;
    default:
      return StoreStatus.unknown;
  }
}

class StoreAddress {
  final String? line1;
  final String? line2;
  final String? city;
  final String? state;
  final String? postcode;
  final String? country;

  const StoreAddress({
    this.line1,
    this.line2,
    this.city,
    this.state,
    this.postcode,
    this.country,
  });

  factory StoreAddress.fromJson(Map<String, dynamic> json) => StoreAddress(
    line1: json['line1'] as String?,
    line2: json['line2'] as String?,
    city: json['city'] as String?,
    state: json['state'] as String?,
    postcode: json['postcode'] as String?,
    country: json['country'] as String?,
  );
}

class StorePayoutDetails {
  final String? method;
  final String? accountName;
  final String? accountNumber;
  final String? ifsc;

  const StorePayoutDetails({
    this.method,
    this.accountName,
    this.accountNumber,
    this.ifsc,
  });

  factory StorePayoutDetails.fromJson(Map<String, dynamic> json) =>
      StorePayoutDetails(
        method: json['method'] as String?,
        accountName: json['account_name'] as String?,
        accountNumber: json['account_number'] as String?,
        ifsc: json['ifsc'] as String?,
      );
}

class Store {
  final int id;
  final String name;
  final String slug;
  final StoreStatus status;
  // Authoritative trading gate per the API docs — route on this, not on
  // `status == approved`, since a suspended/rejected store also has a
  // non-pending status but still cannot trade.
  final bool canTrade;
  final String? email;
  final String? phone;
  final String? logoUrl;
  final String? description;
  final String? contactName;
  final StoreAddress address;
  final String? gstNumber;
  final double commissionRate;
  final double rating;
  final StorePayoutDetails payout;
  final DateTime? approvedAt;
  final DateTime? createdAt;

  const Store({
    required this.id,
    required this.name,
    required this.slug,
    required this.status,
    required this.canTrade,
    this.email,
    this.phone,
    this.logoUrl,
    this.description,
    this.contactName,
    required this.address,
    this.gstNumber,
    required this.commissionRate,
    required this.rating,
    required this.payout,
    this.approvedAt,
    this.createdAt,
  });

  factory Store.fromJson(Map<String, dynamic> json) => Store(
    id: json['id'] as int,
    name: json['name'] as String,
    slug: json['slug'] as String,
    status: _storeStatusFromString(json['status'] as String),
    canTrade: json['can_trade'] as bool,
    email: json['email'] as String?,
    phone: json['phone'] as String?,
    logoUrl: json['logo_url'] as String?,
    description: json['description'] as String?,
    contactName: json['contact_name'] as String?,
    address: StoreAddress.fromJson(
      (json['address'] as Map<String, dynamic>?) ?? const {},
    ),
    gstNumber: json['gst_number'] as String?,
    commissionRate: (json['commission_rate'] as num).toDouble(),
    rating: (json['rating'] as num).toDouble(),
    payout: StorePayoutDetails.fromJson(
      (json['payout'] as Map<String, dynamic>?) ?? const {},
    ),
    approvedAt: json['approved_at'] != null
        ? DateTime.tryParse(json['approved_at'] as String)
        : null,
    createdAt: json['created_at'] != null
        ? DateTime.tryParse(json['created_at'] as String)
        : null,
  );
}
