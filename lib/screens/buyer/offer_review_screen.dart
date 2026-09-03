import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import 'offer_submitted_screen.dart';

class OfferReviewScreen extends StatelessWidget {
  final String crop;
  final String quantity;
  final String offerPrice;
  final String location;
  final String askingPrice;

  const OfferReviewScreen({
    super.key,
    required this.crop,
    required this.quantity,
    required this.offerPrice,
    required this.location,
    required this.askingPrice,
  });

  double get _totalOfferValue {
    final price = double.tryParse(offerPrice.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
    final qty = double.tryParse(quantity.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
    return price * qty;
  }

  String _formatCurrency(double amount) {
    return '₹${amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d+?)(?=(\d\d)+(\d)(?!\d))(\.\d+)?'),
          (match) => '${match[1]},',
        )}';
  }

  void _onSubmitOffer(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OfferSubmittedScreen(
          crop: crop,
          quantity: quantity,
          offerPrice: offerPrice,
          location: location,
          askingPrice: askingPrice,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Offer'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          children: [
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
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
                    const SizedBox(height: 12),
                    Text(
                      crop,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 16,
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
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Offer Summary',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _SummaryRow(
                      icon: Icons.sell_outlined,
                      label: 'Asking Price',
                      value: askingPrice.contains('/qtl') ? askingPrice : '$askingPrice/qtl',
                    ),
                    const SizedBox(height: 10),
                    _SummaryRow(
                      icon: Icons.currency_rupee_rounded,
                      label: 'Your Offer Price',
                      value: offerPrice.contains('/qtl') ? offerPrice : '₹$offerPrice/qtl',
                      isHighlighted: true,
                    ),
                    const SizedBox(height: 10),
                    _SummaryRow(
                      icon: Icons.scale_rounded,
                      label: 'Quantity Requested',
                      value: quantity.contains('qtl') ? quantity : '$quantity qtl',
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Divider(color: AppColors.outlineVariant),
                    ),
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
                        children: [
                          const Text(
                            'Total Offer Value',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.onSurface,
                            ),
                          ),
                          Text(
                            _formatCurrency(_totalOfferValue),
                            style: const TextStyle(
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
            Card(
              color: AppColors.background,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: const BorderSide(color: AppColors.outlineVariant, width: 0.8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      size: 20,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Your offer will be sent to the farmer for review.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 12,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton.icon(
                onPressed: () => _onSubmitOffer(context),
                icon: const Icon(Icons.send_rounded),
                label: const Text('Submit Offer'),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isHighlighted;

  const _SummaryRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(icon, size: 18, color: isHighlighted ? AppColors.primary : AppColors.outline),
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
            fontSize: isHighlighted ? 15 : 14,
            fontWeight: isHighlighted ? FontWeight.w800 : FontWeight.w600,
            color: isHighlighted ? AppColors.primary : AppColors.onSurface,
          ),
        ),
      ],
    );
  }
}