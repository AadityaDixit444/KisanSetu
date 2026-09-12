import 'package:flutter/material.dart';
import '../../localization/language_scope.dart';
import '../../theme/app_colors.dart';
import 'buyer_offers_screen.dart';

class LotDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> lot;

  const LotDetailsScreen({super.key, required this.lot});

  double _parseDouble(dynamic val) {
    if (val == null) return 0.0;
    if (val is num) return val.toDouble();
    return double.tryParse(val.toString().replaceAll(RegExp(r'[^0-9.-]'), '')) ?? 0.0;
  }

  String _formatPrice(dynamic rawPrice) {
    final val = _parseDouble(rawPrice);
    if (val % 1 == 0) {
      return '₹${val.toInt().toString().replaceAllMapped(RegExp(r'(\d+?)(?=(\d\d)+(\d)(?!\d))(\.\d+)?'), (m) => '${m[1]},')}/qtl';
    }
    return '₹${val.toStringAsFixed(2)}/qtl';
  }

  String _formatQuantity(dynamic rawQty) {
    final val = _parseDouble(rawQty);
    return val % 1 == 0 ? '${val.toInt()} qtl' : '$val qtl';
  }

  String _formatLotId(dynamic rawId) {
    if (rawId == null) return 'LOT-N/A';
    final idStr = rawId.toString();
    if (idStr.length > 8) {
      return 'LOT-${idStr.substring(0, 8).toUpperCase()}';
    }
    return 'LOT-${idStr.toUpperCase()}';
  }

  String _formatDate(dynamic rawDate) {
    if (rawDate == null) return 'Immediate';
    try {
      final parsed = DateTime.parse(rawDate.toString());
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      final day = parsed.day.toString().padLeft(2, '0');
      return '$day ${months[parsed.month - 1]} ${parsed.year}';
    } catch (_) {
      return rawDate.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final rawId = lot['id'];
    final lotIdDisplay = _formatLotId(rawId);
    final crop = lot['crop']?.toString() ?? 'Produce';
    final quantity = _formatQuantity(lot['quantity']);
    final askingPrice = _formatPrice(lot['asking_price'] ?? lot['expected_price'] ?? lot['price']);
    final quality = lot['quality']?.toString() ?? 'Standard';
    final location = lot['location']?.toString() ?? 'Local Mandi';
    final availableFrom = _formatDate(lot['available_from'] ?? lot['created_at']);
    final status = lot['status']?.toString() ?? 'Active';
    final isActive = status.toLowerCase().trim() == 'active';

    final dynamic offersRaw = lot['offers'];
    int offerCount = 0;
    if (offersRaw is List) {
      offerCount = offersRaw.length;
    } else if (lot['offers_count'] != null) {
      offerCount = _parseDouble(lot['offers_count']).toInt();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('lot_details')),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                crop,
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${context.tr('lot_id')}: $lotIdDisplay',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppColors.outline,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isActive ? AppColors.primaryContainer : AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            status.toUpperCase(),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isActive ? AppColors.primary : AppColors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [ 
                          Text(
                            context.tr('estimated_net_realisable_price'),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            askingPrice,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
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
            const SizedBox(height: 16),
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr('produce_specifications'),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(height: 24, color: AppColors.outlineVariant),
                    _SpecItem(
                      label: context.tr('quantity'),
                      value: quantity,
                      icon: Icons.scale_outlined,
                    ),
                    const SizedBox(height: 12),
                    _SpecItem(
                      label: context.tr('quality_grade'),
                      value: quality,
                      icon: Icons.verified_outlined,
                    ),
                    const SizedBox(height: 12),
                    _SpecItem(
                      label: context.tr('expected_price'),
                      value: askingPrice,
                      icon: Icons.currency_rupee_rounded,
                      valueColor: AppColors.primary,
                      isBold: true,
                    ),
                    const SizedBox(height: 12),
                    _SpecItem(
                      label: context.tr('location'),
                      value: location,
                      icon: Icons.location_on_outlined,
                    ),
                    const SizedBox(height: 12),
                    _SpecItem(
                      label: context.tr('available_from'),
                      value: availableFrom,
                      icon: Icons.calendar_today_outlined,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BuyerOffersScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.local_offer_outlined),
                label: Text(
                  offerCount > 0
                      ? '${context.tr('view_buyer_offers')} ($offerCount)'
                      : context.tr('view_buyer_offers'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SpecItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? valueColor;
  final bool isBold;

  const _SpecItem({
    required this.label,
    required this.value,
    required this.icon,
    this.valueColor,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.outline),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 15 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: valueColor ?? AppColors.onSurface,
          ),
        ),
      ],
    );
  }
}