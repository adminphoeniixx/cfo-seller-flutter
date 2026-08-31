import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/models/catalog.dart';
import '../../../../shared/models/product.dart';
import '../../../../shared/utils/app_messenger.dart';
import '../../../../shared/widgets/widgets.dart';
import '../controllers/product_draft.dart';
import '../controllers/product_form_controller_base.dart';

/// The product form itself — shared by "New product" and "Edit product"
/// because they are the same fields against the same payload (mirrors the
/// HTML prototype's single `productForm()` used by both screens). Renders
/// the full spec layout: Basics → Media → Category → Pricing → Inventory →
/// Shipping → Variants → Organisation → SEO → Status.
///
/// Text fields keep their own `TextEditingController`s seeded once from the
/// draft and mutate it directly on every keystroke *without* triggering a
/// full-form rebuild (mirrors the prototype's `marginLine` note: "Margin
/// follows price and cost without redrawing the screen under the caret").
/// Only structural changes (switches, photos, tags, variants, disclosure
/// open/close) go through `controller.setField`, which is scoped to small
/// `Obx` blocks so typing elsewhere is never interrupted.
class ProductFormBody extends StatefulWidget {
  final ProductFormControllerBase controller;

  const ProductFormBody({super.key, required this.controller});

  @override
  State<ProductFormBody> createState() => _ProductFormBodyState();
}

class _ProductFormBodyState extends State<ProductFormBody> {
  final _picker = ImagePicker();
  final _margin = ValueNotifier<String>('');
  late final ValueNotifier<int> _seoTitleLen;

  late final Map<String, TextEditingController> _fields;

  ProductFormControllerBase get controller => widget.controller;
  ProductDraft get draft => controller.draft.value!;

  @override
  void initState() {
    super.initState();
    final d = draft;
    _fields = {
      'name': TextEditingController(text: d.name),
      'shortDescription': TextEditingController(text: d.shortDescription),
      'description': TextEditingController(text: d.description),
      'price': TextEditingController(text: d.price),
      'compareAtPrice': TextEditingController(text: d.compareAtPrice),
      'costPrice': TextEditingController(text: d.costPrice),
      'stockQuantity': TextEditingController(text: d.stockQuantity),
      'lowStockThreshold': TextEditingController(text: d.lowStockThreshold),
      'sku': TextEditingController(text: d.sku),
      'barcode': TextEditingController(text: d.barcode),
      'weight': TextEditingController(text: d.weight),
      'length': TextEditingController(text: d.length),
      'width': TextEditingController(text: d.width),
      'height': TextEditingController(text: d.height),
      'brand': TextEditingController(text: d.brand),
      'tagInput': TextEditingController(),
      'seoTitle': TextEditingController(text: d.seoTitle),
      'seoDescription': TextEditingController(text: d.seoDescription),
      'slug': TextEditingController(text: d.slug),
    };
    _seoTitleLen = ValueNotifier<int>(d.seoTitle.length);
    _updateMargin();
  }

  @override
  void dispose() {
    for (final c in _fields.values) {
      c.dispose();
    }
    _margin.dispose();
    _seoTitleLen.dispose();
    super.dispose();
  }

  void _updateMargin() {
    final m = draft.margin;
    _margin.value = m == null
        ? 'Add a price and a cost per item to see profit and margin.'
        : 'Profit ₹${m.profit.toStringAsFixed(2)} · Margin ${m.pct}%';
  }

  List<String>? _errorsFor(String key) => controller.fieldErrors.value?[key];

