import 'package:flutter/material.dart';
import '../localization/app_language.dart';
import '../localization/language_scope.dart';
import '../theme/app_colors.dart';

/// A sleek, modern segmented pill toggle for switching between English and Hindi.
/// Adapts gracefully whether placed on an AppBar (green surface) or general screen body.
class LanguageToggleButton extends StatelessWidget {
  /// Whether the button is hosted on a dark background (such as the primary AppBar).
  /// If null, automatically infers from the current [IconTheme].
  final bool? isLightSurface;

  const LanguageToggleButton({
    super.key,
    this.isLightSurface,
  });

  @override
  Widget build(BuildContext context) {
    final language = context.currentLanguage;
    final isHindi = language == AppLanguage.hi;

    // Detect if we are on a light or dark container (e.g. AppBar foreground vs Scaffold)
    final iconColor = IconTheme.of(context).color;
    final isDarkBackground = isLightSurface != null
        ? !isLightSurface!
        : (iconColor != null && iconColor.computeLuminance() > 0.5);

    final containerColor = isDarkBackground
        ? Colors.white.withValues(alpha: 0.16)
        : AppColors.surfaceVariant.withValues(alpha: 0.5);

    final borderColor = isDarkBackground
        ? Colors.white.withValues(alpha: 0.32)
        : AppColors.outlineVariant;

    final activePillColor =
        isDarkBackground ? Colors.white : AppColors.primary;
    final activeTextColor =
        isDarkBackground ? AppColors.primary : AppColors.onPrimary;

    final inactiveTextColor = isDarkBackground
        ? Colors.white.withValues(alpha: 0.85)
        : AppColors.onSurfaceVariant;

    return Tooltip(
      message: isHindi
          ? 'Switch to English'
          : 'हिन्दी में बदलें',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => context.toggleLanguage(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
            decoration: BoxDecoration(
              color: containerColor,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: borderColor, width: 1.0),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildSegment(
                  text: 'EN',
                  isActive: !isHindi,
                  onTap: () => context.setLanguage(AppLanguage.en),
                  activeColor: activePillColor,
                  activeTextColor: activeTextColor,
                  inactiveTextColor: inactiveTextColor,
                ),
                const SizedBox(width: 2),
                _buildSegment(
                  text: 'हि',
                  isActive: isHindi,
                  onTap: () => context.setLanguage(AppLanguage.hi),
                  activeColor: activePillColor,
                  activeTextColor: activeTextColor,
                  inactiveTextColor: inactiveTextColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSegment({
    required String text,
    required bool isActive,
    required VoidCallback onTap,
    required Color activeColor,
    required Color activeTextColor,
    required Color inactiveTextColor,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isActive ? activeColor : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
            color: isActive ? activeTextColor : inactiveTextColor,
          ),
        ),
      ),
    );
  }
}
