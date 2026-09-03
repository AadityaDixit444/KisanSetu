import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class SimulatorScreen extends StatelessWidget {
  const SimulatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('What-If Simulator'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          children: [
            // Simulation Parameters Card
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
                          'Simulation Parameters',
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
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: const [
                          _ParamCol(label: 'Spot Price', value: '₹2,450/qtl'),
                          _ParamDivider(),
                          _ParamCol(label: 'Transport', value: '₹80/qtl'),
                          _ParamDivider(),
                          _ParamCol(label: 'Storage', value: '₹50/qtl'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Base Strategies Section Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Text(
                'Strategy Comparison (Expected Market)',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // Strategy 1: Sell Now
            const _StrategyCard(
              title: '1. Sell Now',
              sellingPrice: '₹2,450/qtl',
              totalCost: '₹8,000',
              netReturn: '₹2,37,000',
              riskLabel: 'Low Risk',
              riskColor: AppColors.success,
              riskBgColor: Color(0xFFE8F5E9),
              isRecommended: false,
            ),

            // Strategy 3 (Highlighted): Sell 40% Now + Hold 60%
            const _StrategyCard(
              title: '3. Sell 40% Now + Hold 60%',
              sellingPrice: '₹2,450 now / ₹2,520 later',
              totalCost: '₹11,000',
              netReturn: '₹2,38,200',
              riskLabel: 'Balanced Risk',
              riskColor: AppColors.primary,
              riskBgColor: AppColors.primaryContainer,
              isRecommended: true,
            ),

            // Strategy 2: Hold for 7 Days
            const _StrategyCard(
              title: '2. Hold for 7 Days',
              sellingPrice: '₹2,520/qtl (Projected)',
              totalCost: '₹13,000',
              netReturn: '₹2,39,000',
              riskLabel: 'High Risk',
              riskColor: AppColors.error,
              riskBgColor: Color(0xFFFFEBEE),
              isRecommended: false,
            ),

            const SizedBox(height: 12),

            // Stress-Test Scenario: 5% Price Drop
            Card(
              color: const Color(0xFFFFF7F2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: AppColors.tertiary, width: 1.2),
              ),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.tertiaryContainer,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(
                            Icons.trending_down_rounded,
                            size: 18,
                            color: AppColors.tertiary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Simulate 5% Price Drop',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.tertiary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'If mandi rates drop to ₹2,328/qtl due to arrival surges or rain disruptions:',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const _ScenarioImpactTile(
                      strategyName: 'Sell Now',
                      netReturn: '₹2,37,000',
                      protectionNote: 'Locked profit; zero exposure to price fall',
                      impactColor: AppColors.success,
                      delta: '0% impact',
                    ),
                    const SizedBox(height: 8),
                    const _ScenarioImpactTile(
                      strategyName: 'Sell 40% + Hold 60%',
                      netReturn: '₹2,27,480',
                      protectionNote: '+₹7,680 higher protection vs full holding',
                      impactColor: AppColors.tertiary,
                      delta: '-₹9,520 impact',
                    ),
                    const SizedBox(height: 8),
                    const _ScenarioImpactTile(
                      strategyName: 'Hold for 7 Days',
                      netReturn: '₹2,19,800',
                      protectionNote: 'Maximum vulnerability; ₹17,200 total loss vs Sell Now',
                      impactColor: AppColors.error,
                      delta: '-₹17,200 impact',
                    ),
                  ],
                ),
              ),
            ),

            // Simulation Disclaimer
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    size: 16,
                    color: AppColors.outline,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Disclaimer: Figures are simulated estimates for planning and do not guarantee final mandi realizations or returns.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 12,
                        color: AppColors.outline,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _StrategyCard extends StatelessWidget {
  final String title;
  final String sellingPrice;
  final String totalCost;
  final String netReturn;
  final String riskLabel;
  final Color riskColor;
  final Color riskBgColor;
  final bool isRecommended;

  const _StrategyCard({
    required this.title,
    required this.sellingPrice,
    required this.totalCost,
    required this.netReturn,
    required this.riskLabel,
    required this.riskColor,
    required this.riskBgColor,
    required this.isRecommended,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isRecommended ? AppColors.primary : AppColors.outlineVariant,
          width: isRecommended ? 1.8 : 0.8,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
                if (isRecommended)
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'RECOMMENDED',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: AppColors.onPrimary,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: riskBgColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    riskLabel,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: riskColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _SimRow(label: 'Selling Price', value: sellingPrice),
            const SizedBox(height: 6),
            _SimRow(label: 'Estimated Costs', value: totalCost),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Divider(color: AppColors.outlineVariant),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Expected Net Return',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                ),
                Text(
                  netReturn,
                  style: const TextStyle(
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
    );
  }
}

class _ScenarioImpactTile extends StatelessWidget {
  final String strategyName;
  final String netReturn;
  final String protectionNote;
  final Color impactColor;
  final String delta;

  const _ScenarioImpactTile({
    required this.strategyName,
    required this.netReturn,
    required this.protectionNote,
    required this.impactColor,
    required this.delta,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.outlineVariant, width: 0.7),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                strategyName,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Row(
                children: [
                  Text(
                    netReturn,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: impactColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      delta,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: impactColor,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            protectionNote,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: 12,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _SimRow extends StatelessWidget {
  final String label;
  final String value;

  const _SimRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
          ),
        ),
      ],
    );
  }
}

class _ParamCol extends StatelessWidget {
  final String label;
  final String value;

  const _ParamCol({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(fontSize: 11),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _ParamDivider extends StatelessWidget {
  const _ParamDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 28,
      width: 1,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: AppColors.outlineVariant,
    );
  }
}