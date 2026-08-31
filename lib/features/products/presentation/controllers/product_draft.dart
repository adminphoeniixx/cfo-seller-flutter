import '../../../../shared/models/catalog.dart';
import '../../../../shared/models/product.dart';
import '../../../../shared/models/product_payload.dart';

enum DraftImageState { uploading, uploaded, failed }

/// One tile in the media grid. `localPath` is the picked file's path (used
/// to drive the upload call); `image` holds the server-confirmed
/// `path`/`url` once uploaded. Reordering the containing list *is* the
/// display order — index 0 is the cover, per the spec.
class DraftImage {
  final String localPath;
  DraftImageState state;
  ProductImage? image;

  DraftImage({required this.localPath, this.state = DraftImageState.uploading, this.image});

  bool get isReady => state == DraftImageState.uploaded && image != null;
}

/// Mutable, non-reactive form state backing both "New product" and "Edit
/// product" — the app-side equivalent of the HTML prototype's single
/// `draft` object (see `seller-app 3.html`'s `newDraft()`/`regenerate()`).
/// Owned by `NewProductController`/`ProductDetailController`; sub-screens
/// (category picker, option builder, variant editor) mutate the same
/// instance via `Get.find`, so edits persist across pushes exactly like the
/// prototype's in-memory `draft`.
class ProductDraft {
  final int? id;
  String name;
  String shortDescription;
  String description;
  final List<DraftImage> images;
  int? categoryId;
  List<int> categoryIds;
  String price;
  String compareAtPrice;
  String costPrice;
  int? taxClassId;
  bool trackInventory;
  String stockQuantity;
  String lowStockThreshold;
  String sku;
  String barcode;
  bool allowBackorder;
  bool requiresShipping;
  String weight;
  String length;
  String width;
  String height;
  List<int> attributeIds;
  List<ProductVariant> variants;
  String brand;
  List<String> tags;
  String tagInput;
  String seoTitle;
  String seoDescription;
  String slug;
  ProductStatus status;

  /// Which value ids are chosen per attribute id, while building variants —
  /// mirrors the prototype's `chosen` map.
  Map<int, List<int>> chosen;

  /// Disclosure sections open/closed — mirrors the prototype's `open`.
  bool pricingOpen;
  bool inventoryOpen;
  bool shippingOpen;
  bool seoOpen;

  bool dirty = false;

  ProductDraft({
    this.id,
    required this.name,
    required this.shortDescription,
    required this.description,
    required this.images,
    required this.categoryId,
    required this.categoryIds,
    required this.price,
    required this.compareAtPrice,
    required this.costPrice,
    required this.taxClassId,
    required this.trackInventory,
    required this.stockQuantity,
    required this.lowStockThreshold,
    required this.sku,
    required this.barcode,
    required this.allowBackorder,
    required this.requiresShipping,
    required this.weight,
    required this.length,
    required this.width,
    required this.height,
    required this.attributeIds,
    required this.variants,
    required this.brand,
    required this.tags,
    required this.tagInput,
    required this.seoTitle,
    required this.seoDescription,
    required this.slug,
    required this.status,
    required this.chosen,
    required this.pricingOpen,
    required this.inventoryOpen,
    required this.shippingOpen,
    required this.seoOpen,
  });

  factory ProductDraft.blank() => ProductDraft(
    id: null,
    name: '',
    shortDescription: '',
    description: '',
    images: [],
    categoryId: null,
    categoryIds: [],
    price: '',
    compareAtPrice: '',
    costPrice: '',
    taxClassId: null,
    trackInventory: true,
    stockQuantity: '0',
    lowStockThreshold: '5',
    sku: '',
    barcode: '',
    allowBackorder: false,
    requiresShipping: true,
    weight: '',
    length: '',
    width: '',
    height: '',
    attributeIds: [],
    variants: [],
    brand: '',
    tags: [],
    tagInput: '',
    seoTitle: '',
    seoDescription: '',
    slug: '',
    status: ProductStatus.draft,
    chosen: {},
    pricingOpen: false,
    inventoryOpen: false,
    shippingOpen: false,
    seoOpen: false,
  );

