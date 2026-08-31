/// `GET /catalog/options` response shape, per `seller-app-product-form.md`
/// §5 ("Reference data") — **curl-verified against the live QA server on
/// 2026-08-26**. The response has no `data` wrapper (unlike every other
/// seller endpoint) — `ApiCatalogRepository` handles both shapes for
/// safety, but the live response is the bare object directly. Categories
/// also carry an `image_url` (unused here) and each attribute carries a
/// `type` (`button`/`dropdown`/`swatch` — a UI-hint the current product
/// form doesn't yet use, since [AppValueChips] renders every value the same
/// way regardless).
library;

class Category {
  final int id;
  final String name;
  final int? parentId;

  const Category({required this.id, required this.name, this.parentId});

  factory Category.fromJson(Map<String, dynamic> json) => Category(
    id: json['id'] as int,
    name: json['name'] as String,
    parentId: json['parent_id'] as int?,
  );
}

class AttributeValue {
  final int id;
  final String value;
  final String? colorHex;

  const AttributeValue({required this.id, required this.value, this.colorHex});

  factory AttributeValue.fromJson(Map<String, dynamic> json) => AttributeValue(
    id: json['id'] as int,
    value: json['value'] as String,
    colorHex: json['color_hex'] as String? ?? json['color'] as String?,
  );
}

class CatalogAttribute {
  final int id;
  final String name;
  final bool isVariant;
  final List<AttributeValue> values;

  const CatalogAttribute({
    required this.id,
    required this.name,
    required this.isVariant,
    this.values = const [],
  });

  factory CatalogAttribute.fromJson(Map<String, dynamic> json) =>
      CatalogAttribute(
        id: json['id'] as int,
        name: json['name'] as String,
        isVariant: json['is_variant'] as bool? ?? false,
        values: (json['values'] as List? ?? const [])
            .map((v) => AttributeValue.fromJson(v as Map<String, dynamic>))
            .toList(),
      );

  AttributeValue? value(int id) {
    for (final v in values) {
      if (v.id == id) return v;
    }
    return null;
  }
}

class TaxClass {
  final int id;
  final String name;

  const TaxClass({required this.id, required this.name});

  factory TaxClass.fromJson(Map<String, dynamic> json) =>
      TaxClass(id: json['id'] as int, name: json['name'] as String);
}

class CatalogOptions {
  final List<Category> categories;
  final List<CatalogAttribute> attributes;
  final List<TaxClass> taxClasses;
  final List<String> statuses;

  const CatalogOptions({
    this.categories = const [],
    this.attributes = const [],
    this.taxClasses = const [],
    this.statuses = const ['draft', 'active', 'archived'],
  });

  factory CatalogOptions.fromJson(Map<String, dynamic> json) => CatalogOptions(
    categories: (json['categories'] as List? ?? const [])
        .map((c) => Category.fromJson(c as Map<String, dynamic>))
        .toList(),
    attributes: (json['attributes'] as List? ?? const [])
        .map((a) => CatalogAttribute.fromJson(a as Map<String, dynamic>))
        .toList(),
    taxClasses: (json['tax_classes'] as List? ?? const [])
        .map((t) => TaxClass.fromJson(t as Map<String, dynamic>))
        .toList(),
    statuses: (json['statuses'] as List? ?? const ['draft', 'active', 'archived'])
        .map((s) => s as String)
        .toList(),
  );

  /// Attributes usable to build variants — the rest are filter facets and
  /// never appear on the product form.
  List<CatalogAttribute> get variantAttributes =>
      attributes.where((a) => a.isVariant).toList();

  Category? category(int? id) {
    if (id == null) return null;
    for (final c in categories) {
      if (c.id == id) return c;
    }
    return null;
  }

  CatalogAttribute? attribute(int id) {
    for (final a in attributes) {
      if (a.id == id) return a;
    }
    return null;
  }

  TaxClass? taxClass(int? id) {
    if (id == null) return null;
    for (final t in taxClasses) {
      if (t.id == id) return t;
    }
    return null;
  }
}
