import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import 'create_lot_screen.dart';
import 'simulator_screen.dart';

class LotsScreen extends StatelessWidget {
  const LotsScreen({super.key});

  static final List<_FarmerLot> _dummyLots = [
    _FarmerLot(
      id: 'KS-1001',
      crop: 'Wheat',
      quantity: '120 qtl',
      quality: 'Grade A',
      askingPrice: '₹2,480/qtl',
      status: 'Active',
      offersCount: 3,
    ),
    _FarmerLot(
      id: 'KS-1002',
      crop: 'Rice (Basmati)',
      quantity: '60 qtl',
      quality: 'Premium',
      askingPrice: '₹3,200/qtl',
      status: 'Active',
      offersCount: 1,
    ),
    _FarmerLot(
      id: 'KS-1003',
      crop: 'Mustard',
      quantity: '45 qtl',
      quality: 'Standard',
      askingPrice: '₹5,100/qtl',
      status: 'Sold',
      offersCount: 4,
    ),
  ];

  void _navigateToCreateLot(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateLotScreen(),
      ),
    );
  }

  void _navigateToSimulator(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SimulatorScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Lots'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToCreateLot(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Create Lot'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Listed Produce',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${_dummyLots.length} lots listed',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            ..._dummyLots.map((lot) {
              final isActive = lot.status == 'Active';
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(
                    color: AppColors.outlineVariant,
                    width: 0.8,
                  ),
                ),
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
                              CircleAvatar(
                                radius: 18,
                                backgroundColor: AppColors.primaryContainer,
                                child: const Icon(
                                  Icons.eco_rounded,
                                  color: AppColors.primary,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    lot.crop,
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Lot #${lot.id}',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontSize: 11,
                                      color: AppColors.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? AppColors.primaryContainer
                                  : AppColors.background,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              lot.status,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: isActive
                                    ? AppColors.onPrimaryContainer
                                    : AppColors.outline,
                              ),
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Quantity',
                                  style: theme.textTheme.bodyMedium?.copyWith(fontSize: 11),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  lot.quantity,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Asking Price',
                                  style: theme.textTheme.bodyMedium?.copyWith(fontSize: 11),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  lot.askingPrice,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Buyer Offers',
                                  style: theme.textTheme.bodyMedium?.copyWith(fontSize: 11),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${lot.offersCount} Offers',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.secondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 38,
                        child: OutlinedButton.icon(
                          onPressed: () => _navigateToSimulator(context),
                          icon: const Icon(Icons.tune_rounded, size: 18),
                          label: const Text('Test What-If / Simulate Return'),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _FarmerLot {
  final String id;
  final String crop;
  final String quantity;
  final String quality;
  final String askingPrice;
  final String status;
  final int offersCount;

  _FarmerLot({
    required this.id,
    required this.crop,
    required this.quantity,
    required this.quality,
    required this.askingPrice,
    required this.status,
    required this.offersCount,
  });
}