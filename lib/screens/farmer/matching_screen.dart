import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class MatchingScreen extends StatelessWidget {
  const MatchingScreen({super.key});

  static final List<_BuyerMatch> _buyers = [
    _BuyerMatch(
      name: 'Kisan Agro Flour Mills',
      location: 'Karnal, Haryana',
      demand: '250 qtl Wheat',
      offeredPrice: '₹2,470/qtl',
      matchScore: 96,
      distance: '118 km',
      isVerified: true,
      matchReason: 'High price + strong demand',
    ),
    _BuyerMatch(
      name: 'Shree Balaji Grain Traders',
      location: 'Meerut, Uttar Pradesh',
      demand: '120 qtl Wheat',
      offeredPrice: '₹2,460/qtl',
      matchScore: 94,
      distance: '18 km',
      isVerified: true,
      matchReason: 'Closest buyer + suitable quantity',
    ),
    _BuyerMatch(
      name: 'Apex Food Processing Corp',
      location: 'Sonipat, Haryana',
      demand: '500 qtl Wheat',
      offeredPrice: '₹2,445/qtl',
      matchScore: 89,
      distance: '145 km',
      isVerified: true,
      matchReason: 'Large demand + good price',
    ),
    _BuyerMatch(
      name: 'Delhi Grain Hub',
      location: 'Delhi, NCR',
      demand: '180 qtl Wheat',
      offeredPrice: '₹2,430/qtl',
      matchScore: 84,
      distance: '78 km',
      isVerified: true,
      matchReason: 'Nearby market + moderate demand',
    ),
  ];

  void _onViewOffer(BuildContext context, String buyerName) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Offer details will open here'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Buyer Matching'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          children: [
            // Farmer Lot Summary Card
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
                          'Your Listed Produce',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Wheat',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Text(
                          '100 qtl',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: const [
                          _LotItem(label: 'Quality', value: 'Good Quality'),
                          _LotDivider(),
                          _LotItem(label: 'Location', value: 'Meerut'),
                          _LotDivider(),
                          _LotItem(label: 'Net Mandi Price', value: '₹2,320/qtl'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Expected Advantage Card
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
                          Icons.trending_up_rounded,
                          color: AppColors.primary,
                          size: 22,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Expected Advantage',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.onPrimaryContainer,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Best Offer',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.onPrimaryContainer,
                          ),
                        ),
                        const Text(
                          '₹2,470/qtl',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onPrimaryContainer,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Net after estimated logistics',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.onPrimaryContainer,
                          ),
                        ),
                        const Text(
                          '₹2,360/qtl',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onPrimaryContainer,
                          ),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Divider(color: AppColors.outlineVariant),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          'Advantage vs current mandi net price',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.onPrimaryContainer,
                          ),
                        ),
                        Text(
                          '+₹40/qtl',
                          style: TextStyle(
                            fontSize: 16,
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

            // Best Matches Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Best Matches',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Buyers ranked by price, demand, location and suitability',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),

            // Buyer Match Cards
            ...List.generate(_buyers.length, (index) {
              final buyer = _buyers[index];
              final isTopRanked = index == 0;

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: isTopRanked ? AppColors.primary : AppColors.outlineVariant,
                    width: isTopRanked ? 1.5 : 0.8,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        buyer.name,
                                        style: theme.textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    if (buyer.isVerified) ...[
                                      const SizedBox(width: 4),
                                      const Icon(
                                        Icons.verified_rounded,
                                        size: 16,
                                        color: AppColors.secondary,
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.location_on_outlined,
                                      size: 14,
                                      color: AppColors.outline,
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      '${buyer.location} • ${buyer.distance}',
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primaryContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${buyer.matchScore}% Match',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: AppColors.onPrimaryContainer,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Demand',
                                  style: theme.textTheme.bodyMedium?.copyWith(fontSize: 11),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  buyer.demand,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Offered Price',
                                  style: theme.textTheme.bodyMedium?.copyWith(fontSize: 11),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  buyer.offeredPrice,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(
                            Icons.auto_awesome,
                            size: 14,
                            color: AppColors.tertiary,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              buyer.matchReason,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Why this match section for top ranked buyer
                      if (isTopRanked) ...[
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Divider(color: AppColors.outlineVariant),
                        ),
                        Text(
                          'Why this match?',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: const [
                            _MatchPill(label: 'Crop match'),
                            _MatchPill(label: 'Quantity match'),
                            _MatchPill(label: 'Quality match'),
                            _MatchPill(label: 'Price advantage'),
                            _MatchPill(label: 'Location suitability'),
                          ],
                        ),
                      ],

                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 40,
                        child: OutlinedButton(
                          onPressed: () => _onViewOffer(context, buyer.name),
                          child: const Text(
                            'View Offer',
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _BuyerMatch {
  final String name;
  final String location;
  final String demand;
  final String offeredPrice;
  final int matchScore;
  final String distance;
  final bool isVerified;
  final String matchReason;

  _BuyerMatch({
    required this.name,
    required this.location,
    required this.demand,
    required this.offeredPrice,
    required this.matchScore,
    required this.distance,
    required this.isVerified,
    required this.matchReason,
  });
}

class _LotItem extends StatelessWidget {
  final String label;
  final String value;

  const _LotItem({required this.label, required this.value});

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

class _LotDivider extends StatelessWidget {
  const _LotDivider();

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

class _MatchPill extends StatelessWidget {
  final String label;

  const _MatchPill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.secondaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.check_circle_rounded,
            size: 12,
            color: AppColors.secondary,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.onSecondaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}