import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class AppLoading extends StatelessWidget {
  const AppLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(
        color: context.colors.action,
        strokeWidth: 2.5,
      ),
    );
  }
}
