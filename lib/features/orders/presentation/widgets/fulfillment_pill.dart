import 'package:flutter/widgets.dart';

import '../../../../shared/models/order.dart';
import '../../../../shared/widgets/app_status_pill.dart';

/// Maps [FulfillmentStatus] to the prototype's `ffPill()` labels/variants.
class FulfillmentPill extends StatelessWidget {
  final FulfillmentStatus status;

  const FulfillmentPill({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case FulfillmentStatus.fulfilled:
        return const AppStatusPill(
          label: 'Shipped',
          variant: AppPillVariant.ok,
        );
      case FulfillmentStatus.partial:
        return const AppStatusPill(
          label: 'Partly packed',
          variant: AppPillVariant.info,
        );
      case FulfillmentStatus.unfulfilled:
        return const AppStatusPill(
          label: 'To pack',
          variant: AppPillVariant.warn,
        );
    }
  }
}
