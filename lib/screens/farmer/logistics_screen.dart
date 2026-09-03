import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import 'transport_options_screen.dart';

class LogisticsScreen extends StatelessWidget {
  const LogisticsScreen({super.key});

  void _onArrangeTransport(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TransportOptionsScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Logistics'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          children: [
            // Deal Confirmed Status Card
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
                        Icons.check_circle_rounded,
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
                            'Deal Confirmed',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.onPrimaryContainer,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Kisan Agro Flour Mills • Wheat • 100 qtl',
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

            // Route Card with Vertical Indicator
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
                          'Transit Route',
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
                            'Distance: 118 km',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          children: [
                            const Icon(
                              Icons.radio_button_checked_rounded,
                              size: 18,
                              color: AppColors.primary,
                            ),
                            Container(
                              width: 2,
                              height: 38,
                              color: AppColors.outlineVariant,
                            ),
                            const Icon(
                              Icons.location_on_rounded,
                              size: 20,
                              color: AppColors.error,
                            ),
                          ],
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Pickup Location',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontSize: 11,
                                  color: AppColors.outline,
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'Meerut, Uttar Pradesh',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 18),
                              Text(
                                'Delivery Destination',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontSize: 11,
                                  color: AppColors.outline,
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'Karnal, Haryana',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Shipment Details Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Shipment Details',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const _ShipmentDetailRow(
                      icon: Icons.eco_rounded,
                      label: 'Crop',
                      value: 'Wheat',
                    ),
                    const SizedBox(height: 10),
                    const _ShipmentDetailRow(
                      icon: Icons.scale_rounded,
                      label: 'Quantity',
                      value: '100 qtl',
                    ),
                    const SizedBox(height: 10),
                    const _ShipmentDetailRow(
                      icon: Icons.verified_outlined,
                      label: 'Quality Grade',
                      value: 'Good',
                    ),
                    const SizedBox(height: 10),
                    const _ShipmentDetailRow(
                      icon: Icons.local_shipping_outlined,
                      label: 'Estimated Logistics Cost',
                      value: '₹11,000',
                      valueColor: AppColors.primary,
                    ),
                    const SizedBox(height: 10),
                    const _ShipmentDetailRow(
                      icon: Icons.event_available_rounded,
                      label: 'Expected Pickup',
                      value: '04 Sep 2026',
                    ),
                  ],
                ),
              ),
            ),

            // Transport Arrangement Section
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
                          'Transport Arrangement',
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
                            'Not Arranged',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.warning,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Arrange a suitable vehicle for pickup and delivery.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.commute_rounded),
                        label: const Text('Arrange Transport'),
                        onPressed: () => _onArrangeTransport(context),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Delivery Progress Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Delivery Progress',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const _ProgressStepTile(
                      stepNumber: 1,
                      title: 'Deal Confirmed',
                      isCompleted: true,
                      isLast: false,
                    ),
                    const _ProgressStepTile(
                      stepNumber: 2,
                      title: 'Transport Arranged',
                      isCompleted: false,
                      isLast: false,
                    ),
                    const _ProgressStepTile(
                      stepNumber: 3,
                      title: 'Pickup Completed',
                      isCompleted: false,
                      isLast: false,
                    ),
                    const _ProgressStepTile(
                      stepNumber: 4,
                      title: 'Delivery Completed',
                      isCompleted: false,
                      isLast: true,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _ShipmentDetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _ShipmentDetailRow({
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

class _ProgressStepTile extends StatelessWidget {
  final int stepNumber;
  final String title;
  final bool isCompleted;
  final bool isLast;

  const _ProgressStepTile({
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