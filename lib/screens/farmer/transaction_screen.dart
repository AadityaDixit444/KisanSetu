import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import 'payment_details_screen.dart';

class TransactionScreen extends StatelessWidget {
  const TransactionScreen({super.key});

  void _onViewPaymentDetails(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PaymentDetailsScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction & Payment'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          children: [
            // Delivery Completed Status Card
            Card(
              color: AppColors.primaryContainer.withValues(alpha: 0.6),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.verified_rounded,
                        color: AppColors.onPrimary,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Delivery Completed',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.onPrimaryContainer,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Produce received and verified by buyer.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.onPrimaryContainer,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Settlement Summary Card
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
                          'Settlement Summary',
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
                            'Payment Pending',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.warning,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
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
                        'Transaction ID: KS-TXN-1001',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const _TxnDetailRow(
                      icon: Icons.storefront_rounded,
                      label: 'Buyer',
                      value: 'Kisan Agro Flour Mills',
                    ),
                    const SizedBox(height: 8),
                    const _TxnDetailRow(
                      icon: Icons.eco_rounded,
                      label: 'Crop & Quantity',
                      value: 'Wheat • 100 qtl',
                    ),
                    const SizedBox(height: 8),
                    const _TxnDetailRow(
                      icon: Icons.sell_outlined,
                      label: 'Agreed Price',
                      value: '₹2,470/qtl',
                    ),
                    const SizedBox(height: 8),
                    const _TxnDetailRow(
                      icon: Icons.local_shipping_outlined,
                      label: 'Transport Cost',
                      value: '-₹11,000',
                      isDeduction: true,
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
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
                        children: const [
                          Text(
                            'Net Amount',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.onSurface,
                            ),
                          ),
                          Text(
                            '₹2,36,000',
                            style: TextStyle(
                              fontSize: 20,
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

            // Transaction Timeline Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Transaction Timeline',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const _TxnTimelineTile(
                      stepNumber: 1,
                      title: 'Deal Confirmed',
                      isCompleted: true,
                      isLast: false,
                    ),
                    const _TxnTimelineTile(
                      stepNumber: 2,
                      title: 'Transport Arranged',
                      isCompleted: true,
                      isLast: false,
                    ),
                    const _TxnTimelineTile(
                      stepNumber: 3,
                      title: 'Delivery Completed',
                      isCompleted: true,
                      isLast: false,
                    ),
                    const _TxnTimelineTile(
                      stepNumber: 4,
                      title: 'Payment Processing',
                      isCompleted: false,
                      isLast: false,
                    ),
                    const _TxnTimelineTile(
                      stepNumber: 5,
                      title: 'Payment Received',
                      isCompleted: false,
                      isLast: true,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // View Payment Details Action Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton.icon(
                onPressed: () => _onViewPaymentDetails(context),
                icon: const Icon(Icons.account_balance_wallet_rounded),
                label: const Text('View Payment Details'),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _TxnDetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isDeduction;

  const _TxnDetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isDeduction = false,
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
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: isDeduction ? AppColors.error : AppColors.onSurface,
          ),
        ),
      ],
    );
  }
}

class _TxnTimelineTile extends StatelessWidget {
  final int stepNumber;
  final String title;
  final bool isCompleted;
  final bool isLast;

  const _TxnTimelineTile({
    required this.stepNumber,
    required this.title,
    required this.isCompleted,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                style: theme.textTheme.bodyMedium?.copyWith(
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