  factory ProductDraft.fromProduct(Product p, CatalogOptions options) {
    final chosen = <int, List<int>>{};
    for (final id in p.attributeIds) {
      final used = <int>{
        for (final v in p.variants)
          for (final val in v.values)
            if (val.attributeId == id) val.attributeValueId,
      }.toList();
      chosen[id] = used.isNotEmpty
          ? used
          : (options.attribute(id)?.values ?? const []).map((v) => v.id).toList();
    }

    return ProductDraft(
      id: p.id,
      name: p.name,
      shortDescription: p.shortDescription ?? '',
      description: p.description ?? '',
      images: p.images
          .map(
            (img) => DraftImage(
              localPath: img.url ?? img.path ?? '',
              state: DraftImageState.uploaded,
              image: img,
            ),
          )
          .toList(),
      categoryId: p.categoryId,
      categoryIds: [...p.categoryIds],
      price: p.price == 0 ? '' : _trimZero(p.price),
      compareAtPrice: p.compareAt == null ? '' : _trimZero(p.compareAt!),
      costPrice: p.costPrice == null ? '' : _trimZero(p.costPrice!),
      taxClassId: p.taxClassId,
      trackInventory: p.inventoryTracked,
      stockQuantity: '${p.stock}',
      lowStockThreshold: '${p.lowStockThreshold}',
      sku: p.sku ?? '',
      barcode: p.barcode ?? '',
      allowBackorder: p.allowBackorder,
      requiresShipping: p.requiresShipping,
      weight: p.weight == null ? '' : _trimZero(p.weight!),
      length: p.length == null ? '' : _trimZero(p.length!),
      width: p.width == null ? '' : _trimZero(p.width!),
      height: p.height == null ? '' : _trimZero(p.height!),
      attributeIds: [...p.attributeIds],
      variants: p.variants.map((v) => v.copyWith()).toList(),
      brand: p.brand ?? '',
      tags: [...p.tags],
      tagInput: '',
      seoTitle: p.seoTitle ?? '',
      seoDescription: p.seoDescription ?? '',
      slug: p.slug ?? '',
      status: p.status,
      chosen: chosen,
      // Open pricing automatically when a compare-at or cost price already
      // exists, so nothing the seller set is hidden behind a tap.
      pricingOpen: p.compareAt != null || p.costPrice != null,
      inventoryOpen: false,
      shippingOpen: false,
      seoOpen: false,
    );
  }

  static String _trimZero(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString();

  bool get hasVariants => variants.isNotEmpty;

  int get variantStock =>
      variants.fold(0, (sum, v) => sum + v.stockQuantity);

  String get variantType => hasVariants ? 'variable' : 'simple';

  ({double profit, String pct})? get margin {
    final price = double.tryParse(this.price) ?? 0;
    final cost = double.tryParse(costPrice) ?? 0;
    if (price <= 0 || cost <= 0) return null;
    final profit = price - cost;
    final pct = ((profit / price) * 100).toStringAsFixed(1);
    return (profit: profit, pct: pct);
  }

  static String _comboKey(List<ProductVariantValue> values) {
    final sorted = [...values]
      ..sort((a, b) => a.attributeId.compareTo(b.attributeId));
    return sorted.map((v) => '${v.attributeId}:${v.attributeValueId}').join('|');
  }

  /// Cartesian product of the chosen values across every chosen attribute,
  /// capped at 100 rows, preserving rows already edited (matched by the
  /// attribute/value combination, not by index) — ported directly from the
  /// HTML prototype's `regenerate()`.
  void regenerateVariants(CatalogOptions options) {
    final groups = attributeIds
        .map((id) => (id: id, values: chosen[id] ?? const <int>[]))
        .where((g) => g.values.isNotEmpty)
        .toList();

    if (groups.isEmpty) {
      variants = [];
      return;
    }

    var combos = <List<ProductVariantValue>>[[]];
    for (final group in groups) {
      final next = <List<ProductVariantValue>>[];
      for (final combo in combos) {
        for (final valueId in group.values) {
          next.add([
            ...combo,
            ProductVariantValue(attributeId: group.id, attributeValueId: valueId),
          ]);
        }
      }
      combos = next;
    }

    final existing = {for (final v in variants) _comboKey(v.values): v};

    variants = combos.take(100).map((values) {
      final found = existing[_comboKey(values)];
      if (found != null) return found;

      final label = values
          .map((v) => options.attribute(v.attributeId)?.value(v.attributeValueId)?.value)
          .whereType<String>()
          .join(' / ');
      final basePrice = double.tryParse(price) ?? 0;
      final baseCompare = double.tryParse(compareAtPrice);
      final baseWeight = double.tryParse(weight) ?? 0;

      return ProductVariant(
        name: label,
        sku: sku.isNotEmpty
            ? '$sku-${label.replaceAll(RegExp(r'[^a-zA-Z0-9]+'), '-').toUpperCase()}'
            : null,
        price: basePrice,
        compareAtPrice: baseCompare,
        stockQuantity: 0,
        weight: baseWeight,
        isActive: true,
        values: values,
      );
    }).toList();
  }

  ProductPayload toPayload() => ProductPayload(
    name: name.trim(),
    slug: slug,
    sku: sku,
    barcode: barcode,
    categoryId: categoryId,
    categoryIds: categoryIds,
    taxClassId: taxClassId,
    shortDescription: shortDescription,
    description: description,
    price: double.tryParse(price) ?? 0,
    compareAtPrice: compareAtPrice.isEmpty ? null : double.tryParse(compareAtPrice),
    costPrice: costPrice.isEmpty ? null : double.tryParse(costPrice),
    trackInventory: trackInventory,
    stockQuantity: hasVariants ? variantStock : (int.tryParse(stockQuantity) ?? 0),
    lowStockThreshold: int.tryParse(lowStockThreshold) ?? 0,
    allowBackorder: allowBackorder,
    weight: double.tryParse(weight) ?? 0,
    length: length.isEmpty ? null : double.tryParse(length),
    width: width.isEmpty ? null : double.tryParse(width),
    height: height.isEmpty ? null : double.tryParse(height),
    requiresShipping: requiresShipping,
    status: status,
    brand: brand,
    tags: tags,
    seoTitle: seoTitle,
    seoDescription: seoDescription,
    images: images.where((i) => i.isReady).map((i) => i.image!).toList(),
    attributeIds: attributeIds,
    variants: variants,
  );
}
