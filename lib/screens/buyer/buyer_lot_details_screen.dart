import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import 'make_offer_screen.dart';

class BuyerLotDetailsScreen extends StatelessWidget {
  final String lotId;
  final String crop;
  final String quantity;
  final String quality;
  final String askingPrice;
  final String location;
  final String distance;

  const BuyerLotDetailsScreen({
    super.key,
    required this.lotId,
    required this.crop,
    required this.quantity,
    required this.quality,
    required this.askingPrice,
    required this.location,
    required this.distance,
  });

  IconData _getCropIcon(String cropName) {
    switch (cropName.toLowerCase()) {
      case 'wheat':
        return Icons.grass_rounded;
      case 'rice':
        return Icons.rice_bowl_rounded;
      case 'mustard':
        return Icons.spa_rounded;
      case 'maize':
        return Icons.grain_rounded;
      default:
        return Icons.eco_rounded;
    }
  }

  void _onPlaceBid(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MakeOfferScreen(
          lotId: lotId,
          crop: crop,
          quantity: quantity,
          askingPrice: askingPrice,
          location: location,
        ),
      ),
    );
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
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              color: AppColors.primaryContainer.withValues(alpha: 0.5),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: AppColors.primary,
                      child: Icon(
                        _getCropIcon(crop),
                        color: AppColors.onPrimary,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            crop,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.onPrimaryContainer,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Lot ID: $lotId',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.onPrimaryContainer,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Listed on 12 Sep 2026',
                            style: theme.textTheme.bodySmall?.copyWith(
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
            const SizedBox(height: 12),

            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Crop Specifications',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _SpecRow(
                      label: 'Available Quantity',
                      value: quantity,
                      icon: Icons.scale_outlined,
                    ),
                    const SizedBox(height: 10),
                    _SpecRow(
                      label: 'Quality Grade',
                      value: quality,
                      icon: Icons.verified_outlined,
                    ),
                    const SizedBox(height: 10),
                    _SpecRow(
                      label: 'Asking Price',
                      value: askingPrice,
                      icon: Icons.currency_rupee_rounded,
                      isHighlighted: true,
                    ),
                    const SizedBox(height: 10),
                    _SpecRow(
                      label: 'Location',
                      value: distance.isNotEmpty ? '$location ($distance)' : location,
                      icon: Icons.location_on_outlined,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Estimated Landed Cost',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const _CostRow(
                      label: 'Base Asking Price',
                      value: '₹2,450/qtl',
                    ),
                    const SizedBox(height: 8),
                    const _CostRow(
                      label: 'Estimated Freight/Logistics',
                      value: '+₹80/qtl',
                    ),
                    const SizedBox(height: 8),
                    const _CostRow(
                      label: 'Mandi Cess / Handling',
                      value: '+₹25/qtl',
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Divider(color: AppColors.outlineVariant),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Estimated Landed',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          '₹2,555/qtl',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton.icon(
                  onPressed: () => _onPlaceBid(context),
                  icon: const Icon(Icons.gavel_rounded),
                  label: const Text(
                    'Make Offer / Bid Now',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _SpecRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool isHighlighted;

  const _SpecRow({
    required this.label,
    required this.value,
    required this.icon,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: isHighlighted ? AppColors.primary : AppColors.outline,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isHighlighted ? 15 : 14,
            fontWeight: isHighlighted ? FontWeight.w800 : FontWeight.w600,
            color: isHighlighted ? AppColors.primary : AppColors.onSurface,
          ),
        ),
      ],
    );
  }
}

class _CostRow extends StatelessWidget {
  final String label;
  final String value;

  const _CostRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
          ),
        ),
      ],
    );
  }
}