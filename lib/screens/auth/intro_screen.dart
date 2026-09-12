import 'package:flutter/material.dart';

import '../../localization/language_scope.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/language_toggle_button.dart';
import 'login_screen.dart';
import 'signup_screen.dart';

/// First screen for a signed-out user: logo, what the app does, and the
/// two ways in (create account / sign in).
class IntroScreen extends StatelessWidget {
  const IntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 12, 16, 0),
              child: Align(
                alignment: Alignment.centerRight,
                child: LanguageToggleButton(isLightSurface: true),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                children: [
                  const SizedBox(height: 12),
                  const Center(child: AppLogo(size: 96)),
                  const SizedBox(height: 18),
                  Text(
                    context.tr('app_name'),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: AppColors.primary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    context.tr('app_tagline'),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    context.tr('intro_headline'),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    context.tr('intro_sub'),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 28),
                  _FeatureRow(
                    icon: Icons.trending_up_rounded,
                    iconColor: AppColors.primary,
                    iconBackground: AppColors.primaryContainer,
                    title: context.tr('intro_feature_rates'),
                    subtitle: context.tr('intro_feature_rates_desc'),
                  ),
                  const SizedBox(height: 12),
                  _FeatureRow(
                    icon: Icons.handshake_outlined,
                    iconColor: AppColors.secondary,
                    iconBackground: AppColors.secondaryContainer,
                    title: context.tr('intro_feature_buyers'),
                    subtitle: context.tr('intro_feature_buyers_desc'),
                  ),
                  const SizedBox(height: 12),
                  _FeatureRow(
                    icon: Icons.auto_graph_rounded,
                    iconColor: AppColors.tertiary,
                    iconBackground: AppColors.tertiaryContainer,
                    title: context.tr('intro_feature_guidance'),
                    subtitle: context.tr('intro_feature_guidance_desc'),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SignUpScreen(),
                        ),
                      );
                    },
                    child: Text(context.tr('intro_get_started')),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    },
                    child: Text(context.tr('intro_have_account')),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String title;
  final String subtitle;

  const _FeatureRow({
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: iconBackground,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: theme.textTheme.bodyMedium?.copyWith(fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
