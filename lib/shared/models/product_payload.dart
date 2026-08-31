import 'product.dart';

/// The complete `POST /products` / `PUT /products/{id}` request body, built
/// from a `ProductDraft` (see
/// `features/products/presentation/controllers/product_draft.dart`).
///
/// `PUT` clears anything omitted (see `product.dart`'s discrepancy note), so
/// every call sends every field — there is no partial-diff path. Shape
/// mirrors the "Full payload shape" example in `seller-app-product-form.md`
/// §5 (flat top-level fields, not nested `shipping{}`/`seo{}` objects) —
/// **curl-verified against the live QA server on 2026-08-26**: `POST
/// /products` with flat `requires_shipping`/`weight`/`length`/`width`/
/// `height`/`seo_title`/`seo_description` round-trips correctly into the
/// nested `shipping{}`/`seo{}` shape the API returns on every GET (see
/// `product.dart`'s doc comment). `attribute_ids`/`category_id`/
/// `category_ids`/`tax_class_id`/`brand`/`tags` also verified.
///
/// `variants[]` (create, edit-in-place via `id`, remove via omission) is
/// also verified working end-to-end — see `product.dart`'s doc comment for
/// the backend bug this once hit and its 2026-08-26 fix.
class ProductPayload {
  final String name;
  final String? slug;
  final String? sku;
  final String? barcode;
  final int? categoryId;
  final List<int> categoryIds;
  final int? taxClassId;
  final String? shortDescription;
  final String? description;
  final double price;
  final double? compareAtPrice;
  final double? costPrice;
  final bool trackInventory;
  final int stockQuantity;
  final int lowStockThreshold;
  final bool allowBackorder;
  final double weight;
  final double? length;
  final double? width;
  final double? height;
  final bool requiresShipping;
  final ProductStatus status;
  final String? brand;
  final List<String> tags;
  final String? seoTitle;
  final String? seoDescription;
  final List<ProductImage> images;
  final List<int> attributeIds;
  final List<ProductVariant> variants;

  const ProductPayload({
    required this.name,
    this.slug,
    this.sku,
    this.barcode,
    this.categoryId,
    this.categoryIds = const [],
    this.taxClassId,
    this.shortDescription,
    this.description,
    required this.price,
    this.compareAtPrice,
    this.costPrice,
    required this.trackInventory,
    required this.stockQuantity,
    required this.lowStockThreshold,
    this.allowBackorder = false,
    required this.weight,
    this.length,
    this.width,
    this.height,
    this.requiresShipping = true,
    required this.status,
    this.brand,
    this.tags = const [],
    this.seoTitle,
    this.seoDescription,
    this.images = const [],
    this.attributeIds = const [],
    this.variants = const [],
  });

  /// `type` is never user-set — derived from whether variants exist, per
  /// the spec ("`type` is not a user-facing picker").
  String get type => variants.isEmpty ? 'simple' : 'variable';

  Map<String, dynamic> toJson() => {
    'name': name,
    'slug': slug ?? '',
    'sku': sku ?? '',
    'barcode': barcode ?? '',
    'type': type,
    'category_id': categoryId,
    'category_ids': categoryIds,
    'tax_class_id': taxClassId,
    'short_description': shortDescription ?? '',
    'description': description ?? '',
    'price': price,
    'compare_at_price': compareAtPrice,
    'cost_price': costPrice,
    // Always sent explicitly — the API only starts tracking stock when this
    // is present, per the discrepancy note in `product.dart`.
    'track_inventory': trackInventory,
    'stock_quantity': stockQuantity,
    'low_stock_threshold': lowStockThreshold,
    'allow_backorder': allowBackorder,
    'weight': weight,
    'length': length,
    'width': width,
    'height': height,
    'requires_shipping': requiresShipping,
    'status': productStatusToApiString(status),
    'brand': brand ?? '',
    'tags': tags,
    'seo_title': seoTitle ?? '',
    'seo_description': seoDescription ?? '',
    'images': images
        .map((i) => {'id': i.id, 'path': i.path, 'alt': i.alt ?? name})
        .toList(),
    'attribute_ids': attributeIds,
    'variants': variants
        .map(
          (v) => {
            'id': v.id,
            'name': v.name,
            'sku': v.sku ?? '',
            'price': v.price,
            'compare_at_price': v.compareAtPrice,
            'stock_quantity': v.stockQuantity,
            'weight': v.weight,
            'is_active': v.isActive,
            'values': v.values.map((x) => x.toJson()).toList(),
          },
        )
        .toList(),
  };
}
