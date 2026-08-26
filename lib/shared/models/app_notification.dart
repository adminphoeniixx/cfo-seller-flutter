/// Matches `GET /notifications` row shape per the API docs.
///
/// ⚠️ Item-level fields (`title`/`body`/`url`/`tone`/`kind`/read state)
/// are NOT independently verified against a real sample — the QA account
/// has zero notifications and no reachable action in this audit produced
/// one (the only trigger available, raising a cancellation, correctly
/// 422'd: "Nothing is left to cancel" on the QA order's already-shipped
/// item). Parsing is deliberately defensive (every field nullable/
/// fallback-safe) until a real row can be inspected. What IS verified via
/// curl: the list envelope is a FLAT Laravel paginator with a top-level
/// `unread_count` — NOT the `{data, links{}, meta{}}` wrapper the docs
/// call "the standard shape" and that `/orders` and `/products` actually
/// use. `unread-count` and `read-all` both return `{"unread": N}`.
class AppNotification {
  final int id;
  final String title;
  final String body;
  final String? url;
  final String? tone;
  final String kind;
  final bool read;
  final DateTime? createdAt;

  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    this.url,
    this.tone,
    required this.kind,
    required this.read,
    this.createdAt,
  });

  AppNotification copyWith({bool? read}) => AppNotification(
    id: id,
    title: title,
    body: body,
    url: url,
    tone: tone,
    kind: kind,
    read: read ?? this.read,
    createdAt: createdAt,
  );

  factory AppNotification.fromJson(Map<String, dynamic> json) =>
      AppNotification(
        id: json['id'] as int,
        title: (json['title'] as String?) ?? '',
        body: (json['body'] as String?) ?? '',
        url: json['url'] as String?,
        tone: json['tone'] as String?,
        kind: (json['kind'] as String?) ?? 'unknown',
        // Neither a `read` boolean nor a `read_at` timestamp has been
        // observed on a real row — accept either shape defensively.
        read: (json['read'] as bool?) ?? (json['read_at'] != null),
        createdAt: json['created_at'] != null
            ? DateTime.tryParse(json['created_at'] as String)
            : null,
      );

  /// Relative-time label for the list row (e.g. "5m", "3h", "2d").
  String get when {
    final ts = createdAt;
    if (ts == null) return '';
    final diff = DateTime.now().difference(ts);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inHours < 1) return '${diff.inMinutes}m';
    if (diff.inDays < 1) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }
}

/// The flat Laravel paginator `/notifications` actually returns — verified
/// via curl, distinct from the `{data, links, meta}` shape used elsewhere.
class NotificationsPage {
  final List<AppNotification> data;
  final int currentPage;
  final int lastPage;
  final int total;
  final int unreadCount;

  const NotificationsPage({
    required this.data,
    required this.currentPage,
    required this.lastPage,
    required this.total,
    required this.unreadCount,
  });

  factory NotificationsPage.fromJson(Map<String, dynamic> json) =>
      NotificationsPage(
        data: (json['data'] as List)
            .map((n) => AppNotification.fromJson(n as Map<String, dynamic>))
            .toList(),
        currentPage: json['current_page'] as int,
        lastPage: json['last_page'] as int,
        total: json['total'] as int,
        unreadCount: json['unread_count'] as int,
      );
}
