import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import 'transaction_screen.dart';

class TransportTrackingScreen extends StatelessWidget {
  const TransportTrackingScreen({super.key});

  void _onViewDeliveryDetails(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TransactionScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transport Tracking'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          children: [
            // Status Card
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
                        Icons.local_shipping_rounded,
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
                            'Transport Arranged',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.onPrimaryContainer,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Vehicle assigned and scheduled for pickup.',
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

            // Deal Summary Card
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
                          'Deal Summary',
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
                            'KS-LOT-1001',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const _SummaryRow(
                      icon: Icons.storefront_rounded,
                      label: 'Buyer',
                      value: 'Kisan Agro Flour Mills',
                    ),
                    const SizedBox(height: 8),
                    const _SummaryRow(
                      icon: Icons.eco_rounded,
                      label: 'Crop & Quantity',
                      value: 'Wheat • 100 qtl',
                    ),
                    const SizedBox(height: 8),
                    const _SummaryRow(
                      icon: Icons.route_rounded,
                      label: 'Route',
                      value: 'Meerut → Karnal (118 km)',
                    ),
                  ],
                ),
              ),
            ),

            // Transport Details Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Transport Details',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const _DetailRow(
                      icon: Icons.rv_hookup_rounded,
                      label: 'Vehicle',
                      value: '14-Wheeler Truck',
                    ),
                    const SizedBox(height: 10),
                    const _DetailRow(
                      icon: Icons.person_pin_rounded,
                      label: 'Driver / Transporter',
                      value: 'Rajesh Transport Services',
                    ),
                    const SizedBox(height: 10),
                    const _DetailRow(
                      icon: Icons.currency_rupee_rounded,
                      label: 'Estimated Cost',
                      value: '₹11,000',
                      valueColor: AppColors.primary,
                    ),
                    const SizedBox(height: 10),
                    const _DetailRow(
                      icon: Icons.schedule_rounded,
                      label: 'Expected Pickup',
                      value: '04 Sep 2026, 8:00 AM',
                    ),
                  ],
                ),
              ),
            ),

            // Delivery Timeline Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Delivery Timeline',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const _TimelineStepTile(
                      stepNumber: 1,
                      title: 'Deal Confirmed',
                      isCompleted: true,
                      isLast: false,
                    ),
                    const _TimelineStepTile(
                      stepNumber: 2,
                      title: 'Transport Arranged',
                      isCompleted: true,
                      isLast: false,
                    ),
                    const _TimelineStepTile(
                      stepNumber: 3,
                      title: 'Pickup Completed',
                      isCompleted: false,
                      isLast: false,
                    ),
                    const _TimelineStepTile(
                      stepNumber: 4,
                      title: 'In Transit',
                      isCompleted: false,
                      isLast: false,
                    ),
                    const _TimelineStepTile(
                      stepNumber: 5,
                      title: 'Delivered',
                      isCompleted: false,
                      isLast: true,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 8),

            // View Delivery Details Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: OutlinedButton.icon(
                onPressed: () => _onViewDeliveryDetails(context),
                icon: const Icon(Icons.receipt_long_rounded),
                label: const Text('View Delivery Details'),
              ),
            ),
            const SizedBox(height: 20),
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

  const _SummaryRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.outline),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
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
            color: valueColor ?? AppColors.onSurface,
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