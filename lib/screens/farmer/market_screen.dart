import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import 'matching_screen.dart';
import 'simulator_screen.dart';

class MarketScreen extends StatelessWidget {
  const MarketScreen({super.key});

  void _navigateToSimulator(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SimulatorScreen(),
      ),
    );
  }

  void _navigateToMatching(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MatchingScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Market Overview'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Mandi Live Rates Card
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
                          'Live APMC Rates',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: AppColors.onSurfaceVariant,
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
                            'Meerut Mandi',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.onPrimaryContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          'Wheat',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Text(
                          '₹2,450/qtl',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.arrow_upward_rounded,
                          size: 16,
                          color: AppColors.success,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '+3.4% today',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '• Arrivals tightening',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // AI Selling Signal Card
            Card(
              color: AppColors.tertiaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.auto_awesome_rounded,
                        color: AppColors.tertiary,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'AI SELLING SIGNAL',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.onTertiaryContainer,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'HOLD PRODUCE',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: AppColors.tertiary,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Prices are predicted to rise next week by ~₹40/qtl. Evaluate storage charges against expected gains.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.onTertiaryContainer,
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

            // Other Crop Rates Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Other Mandi Commodities',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const _CommodityRateRow(
                      crop: 'Rice (Basmati)',
                      price: '₹3,200/qtl',
                      change: '+1.8%',
                      isPositive: true,
                    ),
                    const Divider(color: AppColors.outlineVariant, height: 20),
                    const _CommodityRateRow(
                      crop: 'Mustard',
                      price: '₹5,100/qtl',
                      change: '-0.5%',
                      isPositive: false,
                    ),
                    const Divider(color: AppColors.outlineVariant, height: 20),
                    const _CommodityRateRow(
                      crop: 'Sugarcane',
                      price: '₹380/qtl',
                      change: '0.0%',
                      isPositive: true,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Action CTA Cards
            Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.secondaryContainer,
                  child: const Icon(
                    Icons.tune_rounded,
                    color: AppColors.secondary,
                  ),
                ),
                title: const Text(
                  'Simulate Holding Strategy',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text('Test hold duration vs storage charges'),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                onTap: () => _navigateToSimulator(context),
              ),
            ),
            const SizedBox(height: 8),

            Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.primaryContainer,
                  child: const Icon(
                    Icons.handshake_rounded,
                    color: AppColors.primary,
                  ),
                ),
                title: const Text(
                  'Find Matching Buyers',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text('Connect with buyers actively seeking Wheat'),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                onTap: () => _navigateToMatching(context),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _CommodityRateRow extends StatelessWidget {
  final String crop;
  final String price;
  final String change;
  final bool isPositive;

  const _CommodityRateRow({
    required this.crop,
    required this.price,
    required this.change,
    required this.isPositive,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          crop,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        Row(
          children: [
            Text(
              price,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: (isPositive ? AppColors.success : AppColors.error)
                    .withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                change,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isPositive ? AppColors.success : AppColors.error,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}