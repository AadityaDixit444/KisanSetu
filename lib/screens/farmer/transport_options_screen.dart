import 'package:flutter/material.dart';

import '../../services/logistics_service.dart';
import '../../theme/app_colors.dart';
import 'transport_tracking_screen.dart';

class TransportOptionsScreen extends StatefulWidget {
  final String transactionId;

  const TransportOptionsScreen({super.key, required this.transactionId});

  @override
  State<TransportOptionsScreen> createState() => _TransportOptionsScreenState();
}

class _TransportOptionsScreenState extends State<TransportOptionsScreen> {
  final LogisticsService _logisticsService = LogisticsService();

  int _selectedOption = 0;
  bool _isSubmitting = false;

  final List<_TransportOption> _options = const [
    _TransportOption(
      title: 'Tata Ace (Chota Hathi)',
      capacity: 'Up to 15 qtl',
      pickupTime: 'Today, 4:00 PM',
      estimatedCost: '₹2,500',
      isRecommended: false,
    ),
    _TransportOption(
      title: 'Eicher 14 Ft Truck',
      capacity: 'Up to 50 qtl',
      pickupTime: 'Tomorrow, 8:00 AM',
      estimatedCost: '₹6,200',
      isRecommended: true,
    ),
    _TransportOption(
      title: 'BharatBenz 10-Wheeler',
      capacity: 'Up to 120 qtl',
      pickupTime: 'Tomorrow, 10:00 AM',
      estimatedCost: '₹11,000',
      isRecommended: false,
    ),
  ];

  DateTime _parsePickupDate(String pickupTimeStr) {
    final now = DateTime.now();
    if (pickupTimeStr.toLowerCase().contains('tomorrow')) {
      return DateTime(
        now.year,
        now.month,
        now.day,
      ).add(const Duration(days: 1));
    }
    return DateTime(now.year, now.month, now.day);
  }

  Future<void> _onSelectTransport() async {
    if (_isSubmitting) return;

    final option = _options[_selectedOption];
    final parsedCost =
        double.tryParse(
          option.estimatedCost.replaceAll(RegExp(r'[^0-9.]'), ''),
        ) ??
        0.0;
    final pickupDate = _parsePickupDate(option.pickupTime);

    setState(() {
      _isSubmitting = true;
    });

    try {
      await _logisticsService.createLogistics(
        transactionId: widget.transactionId,
        vehicleType: option.title,
        transportCost: parsedCost,
        pickupLocation: 'Meerut',
        deliveryLocation: 'Karnal',
        pickupDate: pickupDate,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Transport arranged successfully'),
          duration: Duration(seconds: 2),
        ),
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TransportTrackingScreen(
            vehicleType: option.title,
            transportCost: parsedCost,
            pickupDate: pickupDate,
            pickupTime: option.pickupTime,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Transport Options')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          children: [
            // Route Summary Card
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              color: AppColors.primaryContainer.withValues(alpha: 0.5),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dispatch Route',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.place_outlined,
                          size: 18,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Meerut Farm  →  Karnal Mandi (118 km)',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.onPrimaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Available Vehicles',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            ...List.generate(_options.length, (index) {
              final option = _options[index];
              final isSelected = _selectedOption == index;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.outlineVariant,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: _isSubmitting
                      ? null
                      : () {
                          setState(() {
                            _selectedOption = index;
                          });
                        },
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Radio<int>(
                                  value: index,
                                  groupValue: _selectedOption,
                                  onChanged: _isSubmitting
                                      ? null
                                      : (value) {
                                          if (value != null) {
                                            setState(() {
                                              _selectedOption = value;
                                            });
                                          }
                                        },
                                ),
                                Text(
                                  option.title,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            if (option.isRecommended)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'Best Fit',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.onPrimary,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.only(left: 48),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _OptionDetailRow(
                                label: 'Capacity',
                                value: option.capacity,
                              ),
                              const SizedBox(height: 4),
                              _OptionDetailRow(
                                label: 'Est. Pickup',
                                value: option.pickupTime,
                              ),
                              const SizedBox(height: 4),
                              _OptionDetailRow(
                                label: 'Estimated Freight',
                                value: option.estimatedCost,
                                isHighlighted: true,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _onSelectTransport,
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.onPrimary,
                          ),
                        )
                      : const Text(
                          'Select Transport',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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

class _TransportOption {
  final String title;
  final String capacity;
  final String pickupTime;
  final String estimatedCost;
  final bool isRecommended;

  const _TransportOption({
    required this.title,
    required this.capacity,
    required this.pickupTime,
    required this.estimatedCost,
    required this.isRecommended,
  });
}

class _OptionDetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isHighlighted;

  const _OptionDetailRow({
    required this.label,
    required this.value,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium
              ?.copyWith(color: AppColors.onSurfaceVariant),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isHighlighted ? 15 : 13,
            fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w600,
            color: isHighlighted ? AppColors.primary : AppColors.onSurface,
          ),
        ),
      ],
    );
  }
}
