import 'package:get/get.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../shared/models/catalog.dart';
import '../../../../shared/models/product.dart';
import '../../domain/catalog_repository.dart';
import '../../domain/upload_repository.dart';
import 'product_draft.dart';
import 'products_controller.dart';

/// Shared mutation logic for the product form — both `NewProductController`
/// and `ProductDetailController` extend this so the "add a photo", "toggle
/// an attribute value", "regenerate variants" behaviour (ported from the
/// HTML prototype's `actions` object) lives in exactly one place.
abstract class ProductFormControllerBase extends GetxController {
  final CatalogRepository catalogRepository;
  final UploadRepository uploadRepository;

  ProductFormControllerBase(this.catalogRepository, this.uploadRepository);

  /// The GetX registration tag this instance was `Get.put` under (e.g.
  /// `'product-48'` or `'new-product'`) — set by the router right after
  /// construction. `NewProductController` and `ProductDetailController` both
  /// register under the shared `ProductFormControllerBase` type, so without
  /// a unique tag per instance, opening a second product-form flow (or even
  /// navigating back and forward) would silently overwrite the first one's
  /// registration; a still-mounted screen from the first flow would then
  /// find the wrong concrete controller on its next rebuild and crash on
  /// the type cast. Every sub-screen (category/tax/status/option/variant
  /// pickers) looks the controller up by this same tag via `Get.find`,
  /// passed through `context.push(..., extra: controller.tag)`.
  late final String tag;

  /// The products list screen doesn't auto-refresh when it isn't the one
  /// making the change, so every mutation that affects it (create, update,
  /// delete, status/stock change) explicitly nudges it here instead of
  /// requiring a manual pull-to-refresh or app restart.
  void refreshProductsList() {
    if (Get.isRegistered<ProductsController>()) {
      Get.find<ProductsController>().load();
    }
  }

  final Rxn<ProductDraft> draft = Rxn<ProductDraft>();
  final Rxn<CatalogOptions> options = Rxn<CatalogOptions>();
  final isSubmitting = false.obs;
  final Rxn<Map<String, List<String>>> fieldErrors = Rxn();
  final RxnString errorMessage = RxnString();

  /// Validates and persists the current draft — `createProduct` for a new
  /// product, `updateProduct` when editing. Returns whether it succeeded.
  Future<bool> save();

  Future<CatalogOptions> loadOptions() async {
    final cached = options.value;
    if (cached != null) return cached;
    final result = await catalogRepository.getOptions();
    return result.when(
      success: (o) {
        options.value = o;
        return o;
      },
      failure: (_) {
        // Form still works with an empty options set — pickers just show
        // nothing until the catalog endpoint is reachable.
        const empty = CatalogOptions();
        options.value = empty;
        return empty;
      },
    );
  }

  void touch() => draft.value?.dirty = true;

  void setField<T>(T Function(ProductDraft d) apply) {
    final d = draft.value;
    if (d == null) return;
    apply(d);
    d.dirty = true;
    draft.refresh();
  }

  void toggleSection(String section) {
    final d = draft.value;
    if (d == null) return;
    switch (section) {
      case 'pricing':
        d.pricingOpen = !d.pricingOpen;
      case 'inventory':
        d.inventoryOpen = !d.inventoryOpen;
      case 'shipping':
        d.shippingOpen = !d.shippingOpen;
      case 'seo':
        d.seoOpen = !d.seoOpen;
    }
    draft.refresh();
  }

  Future<void> addPhoto(String localPath) async {
    final d = draft.value;
    if (d == null) return;
    if (d.images.length >= 10) return;

    final entry = DraftImage(localPath: localPath);
    d.images.add(entry);
    d.dirty = true;
    draft.refresh();

    final result = await uploadRepository.upload(localPath);
    result.when(
      success: (img) {
        entry.state = DraftImageState.uploaded;
        entry.image = img;
      },
      failure: (_) {
        entry.state = DraftImageState.failed;
      },
    );
    draft.refresh();
  }

  void removePhoto(int index) {
    setField((d) => d.images.removeAt(index));
  }

  void makeCoverPhoto(int index) {
    setField((d) {
      final img = d.images.removeAt(index);
      d.images.insert(0, img);
    });
  }

  /// Long-press drag reorder — array order *is* display order, index 0 is
  /// the cover (spec §2 media grid).
  void reorderPhoto(int from, int to) {
    setField((d) {
      final img = d.images.removeAt(from);
      d.images.insert(to, img);
    });
  }

  void addTag() {
    setField((d) {
      final tag = d.tagInput.trim().replaceAll(RegExp(r',$'), '');
      if (tag.isNotEmpty && !d.tags.contains(tag)) d.tags.add(tag);
      d.tagInput = '';
    });
  }

  void removeTag(String tag) {
    setField((d) => d.tags.remove(tag));
  }

  void addOption(int attributeId) {
    setField((d) {
      d.attributeIds.add(attributeId);
      d.chosen[attributeId] = [];
    });
  }

  void removeOption(int attributeId) {
    setField((d) {
      d.attributeIds.remove(attributeId);
      d.chosen.remove(attributeId);
      final o = options.value;
      if (o != null) d.regenerateVariants(o);
    });
  }

  void toggleValue(int attributeId, int valueId) {
    setField((d) {
      final list = d.chosen[attributeId] ?? [];
      d.chosen[attributeId] = list.contains(valueId)
          ? list.where((v) => v != valueId).toList()
          : [...list, valueId];
    });
  }

  void doneOption() {
    setField((d) {
      final o = options.value;
      if (o != null) d.regenerateVariants(o);
    });
  }

  void removeVariant(int index) {
    setField((d) => d.variants.removeAt(index));
  }

  void updateVariant(int index, ProductVariant Function(ProductVariant v) apply) {
    setField((d) => d.variants[index] = apply(d.variants[index]));
  }

  void toggleVariantActive(int index) {
    setField(
      (d) =>
          d.variants[index] = d.variants[index].copyWith(isActive: !d.variants[index].isActive),
    );
  }

  void mapValidationError(AppException error) {
    if (error is ValidationException) {
      fieldErrors.value = error.fieldErrors;
      // Laravel keys nested errors as `variants.0.price` — surface which
      // variant they belong to in the toast (1-indexed, matching what a
      // seller sees on screen) since the save flow doesn't auto-navigate to
      // that variant's editor. `_errorsFor` below still exposes the raw
      // per-field text if the seller does open that variant.
      final variantErrors = error.fieldErrors.entries
          .where((e) => e.key.startsWith('variants.'))
          .map((e) {
            final parts = e.key.split('.');
            final index = int.tryParse(parts.length > 1 ? parts[1] : '');
            final label = index == null ? e.key : 'Variant ${index + 1}';
            return '$label: ${e.value.join(' ')}';
          });
      final otherMessage = error.fieldErrors.entries
          .where((e) => !e.key.startsWith('variants.'))
          .map((e) => e.value.join(' '));
      final combined = [...otherMessage, ...variantErrors];
      errorMessage.value = combined.isEmpty ? error.message : combined.join('\n');
    } else {
      errorMessage.value = error.message;
      fieldErrors.value = null;
    }
  }

  /// Field-level errors for one variant row (e.g. `variants.0.price` ->
  /// `price`), for inline display on that variant's editor screen.
  Map<String, List<String>> errorsForVariant(int index) {
    final all = fieldErrors.value;
    if (all == null) return const {};
    final prefix = 'variants.$index.';
    return {
      for (final e in all.entries)
        if (e.key.startsWith(prefix)) e.key.substring(prefix.length): e.value,
    };
  }
}
