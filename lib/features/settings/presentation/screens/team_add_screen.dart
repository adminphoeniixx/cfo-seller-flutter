import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/utils/app_messenger.dart';
import '../../../../shared/widgets/widgets.dart';
import '../controllers/team_controller.dart';

class TeamAddScreen extends GetView<TeamController> {
  const TeamAddScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final passwordCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();

    return AppScreen(
      children: [
        AppTextField(
          label: 'Name',
          controller: nameCtrl,
          placeholder: 'e.g. Packing desk',
        ),
        AppTextField(
          label: 'Email',
          controller: emailCtrl,
          placeholder: 'packing@meeratextiles.in',
          keyboardType: TextInputType.emailAddress,
        ),
        AppTextField(
          label: 'Phone',
          controller: phoneCtrl,
          placeholder: 'Optional',
        ),
        AppTextField(
          label: 'Password',
          controller: passwordCtrl,
          obscureText: true,
          placeholder: 'At least 8 characters',
        ),
        AppTextField(
          label: 'Confirm password',
          controller: confirmCtrl,
          obscureText: true,
        ),
        Text(
          "They'll be able to manage everything on this store, including adding and removing other logins.",
          style: TextStyle(
            fontSize: 11.5,
            color: context.colors.ink3,
            height: 1.5,
          ),
        ),
        AppButton(
          label: 'Create login',
          onPressed: () async {
            if (nameCtrl.text.isEmpty ||
                emailCtrl.text.isEmpty ||
                passwordCtrl.text.isEmpty) {
              AppMessenger.show('Name, email and password are required');
              return;
            }
            if (passwordCtrl.text != confirmCtrl.text) {
              AppMessenger.show('Passwords do not match');
              return;
            }
            final ok = await controller.addMember(
              name: nameCtrl.text,
              email: emailCtrl.text,
              password: passwordCtrl.text,
              phone: phoneCtrl.text.isEmpty ? null : phoneCtrl.text,
            );
            if (ok && context.mounted) {
              Navigator.of(context).pop();
              AppMessenger.show('Login created');
            }
          },
        ),
      ],
    );
  }
}
