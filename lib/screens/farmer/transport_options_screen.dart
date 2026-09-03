import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import 'transport_tracking_screen.dart';

class TransportOptionsScreen extends StatelessWidget {
  const TransportOptionsScreen({super.key});

  static final List<_TransportOption> _transportOptions = [
    _TransportOption(
      vehicle: '14-Wheeler Truck',
      capacity: '150 qtl',
      estimatedCost: '₹11,000',
      pickupTime: '04 Sep, 8:00 AM',
      status: 'Recommended',
      isRecommended: true,
      statusColor: AppColors.primary,
      statusBgColor: AppColors.primaryContainer,
    ),
    _TransportOption(
      vehicle: '10-Wheeler Truck',
      capacity: '100 qtl',
      estimatedCost: '₹9,500',
      pickupTime: '04 Sep, 10:30 AM',
      status: 'Lowest Cost',
      isRecommended: false,
      statusColor: AppColors.secondary,
      statusBgColor: AppColors.secondaryContainer,
    ),
    _TransportOption(
      vehicle: '12-Wheeler Truck',
      capacity: '120 qtl',
      estimatedCost: '₹10,200',
      pickupTime: '04 Sep, 9:00 AM',
      status: 'Fast Pickup',
      isRecommended: false,
      statusColor: AppColors.tertiary,
      statusBgColor: AppColors.tertiaryContainer,
    ),
  ];

  void _onSelectTransport(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TransportTrackingScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transport Options'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          children: [
            // Shipment Summary Card
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
                          'Shipment Overview',
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
                            'Active Shipment',
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
                            fontSize: 18,
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
                          _SummaryItem(label: 'Route', value: 'Meerut → Karnal'),
                          _SummaryDivider(),
                          _SummaryItem(label: 'Distance', value: '118 km'),
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
                'Available Vehicles',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // Vehicle Option Cards
            ..._transportOptions.map((option) {
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: option.isRecommended
                        ? AppColors.primary
                        : AppColors.outlineVariant,
                    width: option.isRecommended ? 1.8 : 0.8,
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
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: option.isRecommended
                                ? AppColors.primaryContainer
                                : AppColors.secondaryContainer,
                            child: Icon(
                              Icons.local_shipping_rounded,
                              color: option.isRecommended
                                  ? AppColors.primary
                                  : AppColors.secondary,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  option.vehicle,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Capacity: ${option.capacity}',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: option.statusBgColor,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              option.status,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: option.statusColor,
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
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Estimated Cost',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontSize: 11,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    option.estimatedCost,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: option.isRecommended
                                          ? AppColors.primary
                                          : AppColors.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              height: 32,
                              width: 1,
                              color: AppColors.outlineVariant,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Pickup Schedule',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontSize: 11,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    option.pickupTime,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 42,
                        child: option.isRecommended
                            ? ElevatedButton(
                                onPressed: () => _onSelectTransport(context),
                                child: const Text('Select Transport'),
                              )
                            : OutlinedButton(
                                onPressed: () => _onSelectTransport(context),
                                child: const Text('Select Transport'),
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

class _TransportOption {
  final String vehicle;
  final String capacity;
  final String estimatedCost;
  final String pickupTime;
  final String status;
  final bool isRecommended;
  final Color statusColor;
  final Color statusBgColor;

  _TransportOption({
    required this.vehicle,
    required this.capacity,
    required this.estimatedCost,
    required this.pickupTime,
    required this.status,
    required this.isRecommended,
    required this.statusColor,
    required this.statusBgColor,
  });
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryItem({required this.label, required this.value});

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
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryDivider extends StatelessWidget {
  const _SummaryDivider();

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