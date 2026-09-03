import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class AggregationScreen extends StatefulWidget {
  const AggregationScreen({super.key});

  @override
  State<AggregationScreen> createState() => _AggregationScreenState();
}

class _AggregationScreenState extends State<AggregationScreen> {
  static const int _userQuantity = 100;

  final List<_FarmerItem> _nearbyFarmers = [
    _FarmerItem(
      id: '1',
      name: 'Rajesh Kumar',
      quantity: 35,
      distance: '2.4 km away',
      quality: 'Good Quality',
      isSelected: true,
    ),
    _FarmerItem(
      id: '2',
      name: 'Sunil Singh',
      quantity: 25,
      distance: '3.1 km away',
      quality: 'Good Quality',
      isSelected: true,
    ),
    _FarmerItem(
      id: '3',
      name: 'Amit Sharma',
      quantity: 40,
      distance: '4.2 km away',
      quality: 'Premium Quality',
      isSelected: false,
    ),
    _FarmerItem(
      id: '4',
      name: 'Pankaj Verma',
      quantity: 30,
      distance: '5.0 km away',
      quality: 'Good Quality',
      isSelected: false,
    ),
  ];

  int get _selectedQuantity {
    return _nearbyFarmers
        .where((farmer) => farmer.isSelected)
        .fold(0, (sum, farmer) => sum + farmer.quantity);
  }

  int get _combinedLot => _userQuantity + _selectedQuantity;

  void _onCreateLotPressed() {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Aggregated lot created successfully'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Aggregation'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          children: [
            // Header Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 18,
                              color: AppColors.outline,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Meerut',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
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
                            'Crop Pooling',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
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
                    const SizedBox(height: 8),
                    Text(
                      'Combine produce with verified farmers nearby to create larger trade lots, attract tier-1 bulk buyers, and negotiate stronger mandi rates.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Nearby Farmers Section
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Nearby Farmers',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${_nearbyFarmers.where((f) => f.isSelected).length} selected',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            ..._nearbyFarmers.map((farmer) {
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: farmer.isSelected
                        ? AppColors.primary
                        : AppColors.outlineVariant,
                    width: farmer.isSelected ? 1.5 : 0.8,
                  ),
                ),
                child: CheckboxListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  activeColor: AppColors.primary,
                  value: farmer.isSelected,
                  onChanged: (val) {
                    setState(() {
                      farmer.isSelected = val ?? false;
                    });
                  },
                  secondary: CircleAvatar(
                    backgroundColor: farmer.isSelected
                        ? AppColors.primaryContainer
                        : AppColors.secondaryContainer,
                    child: Icon(
                      Icons.person_outline_rounded,
                      color: farmer.isSelected
                          ? AppColors.primary
                          : AppColors.secondary,
                    ),
                  ),
                  title: Text(
                    farmer.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              '${farmer.quantity} qtl',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                                fontSize: 13,
                              ),
                            ),
                            const Text(' • '),
                            Text(
                              farmer.distance,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: farmer.quality.contains('Premium')
                                ? AppColors.tertiaryContainer
                                : AppColors.background,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            farmer.quality,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: farmer.quality.contains('Premium')
                                  ? AppColors.onTertiaryContainer
                                  : AppColors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),

            const SizedBox(height: 10),

            // Combined Lot Summary Card
            Card(
              color: AppColors.background,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _LotMetricRow(
                      label: 'Selected Quantity',
                      value: '$_selectedQuantity qtl',
                    ),
                    const SizedBox(height: 8),
                    const _LotMetricRow(
                      label: 'Your Quantity',
                      value: '$_userQuantity qtl',
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Divider(color: AppColors.outlineVariant),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Combined Lot',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '$_combinedLot qtl',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Bulk Selling Advantage Card
            Card(
              color: AppColors.secondaryContainer.withValues(alpha: 0.45),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.secondaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.groups_rounded,
                            color: AppColors.secondary,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Bulk Selling Advantage',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.onSecondaryContainer,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Larger lots can attract bulk buyers and improve bargaining power.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.onSecondaryContainer,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const _AdvantagePoint(
                      icon: Icons.storefront_rounded,
                      text: 'Potential buyer reach: 6 active buyers',
                    ),
                    const SizedBox(height: 8),
                    const _AdvantagePoint(
                      icon: Icons.trending_up_rounded,
                      text: 'Estimated bargaining advantage: +2% to +5%',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Primary Call to Action
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.hub_rounded),
                label: const Text('Create Aggregated Lot'),
                onPressed: _onCreateLotPressed,
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _FarmerItem {
  final String id;
  final String name;
  final int quantity;
  final String distance;
  final String quality;
  bool isSelected;

  _FarmerItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.distance,
    required this.quality,
    required this.isSelected,
  });
}

class _LotMetricRow extends StatelessWidget {
  final String label;
  final String value;

  const _LotMetricRow({required this.label, required this.value});

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
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
          ),
        ),
      ],
    );
  }
}

class _AdvantagePoint extends StatelessWidget {
  final IconData icon;
  final String text;

  const _AdvantagePoint({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.secondary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.onSecondaryContainer,
            ),
          ),
        ),
      ],
    );
  }
}