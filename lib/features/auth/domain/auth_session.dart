import '../../../shared/models/seller.dart';

/// `POST /login`, `POST /register` and `POST /refresh` all return this
/// exact shape at the TOP level — `{ token, seller }`, no `data` wrapper.
/// `GET /me` returns the same `seller` shape but wrapped in `{ "data": ... }`
/// instead — verified against the live API, these are genuinely different
/// envelopes, not an inconsistency to paper over.
class AuthSession {
  final String token;
  final Seller seller;

  const AuthSession({required this.token, required this.seller});

  factory AuthSession.fromJson(Map<String, dynamic> json) => AuthSession(
    token: json['token'] as String,
    seller: Seller.fromJson(json['seller'] as Map<String, dynamic>),
  );
}
