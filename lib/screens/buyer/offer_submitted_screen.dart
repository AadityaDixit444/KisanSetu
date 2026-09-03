import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import 'browse_lots_screen.dart';
import 'my_offers_screen.dart';

class OfferSubmittedScreen extends StatelessWidget {
  final String crop;
  final String quantity;
  final String offerPrice;
  final String location;
  final String askingPrice;

  const OfferSubmittedScreen({
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

  void _onViewMyOffers(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MyOffersScreen(),
      ),
    );
  }

  void _onBackToBrowseLots(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const BrowseLotsScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Offer Submitted'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          children: [
            Card(
              color: AppColors.primaryContainer.withValues(alpha: 0.6),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: AppColors.onPrimary,
                        size: 36,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Offer Sent Successfully',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Your offer has been sent to the farmer for review.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.onPrimaryContainer,
                      ),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Offer Details',
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
                            color: AppColors.warning.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'Pending Farmer Response',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.warning,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _DetailItemRow(
                      icon: Icons.eco_rounded,
                      label: 'Crop & Quantity',
                      value: '$crop • ${quantity.contains('qtl') ? quantity : '$quantity qtl'}',
                    ),
                    const SizedBox(height: 10),
                    _DetailItemRow(
                      icon: Icons.location_on_outlined,
                      label: 'Lot Location',
                      value: location,
                    ),
                    const SizedBox(height: 10),
                    _DetailItemRow(
                      icon: Icons.sell_outlined,
                      label: 'Asking Price',
                      value: askingPrice.contains('/qtl') ? askingPrice : '$askingPrice/qtl',
                    ),
                    const SizedBox(height: 10),
                    _DetailItemRow(
                      icon: Icons.currency_rupee_rounded,
                      label: 'Your Offer Price',
                      value: offerPrice.contains('/qtl') ? offerPrice : '₹$offerPrice/qtl',
                      isHighlighted: true,
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
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Offer Progress',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const _TimelineStepTile(
                      stepNumber: 1,
                      title: 'Offer Submitted',
                      isCompleted: true,
                      isLast: false,
                    ),
                    const _TimelineStepTile(
                      stepNumber: 2,
                      title: 'Farmer Review',
                      isCompleted: false,
                      isLast: false,
                    ),
                    const _TimelineStepTile(
                      stepNumber: 3,
                      title: 'Deal Confirmation',
                      isCompleted: false,
                      isLast: true,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _onViewMyOffers(context),
                      icon: const Icon(Icons.receipt_long_rounded),
                      label: const Text('View My Offers'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _onBackToBrowseLots(context),
                      icon: const Icon(Icons.arrow_back_rounded),
                      label: const Text('Back to Browse Lots'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _DetailItemRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isHighlighted;

  const _DetailItemRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: isHighlighted ? AppColors.primary : AppColors.outline),
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

class _TimelineStepTile extends StatelessWidget {
  final int stepNumber;
  final String title;
  final bool isCompleted;
  final bool isLast;

  const _TimelineStepTile({
    required this.stepNumber,
    required this.title,
    required this.isCompleted,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            CircleAvatar(
              radius: 12,
              backgroundColor: isCompleted
                  ? AppColors.primary
                  : AppColors.outlineVariant.withValues(alpha: 0.6),
              child: isCompleted
                  ? const Icon(
                      Icons.check,
                      size: 14,
                      color: AppColors.onPrimary,
                    )
                  : Text(
                      '$stepNumber',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 28,
                color: isCompleted ? AppColors.primary : AppColors.outlineVariant,
              ),
          ],
        ),
        const SizedBox(width: 12),
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Row(
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: isCompleted ? FontWeight.w700 : FontWeight.w500,
                      color: isCompleted ? AppColors.onSurface : AppColors.outline,
                    ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? AppColors.primaryContainer
                      : AppColors.background,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  isCompleted ? 'Completed' : 'Pending',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: isCompleted
                        ? AppColors.onPrimaryContainer
                        : AppColors.outline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}