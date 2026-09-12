import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// The KisanSetu mark: a green rounded tile with a wheat/agriculture glyph.
/// Drawn in code so there is no image asset to manage.
class AppLogo extends StatelessWidget {
  final double size;

  const AppLogo({super.key, this.size = 88});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2E7D32), AppColors.primary],
        ),
        borderRadius: BorderRadius.circular(size * 0.28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.28),
            blurRadius: size * 0.3,
            offset: Offset(0, size * 0.12),
          ),
        ],
      ),
      child: Icon(
        Icons.agriculture_rounded,
        size: size * 0.58,
        color: AppColors.onPrimary,
      ),
    );
  }
}
