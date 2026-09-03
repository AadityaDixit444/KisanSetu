import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import 'buyer_offers_screen.dart';

class LotDetailsScreen extends StatelessWidget {
  final String crop;
  final String quantity;
  final String quality;
  final String location;
  final String expectedPrice;
  final String status;

  const LotDetailsScreen({
    super.key,
    required this.crop,
    required this.quantity,
    required this.quality,
    required this.location,
    required this.expectedPrice,
    required this.status,
  });

  void _onViewBuyerOffers(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const BuyerOffersScreen(),
      ),
    );
  }

  IconData _getCropIcon(String cropName) {
    switch (cropName.toLowerCase()) {
      case 'wheat':
        return Icons.eco_rounded;
      case 'rice':
        return Icons.grass_rounded;
      case 'maize':
        return Icons.grain_rounded;
      default:
        return Icons.agriculture_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isActive = status.toLowerCase() == 'active';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lot Details'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          children: [
            // Header Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.outlineVariant),
                          ),
                          child: const Text(
                            'Lot ID: KS-LOT-1001',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isActive
                                ? AppColors.primaryContainer
                                : AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            status,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: isActive
                                  ? AppColors.onPrimaryContainer
                                  : AppColors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: isActive
                              ? AppColors.primaryContainer
                              : AppColors.surfaceVariant,
                          child: Icon(
                            _getCropIcon(crop),
                            color: isActive ? AppColors.primary : AppColors.outline,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              crop,
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Available From: 03 Sep 2026',
                              style: theme.textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calculate_outlined,
                            color: AppColors.primary,
                            size: 22,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Estimated Net Realisable Price',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontSize: 12,
                                    color: AppColors.onPrimaryContainer,
                                  ),
                                ),
                                const SizedBox(height: 1),
                                const Text(
                                  '₹2,320/qtl',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Produce Specifications Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Produce Specifications',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _SpecificationRow(
                      icon: Icons.scale_rounded,
                      label: 'Quantity',
                      value: quantity,
                    ),
                    const SizedBox(height: 12),
                    _SpecificationRow(
                      icon: Icons.verified_outlined,
                      label: 'Quality Grade',
                      value: quality,
                    ),
                    const SizedBox(height: 12),
                    _SpecificationRow(
                      icon: Icons.currency_rupee_rounded,
                      label: 'Expected Price',
                      value: expectedPrice,
                      isEmphasized: true,
                    ),
                    const SizedBox(height: 12),
                    _SpecificationRow(
                      icon: Icons.location_on_outlined,
                      label: 'Location',
                      value: location,
                    ),
                    const SizedBox(height: 12),
                    const _SpecificationRow(
                      icon: Icons.calendar_today_rounded,
                      label: 'Available From',
                      value: '03 Sep 2026',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Call to Action
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton.icon(
                onPressed: () => _onViewBuyerOffers(context),
                icon: const Icon(Icons.local_offer_rounded),
                label: const Text('View Buyer Offers'),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _SpecificationRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isEmphasized;

  const _SpecificationRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isEmphasized = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.outlineVariant, width: 0.7),
          ),
          child: Icon(icon, size: 18, color: AppColors.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 12,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isEmphasized ? AppColors.primary : AppColors.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}