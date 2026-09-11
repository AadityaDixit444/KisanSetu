import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../localization/language_scope.dart';
import '../../widgets/language_toggle_button.dart';

class OfferDetailsScreen extends StatelessWidget {
  final String crop;
  final String quantity;
  final String location;
  final String askingPrice;
  final String yourOffer;
  final String totalValue;
  final String status;

  const OfferDetailsScreen({
    super.key,
    required this.crop,
    required this.quantity,
    required this.location,
    required this.askingPrice,
    required this.yourOffer,
    required this.totalValue,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('offer_details_title')),
        actions: const [
          Center(child: LanguageToggleButton(isLightSurface: false)),
          SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Crop & Location Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      crop,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 18,
                          color: AppColors.outline,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          location,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Offer Information Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr('offer_summary'),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(height: 24, color: AppColors.outlineVariant),
                    _buildDetailRow(context.tr('lot_quantity'), quantity),
                    const SizedBox(height: 10),
                    _buildDetailRow(context.tr('asking_price'), askingPrice),
                    const SizedBox(height: 10),
                    _buildDetailRow(context.tr('your_offer_label'), yourOffer, isHighlighted: true),
                    const SizedBox(height: 10),
                    _buildDetailRow(context.tr('total_offer_value'), totalValue, isBold: true),
                    const SizedBox(height: 10),
                    _buildDetailRow(context.tr('status_label'), status),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Offer Progress Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr('offer_progress'),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _ProgressStep(
                      step: '1',
                      title: context.tr('step_offer_submitted'),
                      status: context.tr('status_completed'),
                      isCompleted: true,
                    ),
                    _ProgressStep(
                      step: '2',
                      title: context.tr('step_farmer_review'),
                      status: context.tr('status_pending'),
                      isCompleted: false,
                    ),
                    _ProgressStep(
                      step: '3',
                      title: context.tr('step_deal_confirmation'),
                      status: context.tr('status_pending'),
                      isCompleted: false,
                      isLast: true,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isHighlighted = false, bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.onSurfaceVariant,
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isBold || isHighlighted ? FontWeight.bold : FontWeight.w500,
            color: isHighlighted ? AppColors.primary : AppColors.onSurface,
          ),
        ),
      ],
    );
  }
}

class _ProgressStep extends StatelessWidget {
  final String step;
  final String title;
  final String status;
  final bool isCompleted;
  final bool isLast;

  _ProgressStep({
    required this.step,
    required this.title,
    required this.status,
    required this.isCompleted,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            CircleAvatar(
              radius: 12,
              backgroundColor: isCompleted ? AppColors.primary : AppColors.outlineVariant,
              child: isCompleted
                  ? const Icon(Icons.check, size: 14, color: AppColors.onPrimary)
                  : Text(
                      step,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.onSurfaceVariant,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 24,
                color: isCompleted ? AppColors.primary : AppColors.outlineVariant,
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: isCompleted ? FontWeight.bold : FontWeight.normal,
                    color: AppColors.onSurface,
                  ),
                ),
                Text(
                  status,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isCompleted ? AppColors.primary : AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}