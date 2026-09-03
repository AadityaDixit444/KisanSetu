import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import 'buyer_lot_details_screen.dart';

class BrowseLotsScreen extends StatefulWidget {
  const BrowseLotsScreen({super.key});

  @override
  State<BrowseLotsScreen> createState() => _BrowseLotsScreenState();
}

class _BrowseLotsScreenState extends State<BrowseLotsScreen> {
  String _selectedCrop = 'All';

  static final List<_BrowseLot> _allLots = [
    _BrowseLot(
      crop: 'Wheat',
      quantity: '100 qtl',
      quality: 'Good Quality',
      askingPrice: '₹2,450/qtl',
      location: 'Meerut',
      distance: '12 km away',
      farmerName: 'Ramesh Singh',
    ),
    _BrowseLot(
      crop: 'Wheat',
      quantity: '150 qtl',
      quality: 'Premium Quality',
      askingPrice: '₹2,480/qtl',
      location: 'Muzaffarnagar',
      distance: '52 km away',
      farmerName: 'Suresh Kumar',
    ),
    _BrowseLot(
      crop: 'Wheat',
      quantity: '80 qtl',
      quality: 'Good Quality',
      askingPrice: '₹2,440/qtl',
      location: 'Hapur',
      distance: '38 km away',
      farmerName: 'Dharmendra Yadav',
    ),
    _BrowseLot(
      crop: 'Rice',
      quantity: '120 qtl',
      quality: 'Basmati Grade A',
      askingPrice: '₹3,250/qtl',
      location: 'Karnal',
      distance: '95 km away',
      farmerName: 'Harpreet Singh',
    ),
    _BrowseLot(
      crop: 'Mustard',
      quantity: '60 qtl',
      quality: 'Standard Grade',
      askingPrice: '₹5,150/qtl',
      location: 'Alwar',
      distance: '140 km away',
      farmerName: 'Ramphal Gurjar',
    ),
  ];

  List<_BrowseLot> get _filteredLots {
    if (_selectedCrop == 'All') return _allLots;
    return _allLots.where((lot) => lot.crop == _selectedCrop).toList();
  }

  void _navigateToLotDetails(_BrowseLot lot) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BuyerLotDetailsScreen(
          crop: lot.crop,
          quantity: lot.quantity,
          quality: lot.quality,
          askingPrice: lot.askingPrice,
          location: lot.location,
          distance: lot.distance,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Browse Lots'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          children: [
            // Search and Filter Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search produce or mandi location...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Commodity Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: ['All', 'Wheat', 'Rice', 'Mustard'].map((crop) {
                  final isSelected = _selectedCrop == crop;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      selected: isSelected,
                      label: Text(crop),
                      onSelected: (selected) {
                        setState(() {
                          _selectedCrop = crop;
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),

            // Results Count Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Available Lots',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${_filteredLots.length} listings',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Lot Cards
            ..._filteredLots.map((lot) {
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    lot.farmerName,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontSize: 12,
                                      color: AppColors.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Text(
                            lot.askingPrice,
                            style: const TextStyle(
                              fontSize: 16,
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
                                  'Quality',
                                  style: theme.textTheme.bodyMedium?.copyWith(fontSize: 11),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  lot.quality,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Location',
                                  style: theme.textTheme.bodyMedium?.copyWith(fontSize: 11),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${lot.location} (${lot.distance})',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.onSurfaceVariant,
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
                        child: ElevatedButton(
                          onPressed: () => _navigateToLotDetails(lot),
                          child: const Text('Make Offer / View Lot'),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _BrowseLot {
  final String crop;
  final String quantity;
  final String quality;
  final String askingPrice;
  final String location;
  final String distance;
  final String farmerName;

  _BrowseLot({
    required this.crop,
    required this.quantity,
    required this.quality,
    required this.askingPrice,
    required this.location,
    required this.distance,
    required this.farmerName,
  });
}