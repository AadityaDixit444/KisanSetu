import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import 'make_offer_screen.dart';

class BuyerLotDetailsScreen extends StatelessWidget {
  final String crop;
  final String quantity;
  final String quality;
  final String askingPrice;
  final String location;
  final String distance;

  const BuyerLotDetailsScreen({
    super.key,
    required this.crop,
    required this.quantity,
    required this.quality,
    required this.askingPrice,
    required this.location,
    required this.distance,
  });

  void _onPlaceBid(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MakeOfferScreen(
          crop: crop,
          quantity: quantity,
          askingPrice: askingPrice,
          location: location,
        ),
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lot Details'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          children: [
            // Crop & Price Header Card
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
                            color: AppColors.primaryContainer,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'Active Lot',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.onPrimaryContainer,
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
                          backgroundColor: AppColors.primaryContainer,
                          child: Icon(
                            _getCropIcon(crop),
                            color: AppColors.primary,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
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
                                'Total Available: $quantity',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Asking Price',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontSize: 11,
                                color: AppColors.outline,
                              ),
                            ),
                            Text(
                              askingPrice,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
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
                    _SpecRow(
                      icon: Icons.scale_rounded,
                      label: 'Lot Quantity',
                      value: quantity,
                    ),
                    const SizedBox(height: 12),
                    _SpecRow(
                      icon: Icons.verified_outlined,
                      label: 'Quality Grade',
                      value: quality,
                    ),
                    const SizedBox(height: 12),
                    _SpecRow(
                      icon: Icons.currency_rupee_rounded,
                      label: 'Base Asking Price',
                      value: askingPrice,
                      isEmphasized: true,
                    ),
                    const SizedBox(height: 12),
                    const _SpecRow(
                      icon: Icons.calendar_today_rounded,
                      label: 'Listed On',
                      value: '03 Sep 2026',
                    ),
                  ],
                ),
              ),
            ),

            // Farmer Verification Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: AppColors.secondaryContainer,
                      child: const Icon(
                        Icons.agriculture_rounded,
                        color: AppColors.secondary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Text(
                                'Verified Farmer',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.onSurface,
                                ),
                              ),
                              SizedBox(width: 6),
                              Icon(
                                Icons.verified_rounded,
                                size: 16,
                                color: AppColors.secondary,
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Identity and landholding verified by KisanSetu',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontSize: 12,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Location & Logistics Card with Net Realisable Price
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Location & Sourcing Economics',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _SpecRow(
                      icon: Icons.location_on_outlined,
                      label: 'Origin Location',
                      value: location,
                    ),
                    const SizedBox(height: 12),
                    _SpecRow(
                      icon: Icons.near_me_outlined,
                      label: 'Distance to You',
                      value: distance,
                    ),
                    const SizedBox(height: 12),
                    const _SpecRow(
                      icon: Icons.local_shipping_outlined,
                      label: 'Estimated Transport',
                      value: '₹80/qtl',
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Divider(color: AppColors.outlineVariant),
                    ),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.savings_outlined,
                            color: AppColors.primary,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Estimated Net Realisable Price',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.onPrimaryContainer,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  '₹2,370/qtl',
                                  style: TextStyle(
                                    fontSize: 18,
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

            const SizedBox(height: 12),

            // Primary Bottom Action
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton.icon(
                onPressed: () => _onPlaceBid(context),
                icon: const Icon(Icons.gavel_rounded),
                label: const Text('Place Bid / Make Offer'),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _SpecRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isEmphasized;

  const _SpecRow({
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