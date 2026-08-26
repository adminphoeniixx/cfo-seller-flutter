import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/models/team_member.dart';
import '../../../../shared/utils/app_messenger.dart';
import '../../../../shared/widgets/widgets.dart';
import '../controllers/team_controller.dart';

class TeamScreen extends GetView<TeamController> {
  const TeamScreen({super.key});

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

      final team = controller.team;

      return AppScreen(
        children: [
          Text(
            'Everyone here sees the same orders, products and money. Only passwords, devices and notifications are private to each person.',
            style: TextStyle(
              fontSize: 11.5,
              color: context.colors.ink3,
              height: 1.5,
            ),
          ),
          AppCard(
            flat: true,
            child: Column(
              children: [
                for (var i = 0; i < team.length; i++)
                  AppListRow(
                    leading: AppThumb(emoji: team[i].name.substring(0, 1)),
                    title: team[i].name,
                    titleTrailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (team[i].isYou)
                          const Padding(
                            padding: EdgeInsets.only(right: 4),
                            child: AppStatusPill(
                              label: 'You',
                              variant: AppPillVariant.ok,
                            ),
                          ),
                        if (!team[i].active)
                          const AppStatusPill(
                            label: 'Off',
                            variant: AppPillVariant.mute,
                          ),
                      ],
                    ),
                    subtitle: team[i].email,
                    showChevron: true,
                    showDivider: i != team.length - 1,
                    onTap: () => _showMemberActions(context, team[i]),
                  ),
              ],
            ),
          ),
          AppButton(
            label: 'Add a login',
            onPressed: () => context.push(AppRoutes.teamAdd),
          ),
        ],
      );
    });
  }

  Future<void> _showMemberActions(
    BuildContext context,
    TeamMember member,
  ) async {
    if (member.isYou) {
      // The API returns a 422 if you try to deactivate or remove yourself —
      // there is nothing to offer here beyond viewing.
      AppMessenger.show("You can't change your own access from here.");
      return;
    }

    final action = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(member.name),
        content: Text(member.email),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, 'cancel'),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, 'toggle'),
            child: Text(member.active ? 'Switch off' : 'Switch on'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, 'remove'),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (action == 'toggle') {
      final ok = await controller.toggleMember(member.id);
      if (ok) {
        AppMessenger.show(
          member.active ? 'Access switched off' : 'Access switched on',
        );
      }
    } else if (action == 'remove') {
      if (!context.mounted) return;
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Remove this login?'),
          content: const Text('This cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Remove'),
            ),
          ],
        ),
      );
      if (confirmed == true) {
        final ok = await controller.removeMember(member.id);
        if (ok) AppMessenger.show('Login removed');
      }
    }
  }
}