  void _plainField(String key, void Function(ProductDraft d, String v) apply) {
    apply(draft, _fields[key]!.text);
    draft.dirty = true;
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final d = controller.draft.value;
      if (d == null) return const AppLoading();
      final options = controller.options.value ?? const CatalogOptions();

      return AppScreen(
        children: [
          const AppSectionHeader(title: 'Basics'),
          AppTextField(
            label: 'Title',
            controller: _fields['name'],
            placeholder: 'e.g. Chanderi cotton saree',
            onChanged: (v) => _plainField('name', (d, v) => d.name = v),
            errorText: _errorsFor('name')?.join(' '),
          ),
          AppTextField(
            label: 'Subtitle',
            controller: _fields['shortDescription'],
            placeholder: "One line shoppers see in listings",
            onChanged: (v) => _plainField('shortDescription', (d, v) => d.shortDescription = v),
          ),
          _multiline(
            label: 'Description',
            controller: _fields['description']!,
            placeholder: "What it is, what it's made of, how it's cared for…",
            onChanged: (v) => _plainField('description', (d, v) => d.description = v),
          ),

          AppSectionHeader(title: 'Media', actionLabel: '${d.images.length}/10'),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppMediaGrid(
                  tiles: [
                    for (final img in d.images)
                      MediaTile(
                        localPath: img.state == DraftImageState.uploading || img.image?.url == null
                            ? img.localPath
                            : null,
                        networkUrl: img.image?.url,
                        uploading: img.state == DraftImageState.uploading,
                        failed: img.state == DraftImageState.failed,
                      ),
                  ],
                  onAdd: _addPhoto,
                  onRemove: controller.removePhoto,
                  onMakeCover: controller.makeCoverPhoto,
                  onReorder: controller.reorderPhoto,
                ),
                const SizedBox(height: 9),
                Text(
                  'First photo is the cover, and the order here is the order '
                  'shoppers see. JPG, PNG, WEBP or AVIF up to 5 MB per photo.',
                  style: AppTypography.note.copyWith(color: context.colors.ink3),
                ),
              ],
            ),
          ),

          const AppSectionHeader(title: 'Category'),
          AppTapField(
            label: 'Category',
            value: options.category(d.categoryId)?.name ?? 'Choose',
            valueColor: options.category(d.categoryId) == null ? context.colors.ink3 : null,
            onTap: () => context.push(AppRoutes.productCategory, extra: controller.tag),
          ),

