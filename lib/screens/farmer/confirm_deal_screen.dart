import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import 'logistics_screen.dart';

class ConfirmDealScreen extends StatelessWidget {
  const ConfirmDealScreen({super.key});

  void _onConfirmDeal(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const LogisticsScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirm Deal'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          children: [
            // Page Heading
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Review Your Deal',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Verify deal terms and counterparty details before finalizing',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Buyer Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: AppColors.secondaryContainer,
                      child: const Icon(
                        Icons.storefront_rounded,
                        color: AppColors.secondary,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  'Kisan Agro Flour Mills',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(
                                Icons.verified_rounded,
                                size: 16,
                                color: AppColors.secondary,
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                size: 14,
                                color: AppColors.outline,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                'Karnal, Haryana • 118 km',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Deal Details Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Deal Specifications',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'Wheat • 100 qtl',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.onPrimaryContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const _DealItemRow(label: 'Crop', value: 'Wheat'),
                    const SizedBox(height: 8),
                    const _DealItemRow(label: 'Quantity', value: '100 qtl'),
                    const SizedBox(height: 8),
                    const _DealItemRow(label: 'Quality Grade', value: 'Good'),
                    const SizedBox(height: 8),
                    const _DealItemRow(label: 'Offered Price', value: '₹2,470/qtl'),
                    const SizedBox(height: 8),
                    const _DealItemRow(
                      label: 'Estimated Logistics',
                      value: '-₹110/qtl',
                      isDeduction: true,
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Divider(color: AppColors.outlineVariant),
                    ),
                    const _DealItemRow(
                      label: 'Net Realisable Price',
                      value: '₹2,360/qtl',
                      isHighlighted: true,
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text(
                            'Estimated Total Value',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.onSurface,
                            ),
                          ),
                          Text(
                            '₹2,36,000',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // What happens next Info Card
            Card(
              color: AppColors.primaryContainer.withValues(alpha: 0.5),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(
                          Icons.info_outline_rounded,
                          size: 20,
                          color: AppColors.primary,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'What happens next?',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.onPrimaryContainer,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const _NextStepItem(step: '1', text: 'Buyer confirms the order'),
                    const SizedBox(height: 8),
                    const _NextStepItem(step: '2', text: 'Logistics are arranged'),
                    const SizedBox(height: 8),
                    const _NextStepItem(step: '3', text: 'Delivery is completed'),
                    const SizedBox(height: 8),
                    const _NextStepItem(
                      step: '4',
                      text: 'Payment is tracked through KisanSetu',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Confirm Deal Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.handshake_rounded),
                label: const Text('Confirm Deal'),
                onPressed: () => _onConfirmDeal(context),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _DealItemRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isDeduction;
  final bool isHighlighted;

  const _DealItemRow({
    required this.label,
    required this.value,
    this.isDeduction = false,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: isHighlighted ? FontWeight.w700 : FontWeight.w500,
            color: isHighlighted ? AppColors.onSurface : AppColors.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isHighlighted ? 16 : 14,
            fontWeight: isHighlighted ? FontWeight.w800 : FontWeight.w600,
            color: isDeduction
                ? AppColors.error
                : isHighlighted
                    ? AppColors.primary
                    : AppColors.onSurface,
          ),
        ),
      ],
    );
  }
}

class _NextStepItem extends StatelessWidget {
  final String step;
  final String text;

  const _NextStepItem({
    required this.step,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 10,
          backgroundColor: AppColors.primary,
          child: Text(
            step,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppColors.onPrimary,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.onPrimaryContainer,
            ),
          ),
        ),
      ],
    );
  }
}