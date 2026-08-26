/// Maps a notification's `url` (as sent by `GET /notifications` rows and by
/// FCM `data.url`, per the API docs — same field, same value, both sourced
/// from the same server-side notification record) to an in-app GoRouter
/// path.
///
/// Single source of truth for that mapping — used by the in-app
/// notifications list (tapping a row) AND by [PushService] (tapping a push
/// notification, whether the app was foregrounded, backgrounded, or
/// terminated), so the two never drift into two different behaviors for
/// the same `kind`/`url`.
class PushRouteMapper {
  const PushRouteMapper._();

  /// The server already sends a ready-to-use in-app path (e.g.
  /// `/orders/order/91`, matching `AppRoutes.orderDetailPath`), so this is
  /// deliberately a pass-through rather than a `kind`-keyed rebuild: it
  /// exists as one named place to route through/extend (e.g. to validate
  /// the path, or fall back by `kind` if a future payload omits `url`)
  /// rather than every call site doing `context.push(data['url'])` itself.
  static String? resolve({String? url, String? kind}) {
    if (url == null || url.isEmpty) return null;
    // Defensive: only ever navigate to a path internal to this app.
    if (!url.startsWith('/')) return null;
    return url;
  }
}
