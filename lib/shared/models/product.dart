/// Matches `GET /products`, `GET /products/{id}`, `POST /products`,
/// `PUT /products/{id}`, `PATCH /products/{id}/status` and
/// `PATCH /products/{id}/stock` response shapes — verified via curl against
/// the live QA store on 2026-08-22 (product #48 "QA TEST — Kanchipuram silk
/// saree", and a scratch product #49 created/updated/deleted during
/// verification) for the original 7-field shape, and again on 2026-08-26
/// (products #48, #52, and a scratch #53 created/updated/deleted during
/// verification) for the extended 28-field shape added per
/// `seller-app-product-form.md`.
///
/// Discrepancies found while integrating:
/// - The docs don't say `stock_quantity` alone turns tracking on: posting
///   `{"stock_quantity": 10}` without `track_inventory: true` came back
///   with `inventory.tracked: false` (quantity still saved). The Postman
///   sample request under "Products/Create (simple)" does send
///   `track_inventory: true` explicitly, so callers must always send it.
/// - The API has no `emoji` field at all (products carry real `images[]`
///   instead) — [Product.emoji] is a fixed placeholder keyed off
///   [ProductType], matching the same pattern used for [OrderItem.emoji].
/// - `category` is not a string on the wire, only `category_id` (nullable)
///   plus a separate `category_ids[]` for secondary categories, resolved via
///   `GET /catalog/options` (see `catalog.dart`) — [Product.category] here
///   is still just a placeholder derived from `category_id`; screens resolve
///   the real name themselves via `CatalogOptions.category()`.
/// - `shipping` (`required`/`weight`/`length`/`width`/`height`) and `seo`
///   (`title`/`description`) come back as **nested objects** on every GET,
///   even though the request body accepts the same fields flat at the top
///   level (`requires_shipping`, `weight`, `seo_title`, … — confirmed
///   round-tripping correctly on 2026-08-26). `fromJson` below reads the
///   nested shape; `ProductPayload.toJson` sends the flat one — they are
///   deliberately asymmetric because that's what the live server does.
/// - A backend bug found on 2026-08-26 (creating a `variants[]` entry 500'd
///   with a Postgres not-null violation on `product_variants.id`) was
///   **fixed server-side the same day** — reconfirmed by curl: create,
///   add-a-variant, edit-a-variant, and remove-a-variant (via omission) all
///   round-trip correctly on a scratch product (#56) created/updated/
///   deleted during that recheck. Sending a variant with an existing `id`
///   updates it in place; omitting `id` on a new one creates it; leaving a
///   previously-saved variant's id out of the array removes it. A variable
///   product with `track_inventory: true` still requires a top-level
///   `stock_quantity` even though it's derived from the variants —
///   `ProductPayload` already sends `variantStock` for this.
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
  final int? id;
  final String? path;
  final String? url;
  final String? alt;

  const ProductImage({this.id, this.path, this.url, this.alt});

  factory ProductImage.fromJson(Map<String, dynamic> json) => ProductImage(
    id: json['id'] as int?,
    path: json['path'] as String?,
    url: json['url'] as String?,
    alt: json['alt'] as String?,
  );

  Map<String, dynamic> toJson() => {'id': id, 'path': path, 'alt': alt};
}

class ProductVariantValue {
  final int attributeId;
  final int attributeValueId;

  const ProductVariantValue({
    required this.attributeId,
    required this.attributeValueId,
  });

  factory ProductVariantValue.fromJson(Map<String, dynamic> json) =>
      ProductVariantValue(
        attributeId: json['attribute_id'] as int,
        attributeValueId: json['attribute_value_id'] as int,
      );

  Map<String, dynamic> toJson() => {
    'attribute_id': attributeId,
    'attribute_value_id': attributeValueId,
  };
}

class ProductVariant {
  final int? id;
  final String name;
  final String? sku;
  final double price;
  final double? compareAtPrice;
  final int stockQuantity;
  final double weight;
  final bool isActive;
  final List<ProductVariantValue> values;

  const ProductVariant({
    this.id,
    required this.name,
    this.sku,
    required this.price,
    this.compareAtPrice,
    required this.stockQuantity,
    required this.weight,
    this.isActive = true,
    this.values = const [],
  });

