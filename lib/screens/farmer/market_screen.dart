import 'package:flutter/material.dart';
import '../../services/market_price_service.dart';
import '../../theme/app_colors.dart';
import 'simulator_screen.dart';

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  final MarketPriceService _marketPriceService = MarketPriceService();

  bool _isLoading = true;
  String? _errorMessage;
  List<Map<String, dynamic>> _marketPrices = [];
  String _selectedCrop = 'Wheat';

  final List<String> _trackedCrops = const [
    'Wheat',
    'Basmati Rice',
    'Mustard',
    'Chana (Gram)',
    'Maize',
    'Soybean',
  ];

  @override
  void initState() {
    super.initState();
    _fetchMarketRates();
  }

  Future<void> _fetchMarketRates() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final rates = await _marketPriceService.getMarketPrices();
      if (!mounted) return;
      setState(() {
        _marketPrices = rates;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Failed to load market rates: $e';
        _isLoading = false;
      });
    }
  }

  double _parseDouble(dynamic val) {
    if (val == null) return 0.0;
    if (val is num) return val.toDouble();
    return double.tryParse(val.toString()) ?? 0.0;
  }

  String _formatPrice(dynamic rawPrice) {
    final val = _parseDouble(rawPrice);
    if (val % 1 == 0) {
      return '₹${val.toInt().toString().replaceAllMapped(RegExp(r'(\d+?)(?=(\d\d)+(\d)(?!\d))(\.\d+)?'), (m) => '${m[1]},')}/qtl';
    }
    return '₹${val.toStringAsFixed(2)}/qtl';
  }

  String _formatArrival(dynamic rawArrival) {
    if (rawArrival == null) return 'N/A';
    final val = _parseDouble(rawArrival);
    return val % 1 == 0 ? '${val.toInt()} qtl' : '$val qtl';
  }

  String _formatDate(dynamic dateString) {
    if (dateString == null) return '';
    try {
      final parsed = DateTime.parse(dateString.toString());
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      final day = parsed.day.toString().padLeft(2, '0');
      return '$day ${months[parsed.month - 1]} ${parsed.year}';
    } catch (_) {
      return dateString.toString();
    }
  }

  bool _matchesCrop(String recordCrop, String selectedCrop) {
    final normalizedRecord = recordCrop.toLowerCase().trim();
    final normalizedSelected = selectedCrop.toLowerCase().trim();

    if (normalizedSelected == 'basmati rice') {
      return normalizedRecord == 'rice (basmati)' ||
          normalizedRecord == 'basmati rice' ||
          normalizedRecord == 'rice';
    }

    if (normalizedSelected == 'chana (gram)') {
      return normalizedRecord == 'chana (gram)' ||
          normalizedRecord == 'chana' ||
          normalizedRecord == 'gram';
    }

    return normalizedRecord == normalizedSelected;
  }

  List<Map<String, dynamic>> _getFilteredPrices() {
    return _marketPrices.where((item) {
      final crop = item['crop']?.toString() ?? '';
      return _matchesCrop(crop, _selectedCrop);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filteredPrices = _getFilteredPrices();
    final benchmarkItem = filteredPrices.isNotEmpty ? filteredPrices.first : null;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back',
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Live Mandi Rates'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
            onPressed: _fetchMarketRates,
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchMarketRates,
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 16),
            children: [
              // Commodity Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: _trackedCrops.map((crop) {
                    final isSelected = _selectedCrop == crop;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(crop),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _selectedCrop = crop;
                            });
                          }
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 16),

              // Benchmark Overview Banner
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              '$_selectedCrop Regional Benchmark',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: AppColors.onSurfaceVariant,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primaryContainer,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'Live Data',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      if (_isLoading)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      else if (benchmarkItem != null) ...[
                        Text(
                          _formatPrice(benchmarkItem['price']),
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Text(
                              'Market: ${benchmarkItem['market'] ?? 'Regional Mandi'}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (benchmarkItem['price_change'] != null) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.secondaryContainer,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  benchmarkItem['price_change'].toString(),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.secondary,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ] else ...[
                        Text(
                          'Rate unavailable',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'No benchmark price recorded for $_selectedCrop yet.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Price Simulator Callout Card
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SimulatorScreen(),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.secondaryContainer,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.calculate_outlined,
                            color: AppColors.secondary,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Simulate Hold vs. Sell Return',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Calculate net gains factoring in storage fees, weight shrinkage & freight costs.',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 16,
                          color: AppColors.outline,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Recorded Mandi Rates',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
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
                          onPressed: _fetchMarketRates,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              else if (filteredPrices.isEmpty)
                Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: Column(
                        children: [
                          const Icon(
                            Icons.insights_rounded,
                            size: 48,
                            color: AppColors.outline,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No recorded rates found',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Market rates for $_selectedCrop will appear once synced with Mandi records.',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                ...filteredPrices.map((item) {
                  final market = item['market']?.toString() ?? 'Regional Mandi';
                  final crop = item['crop']?.toString() ?? _selectedCrop;
                  final price = _formatPrice(item['price']);
                  final arrival = _formatArrival(item['arrival_volume']);
                  final demand = item['demand_level']?.toString() ?? 'Moderate';
                  final priceChange = item['price_change']?.toString();
                  final recordedDate = _formatDate(item['recorded_at']);

                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  market,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                price,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                crop,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                              if (recordedDate.isNotEmpty)
                                Text(
                                  recordedDate,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: AppColors.outline,
                                  ),
                                ),
                            ],
                          ),
                          const Divider(height: 20, color: AppColors.outlineVariant),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Arrivals: $arrival',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                              Text(
                                'Demand: $demand',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                              if (priceChange != null && priceChange.isNotEmpty)
                                Text(
                                  priceChange,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.secondary,
                                  ),
                                ),
                            ],
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
      ),
    );
  }
}