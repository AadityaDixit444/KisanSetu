import 'package:flutter/material.dart';
import '../../services/lot_service.dart';
import '../../theme/app_colors.dart';
import 'buyer_lot_details_screen.dart';

class BrowseLotsScreen extends StatefulWidget {
  const BrowseLotsScreen({super.key});

  @override
  State<BrowseLotsScreen> createState() => _BrowseLotsScreenState();
}

class _BrowseLotsScreenState extends State<BrowseLotsScreen> {
  final LotService _lotService = LotService();

  String _selectedCrop = 'All';
  bool _isLoading = true;
  String? _errorMessage;
  List<_BrowseLot> _allLots = [];

  @override
  void initState() {
    super.initState();
    _fetchLots();
  }

  Future<void> _fetchLots() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await _lotService.getActiveLots();

      final lots = data.map((item) {
        final rawQty = item['quantity'];
        final rawPrice = item['asking_price'];

        final qtyVal = rawQty is num ? rawQty.toDouble() : double.tryParse(rawQty?.toString() ?? '0') ?? 0.0;
        final priceVal = rawPrice is num ? rawPrice.toDouble() : double.tryParse(rawPrice?.toString() ?? '0') ?? 0.0;

        final formattedQty = qtyVal % 1 == 0 ? '${qtyVal.toInt()} qtl' : '$qtyVal qtl';
        final formattedPrice = priceVal % 1 == 0
            ? '₹${priceVal.toInt().toString().replaceAllMapped(RegExp(r'(\d+?)(?=(\d\d)+(\d)(?!\d))(\.\d+)?'), (m) => '${m[1]},')}/qtl'
            : '₹${priceVal.toStringAsFixed(2)}/qtl';

        return _BrowseLot(
          lotId: item['id']?.toString() ?? '',
          crop: item['crop']?.toString() ?? 'Produce',
          quantity: formattedQty,
          quality: item['quality']?.toString() ?? 'Standard',
          askingPrice: formattedPrice,
          location: item['location']?.toString() ?? 'Local Mandi',
          farmerName: 'Farmer',
        );
      }).toList();

      if (!mounted) return;

      setState(() {
        _allLots = lots;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Failed to load active lots. Please try again.';
        _isLoading = false;
      });
    }
  }

  List<_BrowseLot> get _filteredLots {
    if (_selectedCrop == 'All') return _allLots;
    return _allLots.where((lot) => lot.crop.toLowerCase() == _selectedCrop.toLowerCase()).toList();
  }

  void _navigateToLotDetails(_BrowseLot lot) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BuyerLotDetailsScreen(
          lotId: lot.lotId,
          crop: lot.crop,
          quantity: lot.quantity,
          quality: lot.quality,
          askingPrice: lot.askingPrice,
          location: lot.location,
          distance: '',
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
        child: RefreshIndicator(
          onRefresh: _fetchLots,
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 16),
            children: [
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
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: ['All', 'Wheat', 'Rice', 'Maize', 'Mustard'].map((crop) {
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
                    if (!_isLoading && _errorMessage == null)
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
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 48),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
                  child: Column(
                    children: [
                      Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: _fetchLots,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              else if (_filteredLots.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
                  child: Center(
                    child: Text(
                      'No active lots available',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ),
                )
              else
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
                                      lot.location,
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
      ),
    );
  }
}

class _BrowseLot {
  final String lotId;
  final String crop;
  final String quantity;
  final String quality;
  final String askingPrice;
  final String location;
  final String farmerName;

  _BrowseLot({
    required this.lotId,
    required this.crop,
    required this.quantity,
    required this.quality,
    required this.askingPrice,
    required this.location,
    required this.farmerName,
  });
}