  factory ProductVariant.fromJson(Map<String, dynamic> json) => ProductVariant(
    id: json['id'] as int?,
    name: json['name'] as String? ?? '',
    sku: json['sku'] as String?,
    price: (json['price'] as num?)?.toDouble() ?? 0,
    compareAtPrice: (json['compare_at_price'] as num?)?.toDouble(),
    stockQuantity: (json['stock_quantity'] as num?)?.toInt() ?? 0,
    weight: (json['weight'] as num?)?.toDouble() ?? 0,
    isActive: json['is_active'] as bool? ?? true,
    values: (json['values'] as List? ?? const [])
        .map((v) => ProductVariantValue.fromJson(v as Map<String, dynamic>))
        .toList(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'sku': sku,
    'price': price,
    'compare_at_price': compareAtPrice,
    'stock_quantity': stockQuantity,
    'weight': weight,
    'is_active': isActive,
    'values': values.map((v) => v.toJson()).toList(),
  };

  ProductVariant copyWith({
    String? name,
    String? sku,
    double? price,
    double? compareAtPrice,
    int? stockQuantity,
    double? weight,
    bool? isActive,
    List<ProductVariantValue>? values,
  }) => ProductVariant(
    id: id,
    name: name ?? this.name,
    sku: sku ?? this.sku,
    price: price ?? this.price,
    compareAtPrice: compareAtPrice ?? this.compareAtPrice,
    stockQuantity: stockQuantity ?? this.stockQuantity,
    weight: weight ?? this.weight,
    isActive: isActive ?? this.isActive,
    values: values ?? this.values,
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

  // --- extended fields (spec §3), unverified shape — see file doc comment.
  final String? shortDescription;
  final String? description;
  final List<int> categoryIds;
  final int? taxClassId;
  final double? costPrice;
  final String? barcode;
  final bool requiresShipping;
  final double? weight;
  final double? length;
  final double? width;
  final double? height;
  final String? brand;
  final List<String> tags;
  final String? seoTitle;
  final String? seoDescription;
  final String? slug;
  final List<int> attributeIds;
  final List<ProductVariant> variants;
  final int? sold;
  final double? revenue;
  final int? orderCount;

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
    this.shortDescription,
    this.description,
    this.categoryIds = const [],
    this.taxClassId,
    this.costPrice,
    this.barcode,
    this.requiresShipping = true,
    this.weight,
    this.length,
    this.width,
    this.height,
    this.brand,
    this.tags = const [],
    this.seoTitle,
    this.seoDescription,
    this.slug,
    this.attributeIds = const [],
    this.variants = const [],
    this.sold,
    this.revenue,
    this.orderCount,
  });

  /// Real API has no emoji/icon field — fixed placeholder per type so the
  /// existing `AppThumb(emoji: …)` widget still has something to show when
  /// there is no uploaded photo yet.
  String get emoji => type == ProductType.variable ? '👕' : '🏷️';

  /// See the discrepancy note at the top of this file — resolve the real
  /// name via `CatalogOptions.category(categoryId)` where one is loaded;
  /// this getter is just a placeholder fallback.
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
    shortDescription: shortDescription,
    description: description,
    categoryIds: categoryIds,
    taxClassId: taxClassId,
    costPrice: costPrice,
    barcode: barcode,
    requiresShipping: requiresShipping,
    weight: weight,
    length: length,
    width: width,
    height: height,
    brand: brand,
    tags: tags,
    seoTitle: seoTitle,
    seoDescription: seoDescription,
    slug: slug,
    attributeIds: attributeIds,
    variants: variants,
    sold: sold,
    revenue: revenue,
    orderCount: orderCount,
  );

  factory Product.fromJson(Map<String, dynamic> json) {
    final inventory =
        (json['inventory'] as Map?)?.cast<String, dynamic>() ?? const {};
    final shipping =
        (json['shipping'] as Map?)?.cast<String, dynamic>() ?? const {};
    final seo = (json['seo'] as Map?)?.cast<String, dynamic>() ?? const {};
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
      inventoryTracked:
          inventory['tracked'] as bool? ??
          json['track_inventory'] as bool? ??
          false,
      stock:
          (inventory['quantity'] as num?)?.toInt() ??
          (json['stock_quantity'] as num?)?.toInt() ??
          0,
      lowStockThreshold:
          (inventory['low_stock_threshold'] as num?)?.toInt() ??
          (json['low_stock_threshold'] as num?)?.toInt() ??
          0,
      allowBackorder:
          inventory['allow_backorder'] as bool? ??
          json['allow_backorder'] as bool? ??
          false,
      images: (json['images'] as List? ?? const [])
          .map((e) => ProductImage.fromJson(e as Map<String, dynamic>))
          .toList(),
      shortDescription: json['short_description'] as String?,
      description: json['description'] as String?,
      categoryIds: (json['category_ids'] as List? ?? const [])
          .map((e) => e as int)
          .toList(),
      taxClassId: json['tax_class_id'] as int?,
      costPrice: (json['cost_price'] as num?)?.toDouble(),
      barcode: json['barcode'] as String?,
      // `shipping{}` is a nested object on the response (curl-verified
      // against the live QA server on 2026-08-26 — GET /products/48/52) even
      // though the request body takes these same fields flat (also
      // verified: POST /products with flat `requires_shipping`/`weight`/…
      // round-trips correctly into this nested shape). See
      // `product_payload.dart`'s doc comment for the request-side shape.
      requiresShipping: shipping['required'] as bool? ?? true,
      weight: (shipping['weight'] as num?)?.toDouble(),
      length: (shipping['length'] as num?)?.toDouble(),
      width: (shipping['width'] as num?)?.toDouble(),
      height: (shipping['height'] as num?)?.toDouble(),
      brand: json['brand'] as String?,
      tags: (json['tags'] as List? ?? const []).map((e) => e as String).toList(),
      // `seo{}` is likewise a nested object on the response only — see the
      // `shipping{}` note just above.
      seoTitle: seo['title'] as String?,
      seoDescription: seo['description'] as String?,
      slug: json['slug'] as String?,
      attributeIds: (json['attribute_ids'] as List? ?? const [])
          .map((e) => e as int)
          .toList(),
      variants: (json['variants'] as List? ?? const [])
          .map((v) => ProductVariant.fromJson(v as Map<String, dynamic>))
          .toList(),
      sold: json['sold'] as int?,
      revenue: (json['revenue'] as num?)?.toDouble(),
      orderCount: json['order_count'] as int? ?? json['orders_count'] as int?,
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
