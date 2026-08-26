import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../shared/models/device.dart';
import '../../../../shared/utils/app_messenger.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../controllers/device_controller.dart';

class DevicesScreen extends GetView<DeviceController> {
  const DevicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) return const AppLoading();
      if (controller.errorMessage.value != null) {
        return AppErrorState(
          message: controller.errorMessage.value!,
          onRetry: controller.load,
        );
      }

      final devices = controller.devices;
      if (devices.isEmpty) {
        return const AppEmptyState(
          emoji: '📱',
          message: 'No signed-in devices found.',
        );
      }

      return AppScreen(
        children: [
          AppCard(
            flat: true,
            child: Column(
              children: [
                for (var i = 0; i < devices.length; i++)
                  AppListRow(
                    title: devices[i].name,
                    titleTrailing: devices[i].current
                        ? const AppStatusPill(
                            label: 'This device',
                            variant: AppPillVariant.ok,
                          )
                        : null,
                    subtitle: _lastUsedLabel(devices[i]),
                    showDivider: i != devices.length - 1,
                    trailing: devices[i].current
                        ? null
                        : TextButton(
                            onPressed: () => _revoke(context, devices[i]),
                            child: const Text('Sign out'),
                          ),
                  ),
              ],
            ),
          ),
          AppButton.ghost(
            label: 'Sign out everywhere',
            onPressed: () => _signOutEverywhere(context),
          ),
        ],
      );
    });
  }

  String _lastUsedLabel(Device device) {
    final lastUsed = device.lastUsedAt;
    if (lastUsed == null) return 'Never used';
    return 'Last used ${_relativeTime(lastUsed)}';
  }

  String _relativeTime(DateTime time) {
    final diff = DateTime.now().toUtc().difference(time.toUtc());
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  Future<void> _revoke(BuildContext context, Device device) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Sign out "${device.name}"?'),
        content: const Text('This device will need to sign in again.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final ok = await controller.revokeDevice(device.id);
    if (ok) AppMessenger.show('${device.name} signed out');
  }

  Future<void> _signOutEverywhere(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign out everywhere?'),
        content: const Text(
          'Every device, including this one, will be signed out.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sign out everywhere'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await Get.find<AuthController>().signOutAllDevices();
  }
}