          const AppSectionHeader(title: 'Pricing'),
          AppTextField(
            label: 'Price',
            controller: _fields['price'],
            placeholder: '0.00',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (v) {
              _plainField('price', (d, v) => d.price = v);
              _updateMargin();
            },
            errorText: _errorsFor('price')?.join(' '),
          ),
          AppDisclosureRow(
            tags: const ['Compare-at', 'Cost', 'Tax', 'Margin'],
            open: d.pricingOpen,
            onTap: () => controller.toggleSection('pricing'),
          ),
          if (d.pricingOpen) ...[
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    label: 'Compare at',
                    controller: _fields['compareAtPrice'],
                    placeholder: '—',
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (v) => _plainField('compareAtPrice', (d, v) => d.compareAtPrice = v),
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: AppTextField(
                    label: 'Cost per item',
                    controller: _fields['costPrice'],
                    placeholder: '—',
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (v) {
                      _plainField('costPrice', (d, v) => d.costPrice = v);
                      _updateMargin();
                    },
                  ),
                ),
              ],
            ),
            AppTapField(
              label: 'Tax class',
              value: options.taxClass(d.taxClassId)?.name ?? 'No tax class',
              valueColor: options.taxClass(d.taxClassId) == null ? context.colors.ink3 : null,
              onTap: () => context.push(AppRoutes.productTaxClass, extra: controller.tag),
            ),
            ValueListenableBuilder<String>(
              valueListenable: _margin,
              builder: (context, value, _) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: Text(value, style: AppTypography.note.copyWith(color: context.colors.ink3)),
              ),
            ),
          ],

          const AppSectionHeader(title: 'Inventory'),
          AppSwitch(
            label: 'Track quantity',
            subLabel: 'Counts down as orders come in',
            value: d.trackInventory,
            onChanged: (v) => controller.setField((d) => d.trackInventory = v),
          ),
          if (d.hasVariants)
            AppBanner(
              text: 'Quantity is set per variant below — ${d.variantStock} in stock '
                  'across ${d.variants.length} variants.',
            )
          else if (d.trackInventory)
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    label: 'Quantity',
                    controller: _fields['stockQuantity'],
                    keyboardType: TextInputType.number,
                    onChanged: (v) => _plainField('stockQuantity', (d, v) => d.stockQuantity = v),
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: AppTextField(
                    label: 'Low stock alert at',
                    controller: _fields['lowStockThreshold'],
                    keyboardType: TextInputType.number,
                    onChanged: (v) =>
                        _plainField('lowStockThreshold', (d, v) => d.lowStockThreshold = v),
                  ),
                ),
              ],
            )
          else
            Text(
              'Stock is not tracked, so this never sells out.',
              style: AppTypography.note.copyWith(color: context.colors.ink3),
            ),
          AppDisclosureRow(
            tags: const ['SKU', 'Barcode', 'Backorders'],
            open: d.inventoryOpen,
            onTap: () => controller.toggleSection('inventory'),
          ),
          if (d.inventoryOpen) ...[
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    label: 'SKU',
                    controller: _fields['sku'],
                    placeholder: 'MINE-1',
                    onChanged: (v) => _plainField('sku', (d, v) => d.sku = v),
                    errorText: _errorsFor('sku')?.join(' '),
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: AppTextField(
                    label: 'Barcode',
                    controller: _fields['barcode'],
                    placeholder: 'ISBN, UPC, GTIN',
                    onChanged: (v) => _plainField('barcode', (d, v) => d.barcode = v),
                  ),
                ),
              ],
            ),
            AppSwitch(
              label: 'Keep selling when out of stock',
              subLabel: 'Orders keep coming in at zero',
              value: d.allowBackorder,
              onChanged: (v) => controller.setField((d) => d.allowBackorder = v),
            ),
          ],

          const AppSectionHeader(title: 'Shipping'),
          AppSwitch(
            label: 'Physical product',
            subLabel: 'Switch off for anything downloaded',
            value: d.requiresShipping,
            onChanged: (v) => controller.setField((d) => d.requiresShipping = v),
          ),
          if (d.requiresShipping) ...[
            AppTextField(
              label: 'Weight (kg)',
              controller: _fields['weight'],
              placeholder: '0.000',
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (v) => _plainField('weight', (d, v) => d.weight = v),
            ),
            AppDisclosureRow(
              tags: const ['Length', 'Width', 'Height'],
              open: d.shippingOpen,
              onTap: () => controller.toggleSection('shipping'),
            ),
            if (d.shippingOpen)
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      label: 'Length (cm)',
                      controller: _fields['length'],
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (v) => _plainField('length', (d, v) => d.length = v),
                    ),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: AppTextField(
                      label: 'Width (cm)',
                      controller: _fields['width'],
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (v) => _plainField('width', (d, v) => d.width = v),
                    ),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: AppTextField(
                      label: 'Height (cm)',
                      controller: _fields['height'],
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (v) => _plainField('height', (d, v) => d.height = v),
                    ),
                  ),
                ],
              ),
          ] else
            Text(
              'Digital product — no weight or delivery needed.',
              style: AppTypography.note.copyWith(color: context.colors.ink3),
            ),

          AppSectionHeader(
            title: 'Variants',
            actionLabel: d.hasVariants ? '${d.variants.length} · ${d.variantType}' : null,
          ),
          if (d.attributeIds.isNotEmpty)
            AppCard(
              flat: true,
              child: Column(
                children: [
                  for (var i = 0; i < d.attributeIds.length; i++)
                    AppListRow(
                      title: options.attribute(d.attributeIds[i])?.name ?? '',
                      subtitle: (d.chosen[d.attributeIds[i]] ?? const [])
                              .map((v) => options.attribute(d.attributeIds[i])?.value(v)?.value)
                              .whereType<String>()
                              .join(' · ')
                              .let((s) => s.isEmpty ? 'No values picked yet' : s),
                      showChevron: true,
                      showDivider: i != d.attributeIds.length - 1,
                      onTap: () => context.push(AppRoutes.productOptionPath(d.attributeIds[i]), extra: controller.tag),
                    ),
                ],
              ),
            ),
          AppButton.ghost(
            label: '＋ Add options like size or colour',
            onPressed: () => context.push(AppRoutes.productAddOption, extra: controller.tag),
          ),
          if (d.hasVariants) ...[
            AppCard(
              flat: true,
              child: Column(
                children: [
                  for (var i = 0; i < d.variants.length; i++)
                    AppListRow(
                      title: d.variants[i].name.isEmpty ? 'Variant' : d.variants[i].name,
                      titleTrailing: d.variants[i].isActive
                          ? null
                          : const AppStatusPill(label: 'Off', variant: AppPillVariant.mute),
                      subtitle:
                          '${d.variants[i].sku?.isNotEmpty == true ? d.variants[i].sku : "No SKU"} · '
                          '${d.variants[i].stockQuantity} available',
                      amount: '₹${d.variants[i].price.toStringAsFixed(0)}',
                      showChevron: true,
                      showDivider: i != d.variants.length - 1,
                      onTap: () => context.push(AppRoutes.productVariantPath(i), extra: controller.tag),
                    ),
                ],
              ),
            ),
            Text(
              'Total inventory: ${d.variantStock} available. The type is '
              '${d.variantType} — worked out from the variants, never picked by hand.',
              style: AppTypography.note.copyWith(color: context.colors.ink3),
            ),
          ],

          const AppSectionHeader(title: 'Organisation'),
          AppTextField(
            label: 'Brand',
            controller: _fields['brand'],
            placeholder: 'Optional',
            onChanged: (v) => _plainField('brand', (d, v) => d.brand = v),
          ),
          AppCard(
            child: AppTagInput(
              tags: d.tags,
              controller: _fields['tagInput']!,
              onAdd: (v) {
                draft.tagInput = v;
                controller.addTag();
                _fields['tagInput']!.clear();
              },
              onRemove: controller.removeTag,
            ),
          ),
          AppTapField(
            label: 'Also list under',
            value: d.categoryIds.isEmpty
                ? 'Nothing else'
                : d.categoryIds.map((id) => options.category(id)?.name ?? '').join(', '),
            valueColor: d.categoryIds.isEmpty ? context.colors.ink3 : null,
            onTap: () => context.push(AppRoutes.productMoreCategories, extra: controller.tag),
          ),

          const AppSectionHeader(title: 'Search engine listing'),
          AppDisclosureRow(
            lead: d.seoTitle.isNotEmpty
                ? d.seoTitle
                : (d.name.isNotEmpty ? d.name : 'How this shows up in search'),
            open: d.seoOpen,
            onTap: () => controller.toggleSection('seo'),
          ),
          if (d.seoOpen) ...[
            AppTextField(
              label: 'Page title',
              controller: _fields['seoTitle'],
              onChanged: (v) {
                _plainField('seoTitle', (d, v) => d.seoTitle = v);
                _seoTitleLen.value = v.length;
              },
            ),
            ValueListenableBuilder<int>(
              valueListenable: _seoTitleLen,
              builder: (context, len, _) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: Text(
                  '$len of 70 characters used',
                  style: AppTypography.note.copyWith(color: context.colors.ink3, fontSize: 10.5),
                ),
              ),
            ),
            _multiline(
              label: 'Meta description',
              controller: _fields['seoDescription']!,
              onChanged: (v) => _plainField('seoDescription', (d, v) => d.seoDescription = v),
              minLines: 3,
            ),
            AppTextField(
              label: 'URL handle',
              controller: _fields['slug'],
              placeholder: '/products/…',
              onChanged: (v) => _plainField('slug', (d, v) => d.slug = v),
            ),
          ],

          const AppSectionHeader(title: 'Status'),
          AppTapField(
            label: 'Status',
            value: _statusLabel(d.status),
            onTap: () => context.push(AppRoutes.productStatus, extra: controller.tag),
          ),
          Text(
            'Only Active products are visible to shoppers. Save with Save, '
            'top right — status is a field here, not a second save button.',
            style: AppTypography.note.copyWith(color: context.colors.ink3),
          ),
        ],
      );
    });
  }

  Future<void> _addPhoto() async {
    if (draft.images.length >= 10) {
      AppMessenger.show('Ten photos is the limit');
      return;
    }
    final file = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (file == null) return;
    await controller.addPhoto(file.path);
  }

  Widget _multiline({
    required String label,
    required TextEditingController controller,
    String? placeholder,
    required ValueChanged<String> onChanged,
    int minLines = 4,
  }) {
    return Builder(
      builder: (context) {
        final colors = context.colors;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(11),
            border: Border.all(color: colors.line),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label.toUpperCase(), style: AppTypography.fieldLabel.copyWith(color: colors.ink3)),
              const SizedBox(height: 2),
              TextField(
                controller: controller,
                minLines: minLines,
                maxLines: minLines + 4,
                onChanged: onChanged,
                style: AppTypography.fieldValue.copyWith(color: colors.ink),
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                  border: InputBorder.none,
                  hintText: placeholder,
                  hintStyle: AppTypography.fieldValue.copyWith(color: colors.ink3),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _statusLabel(ProductStatus s) => switch (s) {
    ProductStatus.active => 'Active',
    ProductStatus.draft => 'Draft',
    ProductStatus.archived => 'Archived',
  };
}

extension _Let<T> on T {
  R let<R>(R Function(T) f) => f(this);
}
