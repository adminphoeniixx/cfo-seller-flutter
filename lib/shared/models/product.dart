/// Matches `GET /products`, `GET /products/{id}`, `POST /products`,
/// `PUT /products/{id}`, `PATCH /products/{id}/status` and
/// `PATCH /products/{id}/stock` response shapes — verified via curl against
/// the live QA store on 2026-08-22 (product #48 "QA TEST — Kanchipuram silk
/// saree", and a scratch product #49 created/updated/deleted during
/// verification). Replaces the earlier flat prototype shape (`stock`,
/// `low` as bare top-level fields, a fake `emoji`/`category` string) with
/// the real nested API shape (`inventory{...}`, `shipping{...}`,
/// `category_id`, `seo{...}`, `images[]`).
///
/// Discrepancies vs the docs found while integrating:
/// - The docs don't say `stock_quantity` alone turns tracking on: posting
///   `{"stock_quantity": 10}` without `track_inventory: true` came back
///   with `inventory.tracked: false` (quantity still saved). The Postman
///   sample request under "Products/Create (simple)" does send
///   `track_inventory: true` explicitly, so callers must always send it.
/// - The API has no `emoji` field at all (products carry real `images[]`
///   instead) — [Product.emoji] is a fixed placeholder keyed off
///   [ProductType], matching the same pattern used for [OrderItem.emoji].
/// - `category` is not a string on the wire, only `category_id` (nullable)
///   plus a separate `category_ids[]` for secondary categories and a
///   `GET /catalog/categories` lookup to resolve names. The product
///   screens here don't yet expose a category picker (still a stub
///   "Not part of this preview yet" tap target), so [Product.category] is
///   just a placeholder derived from whether `category_id` is set, not a
///   real resolved name.
library;

enum ProductStatus { active, draft, archived }

enum ProductType { simple, variable }

ProductStatus _statusFromString(String? s) {
  switch (s) {
    case 'draft':
      return ProductStatus.draft;
    case 'archived':
      return ProductStatus.archived;
    default:
      return ProductStatus.active;
  }
}

String _statusToString(ProductStatus s) => switch (s) {
  ProductStatus.active => 'active',
  ProductStatus.draft => 'draft',
  ProductStatus.archived => 'archived',
};

class ProductImage {
  final String? path;
  final String? url;
  final String? alt;

  const ProductImage({this.path, this.url, this.alt});

  factory ProductImage.fromJson(Map<String, dynamic> json) => ProductImage(
    path: json['path'] as String?,
    url: json['url'] as String?,
    alt: json['alt'] as String?,
  );
}

class Product {
  final int id;
  final String name;
  final String? sku;
  final ProductType type;
  final ProductStatus status;
  final double price;
  final double? compareAt;
  final int? categoryId;
  final bool inventoryTracked;
  final int stock;
  final int lowStockThreshold;
  final bool allowBackorder;
  final List<ProductImage> images;

  const Product({
    required this.id,
    required this.name,
    this.sku,
    required this.type,
    required this.status,
    required this.price,
    this.compareAt,
    this.categoryId,
    required this.inventoryTracked,
    required this.stock,
    required this.lowStockThreshold,
    this.allowBackorder = false,
    this.images = const [],
  });

  /// Real API has no emoji/icon field — fixed placeholder per type so the
  /// existing `AppThumb(emoji: …)` widget still has something to show.
  String get emoji => type == ProductType.variable ? '👕' : '🏷️';

  /// See the discrepancy note at the top of this file — `category_id` is
  /// not yet resolved to a real name anywhere in this app.
  String get category =>
      categoryId == null ? 'Uncategorised' : 'Category #$categoryId';

  bool get isLowStock => inventoryTracked && stock <= lowStockThreshold;
  bool get isOutOfStock => inventoryTracked && stock <= 0 && !allowBackorder;

  Product copyWith({
    ProductStatus? status,
    int? stock,
    int? lowStockThreshold,
  }) => Product(
    id: id,
    name: name,
    sku: sku,
    type: type,
    status: status ?? this.status,
    price: price,
    compareAt: compareAt,
    categoryId: categoryId,
    inventoryTracked: inventoryTracked,
    stock: stock ?? this.stock,
    lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
    allowBackorder: allowBackorder,
    images: images,
  );

  factory Product.fromJson(Map<String, dynamic> json) {
    final inventory =
        (json['inventory'] as Map?)?.cast<String, dynamic>() ?? const {};
    return Product(
      id: json['id'] as int,
      name: json['name'] as String,
      sku: json['sku'] as String?,
      type: json['type'] == 'variable'
          ? ProductType.variable
          : ProductType.simple,
      status: _statusFromString(json['status'] as String?),
      price: (json['price'] as num?)?.toDouble() ?? 0,
      compareAt: (json['compare_at_price'] as num?)?.toDouble(),
      categoryId: json['category_id'] as int?,
      inventoryTracked: inventory['tracked'] as bool? ?? false,
      stock: (inventory['quantity'] as num?)?.toInt() ?? 0,
      lowStockThreshold:
          (inventory['low_stock_threshold'] as num?)?.toInt() ?? 0,
      allowBackorder: inventory['allow_backorder'] as bool? ?? false,
      images: (json['images'] as List? ?? const [])
          .map((e) => ProductImage.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Exposed for [ApiProductRepository] request bodies — mirrors the string
/// values the API's `status` field accepts (`draft`/`active`/`archived`).
String productStatusToApiString(ProductStatus s) => _statusToString(s);

class ProductsPage {
  final List<Product> data;
  final int currentPage;
  final int lastPage;
  final int total;

  const ProductsPage({
    required this.data,
    required this.currentPage,
    required this.lastPage,
    required this.total,
  });

  factory ProductsPage.fromJson(Map<String, dynamic> json) {
    final meta = (json['meta'] as Map?)?.cast<String, dynamic>() ?? const {};
    return ProductsPage(
      data: (json['data'] as List? ?? const [])
          .map((p) => Product.fromJson(p as Map<String, dynamic>))
          .toList(),
      currentPage: meta['current_page'] as int? ?? 1,
      lastPage: meta['last_page'] as int? ?? 1,
      total: meta['total'] as int? ?? 0,
    );
  }
}
