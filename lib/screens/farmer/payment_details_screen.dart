import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class PaymentDetailsScreen extends StatelessWidget {
  const PaymentDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Details'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          children: [
            // Status Card
            Card(
              color: AppColors.warning.withValues(alpha: 0.12),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.warning,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.hourglass_top_rounded,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Payment Pending',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.warning,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Expected within 24 hours after delivery verification',
                            style: theme.textTheme.bodyMedium?.copyWith(
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

            // Settlement Breakdown Card
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
                          'Payment Breakdown',
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
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.outlineVariant),
                          ),
                          child: const Text(
                            'KS-TXN-1001',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const _PaymentItemRow(
                      label: 'Buyer',
                      value: 'Kisan Agro Flour Mills',
                    ),
                    const SizedBox(height: 8),
                    const _PaymentItemRow(
                      label: 'Produce',
                      value: 'Wheat • 100 qtl',
                    ),
                    const SizedBox(height: 8),
                    const _PaymentItemRow(
                      label: 'Agreed Price',
                      value: '₹2,470/qtl',
                    ),
                    const SizedBox(height: 8),
                    const _PaymentItemRow(
                      label: 'Gross Sale Value',
                      value: '₹2,47,000',
                    ),
                    const SizedBox(height: 8),
                    const _PaymentItemRow(
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
                            'Final Payable Amount',
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
                    const SizedBox(height: 14),
                    const _PaymentItemRow(
                      label: 'Payment Method',
                      value: 'Direct Bank Transfer',
                    ),
                  ],
                ),
              ),
            ),

            // Payment Timeline Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Payment Timeline',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const _TimelineTile(
                      stepNumber: 1,
                      title: 'Delivery Verified',
                      isCompleted: true,
                      isLast: false,
                    ),
                    const _TimelineTile(
                      stepNumber: 2,
                      title: 'Payment Initiated',
                      isCompleted: false,
                      isLast: false,
                    ),
                    const _TimelineTile(
                      stepNumber: 3,
                      title: 'Payment Received',
                      isCompleted: false,
                      isLast: true,
                    ),
                  ],
                ),
              ),
            ),

            // Note Card
            Card(
              color: AppColors.primaryContainer.withValues(alpha: 0.4),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      size: 20,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Payment status will automatically update once the buyer completes bank settlement. The amount will be credited directly to your registered bank account.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.onPrimaryContainer,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
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

class _PaymentItemRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isDeduction;

  const _PaymentItemRow({
    required this.label,
    required this.value,
    this.isDeduction = false,
  });

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

class _TimelineTile extends StatelessWidget {
  final int stepNumber;
  final String title;
  final bool isCompleted;
  final bool isLast;

  const _TimelineTile({
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