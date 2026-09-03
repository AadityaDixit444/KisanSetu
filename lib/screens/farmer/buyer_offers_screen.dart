import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import 'confirm_deal_screen.dart';

class BuyerOffersScreen extends StatelessWidget {
  const BuyerOffersScreen({super.key});

  static final List<_BuyerOffer> _offers = [
    _BuyerOffer(
      buyerName: 'Kisan Agro Flour Mills',
      location: 'Karnal, Haryana',
      distance: '118 km',
      demand: '250 qtl',
      offeredPrice: '₹2,470/qtl',
      logistics: '₹110/qtl',
      netPrice: '₹2,360/qtl',
      status: 'Best Offer',
      statusColor: AppColors.primary,
      statusBgColor: AppColors.primaryContainer,
    ),
    _BuyerOffer(
      buyerName: 'Shree Balaji Grain Traders',
      location: 'Meerut, Uttar Pradesh',
      distance: '18 km',
      demand: '120 qtl',
      offeredPrice: '₹2,460/qtl',
      logistics: '₹40/qtl',
      netPrice: '₹2,420/qtl',
      status: 'Nearby Buyer',
      statusColor: AppColors.secondary,
      statusBgColor: AppColors.secondaryContainer,
    ),
    _BuyerOffer(
      buyerName: 'Apex Food Processing Corp',
      location: 'Sonipat, Haryana',
      distance: '145 km',
      demand: '500 qtl',
      offeredPrice: '₹2,445/qtl',
      logistics: '₹125/qtl',
      netPrice: '₹2,320/qtl',
      status: 'Large Demand',
      statusColor: AppColors.tertiary,
      statusBgColor: AppColors.tertiaryContainer,
    ),
    _BuyerOffer(
      buyerName: 'Delhi Grain Hub',
      location: 'Delhi, NCR',
      distance: '78 km',
      demand: '180 qtl',
      offeredPrice: '₹2,430/qtl',
      logistics: '₹80/qtl',
      netPrice: '₹2,350/qtl',
      status: 'Good Offer',
      statusColor: AppColors.primary,
      statusBgColor: AppColors.primaryContainer,
    ),
  ];

  void _onAcceptOffer(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ConfirmDealScreen(),
      ),
    );
  }

  void _onDeclineOffer(BuildContext context) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Offer declined.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Buyer Offers'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          children: [
            // Lot Summary Card
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
                          'Lot Summary',
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
                    Text(
                      'Wheat',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
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
                          _LotMetaItem(label: 'Quantity', value: '100 qtl'),
                          _LotDivider(),
                          _LotMetaItem(label: 'Quality', value: 'Good'),
                          _LotDivider(),
                          _LotMetaItem(label: 'Location', value: 'Meerut'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Section Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Received Offers',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // Buyer Offer Cards
            ..._offers.map((offer) {
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: offer.status == 'Best Offer'
                        ? AppColors.primary
                        : AppColors.outlineVariant,
                    width: offer.status == 'Best Offer' ? 1.5 : 0.8,
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
                                        offer.buyerName,
                                        style: theme.textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(
                                      Icons.verified_rounded,
                                      size: 16,
                                      color: AppColors.secondary,
                                    ),
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
                                      '${offer.location} • ${offer.distance}',
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
                              color: offer.statusBgColor,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              offer.status,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: offer.statusColor,
                              ),
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
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Demand',
                                  style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
                                ),
                                Text(
                                  offer.demand,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Offered Price',
                                  style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
                                ),
                                Text(
                                  offer.offeredPrice,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.onSurface,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Est. Logistics Cost',
                                  style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
                                ),
                                Text(
                                  '-${offer.logistics}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.error,
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
                              children: [
                                Text(
                                  'Net Realisable Price',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  offer.netPrice,
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
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 40,
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.error,
                                  side: const BorderSide(color: AppColors.error),
                                ),
                                onPressed: () => _onDeclineOffer(context),
                                child: const Text('Decline'),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: SizedBox(
                              height: 40,
                              child: ElevatedButton(
                                onPressed: () => _onAcceptOffer(context),
                                child: const Text('Accept Offer'),
                              ),
                            ),
                          ),
                        ],
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

class _BuyerOffer {
  final String buyerName;
  final String location;
  final String distance;
  final String demand;
  final String offeredPrice;
  final String logistics;
  final String netPrice;
  final String status;
  final Color statusColor;
  final Color statusBgColor;

  _BuyerOffer({
    required this.buyerName,
    required this.location,
    required this.distance,
    required this.demand,
    required this.offeredPrice,
    required this.logistics,
    required this.netPrice,
    required this.status,
    required this.statusColor,
    required this.statusBgColor,
  });
}

class _LotMetaItem extends StatelessWidget {
  final String label;
  final String value;

  const _LotMetaItem({required this.label, required this.value});

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