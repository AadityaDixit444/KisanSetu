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
  String _selectedMarket = 'Meerut Mandi';

  final List<String> _trackedCrops = const [
    'Wheat',
    'Rice (Basmati)',
    'Mustard',
    'Sugarcane',
    'Potato',
    'Tomato',
    'Onion',
    'Maize',
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

        final markets = _availableMarkets;

        if (markets.isNotEmpty && !markets.contains(_selectedMarket)) {
          _selectedMarket = markets.first;
        }
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = 'Failed to load market rates: $e';
        _isLoading = false;
      });
    }
  }

  double _parseDouble(dynamic value) {
    if (value == null) return 0.0;

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value.toString()) ?? 0.0;
  }

  String _formatPrice(dynamic rawPrice) {
    final value = _parseDouble(rawPrice);

    final formatted = value.toStringAsFixed(
      value % 1 == 0 ? 0 : 2,
    );

    final parts = formatted.split('.');
    final integerPart = parts[0];

    final withCommas = integerPart.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{2})+(?!\d))'),
      (match) => '${match[1]},',
    );

    if (parts.length == 1 || parts[1] == '00') {
      return '₹$withCommas/qtl';
    }

    return '₹$withCommas.${parts[1]}/qtl';
  }

  String _formatArrival(dynamic rawArrival) {
    if (rawArrival == null) {
      return 'N/A';
    }

    final value = _parseDouble(rawArrival);

    if (value % 1 == 0) {
      return '${value.toInt()} qtl';
    }

    return '${value.toStringAsFixed(1)} qtl';
  }

  String _formatPriceChange(dynamic rawChange) {
    if (rawChange == null) {
      return '';
    }

    final value = _parseDouble(rawChange);

    if (value > 0) {
      return '+${value.toStringAsFixed(1)}%';
    }

    return '${value.toStringAsFixed(1)}%';
  }

  String _formatDate(dynamic dateString) {
    if (dateString == null) {
      return '';
    }

    try {
      final parsed = DateTime.parse(dateString.toString());

      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];

      final day = parsed.day.toString().padLeft(2, '0');

      return '$day ${months[parsed.month - 1]} ${parsed.year}';
    } catch (_) {
      return dateString.toString();
    }
  }

  bool _matchesCrop(String recordCrop, String selectedCrop) {
    final record = recordCrop.toLowerCase().trim();
    final selected = selectedCrop.toLowerCase().trim();

    if (selected == 'rice (basmati)') {
      return record == 'rice (basmati)' ||
          record == 'basmati rice' ||
          record == 'rice';
    }

    return record == selected;
  }

  List<String> get _availableMarkets {
    final markets = <String>{};

    for (final item in _marketPrices) {
      final market = item['market']?.toString().trim();

      if (market != null && market.isNotEmpty) {
        markets.add(market);
      }
    }

    final result = markets.toList();

    result.sort((a, b) {
      if (a == 'Meerut Mandi') return -1;
      if (b == 'Meerut Mandi') return 1;
      return a.compareTo(b);
    });

    return result;
  }

  List<Map<String, dynamic>> _getFilteredPrices() {
    return _marketPrices.where((item) {
      final crop = item['crop']?.toString() ?? '';
      final market = item['market']?.toString() ?? '';

      return _matchesCrop(crop, _selectedCrop) &&
          market.toLowerCase().trim() ==
              _selectedMarket.toLowerCase().trim();
    }).toList();
  }

  Map<String, dynamic>? get _benchmarkItem {
    final filtered = _getFilteredPrices();

    if (filtered.isEmpty) {
      return null;
    }

    filtered.sort((a, b) {
      final aDate =
          DateTime.tryParse(a['recorded_at']?.toString() ?? '') ??
              DateTime.fromMillisecondsSinceEpoch(0);

      final bDate =
          DateTime.tryParse(b['recorded_at']?.toString() ?? '') ??
              DateTime.fromMillisecondsSinceEpoch(0);

      return bDate.compareTo(aDate);
    });

    return filtered.first;
  }

  String _getRecommendation(
    dynamic rawPriceChange,
    String demandLevel,
  ) {
    final priceChange = _parseDouble(rawPriceChange);
    final demand = demandLevel.toLowerCase();

    if (priceChange >= 3.0 && demand == 'high') {
      return 'HOLD';
    }

    if (priceChange < 0 || demand == 'low') {
      return 'SELL';
    }

    return 'HOLD';
  }

  Color _recommendationColor(String recommendation) {
    if (recommendation == 'SELL') {
      return AppColors.error;
    }

    return AppColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filteredPrices = _getFilteredPrices();
    final benchmark = _benchmarkItem;

    final recommendation = benchmark == null
        ? null
        : _getRecommendation(
            benchmark['price_change'],
            benchmark['demand_level']?.toString() ?? 'Medium',
          );

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back',
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Market Intelligence'),
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
            padding: const EdgeInsets.only(top: 16, bottom: 24),
            children: [
              // Crop selector
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Select Commodity',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 10),

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
                          if (!selected) return;

                          setState(() {
                            _selectedCrop = crop;
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 18),

              // Market selector
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Select Mandi',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: DropdownButtonFormField<String>(
                  initialValue: _availableMarkets.contains(_selectedMarket)
                      ? _selectedMarket
                      : null,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.location_on_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: theme.colorScheme.surface,
                  ),
                  hint: const Text('Select mandi'),
                  items: _availableMarkets.map((market) {
                    return DropdownMenuItem<String>(
                      value: market,
                      child: Text(market),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value == null) return;

                    setState(() {
                      _selectedMarket = value;
                    });
                  },
                ),
              ),

              const SizedBox(height: 18),

              // Main market overview
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              '$_selectedCrop Market Rate',
                              style:
                                  theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.onSurfaceVariant,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryContainer,
                              borderRadius: BorderRadius.circular(7),
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

                      const SizedBox(height: 12),

                      if (_isLoading)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      else if (benchmark != null) ...[
                        Text(
                          _formatPrice(benchmark['price']),
                          style:
                              theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),

                        const SizedBox(height: 6),

                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 18,
                              color: AppColors.onSurfaceVariant,
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                benchmark['market']
                                        ?.toString() ??
                                    _selectedMarket,
                                style:
                                    theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            if (benchmark['price_change'] != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.secondaryContainer,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  _formatPriceChange(
                                    benchmark['price_change'],
                                  ),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.secondary,
                                  ),
                                ),
                              ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        const Divider(),

                        const SizedBox(height: 12),

                        Row(
                          children: [
                            Expanded(
                              child: _InfoItem(
                                icon: Icons.inventory_2_outlined,
                                title: 'Arrivals',
                                value: _formatArrival(
                                  benchmark['arrival_volume'],
                                ),
                              ),
                            ),
                            Expanded(
                              child: _InfoItem(
                                icon: Icons.trending_up_rounded,
                                title: 'Demand',
                                value: benchmark['demand_level']
                                        ?.toString() ??
                                    'Medium',
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        Row(
                          children: [
                            Expanded(
                              child: _InfoItem(
                                icon: Icons.calendar_today_outlined,
                                title: 'Recorded',
                                value: _formatDate(
                                  benchmark['recorded_at'],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ] else ...[
                        Text(
                          'Rate unavailable',
                          style:
                              theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'No market record is available for $_selectedCrop at $_selectedMarket.',
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

              // Recommendation
              if (!_isLoading && recommendation != null)
                Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: recommendation == 'SELL'
                                ? AppColors.error.withValues(alpha: 0.12)
                                : AppColors.primaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            recommendation == 'SELL'
                                ? Icons.sell_outlined
                                : Icons.trending_up_rounded,
                            color: _recommendationColor(
                              recommendation,
                            ),
                            size: 28,
                          ),
                        ),

                        const SizedBox(width: 14),

                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Market Recommendation',
                                style: theme.textTheme.titleMedium
                                    ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Based on current price movement and buyer demand',
                                style:
                                    theme.textTheme.bodySmall?.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 8),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: recommendation == 'SELL'
                                ? AppColors.error.withValues(alpha: 0.12)
                                : AppColors.primaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            recommendation,
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: _recommendationColor(
                                recommendation,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 18),

              // Simulator
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const SimulatorScreen(),
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
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                'What-If Market Simulator',
                                style: theme.textTheme.titleMedium
                                    ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                'Compare Sell Now vs Hold scenarios with storage and transport costs.',
                                style:
                                    theme.textTheme.bodySmall?.copyWith(
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

              const SizedBox(height: 22),

              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Mandi Comparison',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
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
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16),
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
                            style:
                                theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'No data is currently available for $_selectedCrop at $_selectedMarket.',
                            textAlign: TextAlign.center,
                            style:
                                theme.textTheme.bodySmall?.copyWith(
                              color:
                                  AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else ...[
                ..._getMarketComparisonPrices().map((item) {
                  return _MarketRateCard(
                    item: item,
                    formatPrice: _formatPrice,
                    formatArrival: _formatArrival,
                    formatDate: _formatDate,
                    formatPriceChange: _formatPriceChange,
                  );
                }),
              ],

              const SizedBox(height: 12),

              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Data shown is based on the latest market records available in KisanSetu.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.outline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getMarketComparisonPrices() {
    final prices = _marketPrices.where((item) {
      final crop = item['crop']?.toString() ?? '';

      return _matchesCrop(crop, _selectedCrop);
    }).toList();

    prices.sort((a, b) {
      final aPrice = _parseDouble(a['price']);
      final bPrice = _parseDouble(b['price']);

      return bPrice.compareTo(aPrice);
    });

    return prices;
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoItem({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: AppColors.primary,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MarketRateCard extends StatelessWidget {
  final Map<String, dynamic> item;

  final String Function(dynamic) formatPrice;
  final String Function(dynamic) formatArrival;
  final String Function(dynamic) formatDate;
  final String Function(dynamic) formatPriceChange;

  const _MarketRateCard({
    required this.item,
    required this.formatPrice,
    required this.formatArrival,
    required this.formatDate,
    required this.formatPriceChange,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final market =
        item['market']?.toString() ?? 'Regional Mandi';

    final crop =
        item['crop']?.toString() ?? 'Unknown Crop';

    final demand =
        item['demand_level']?.toString() ?? 'Medium';

    final priceChange =
        item['price_change'];

    final date =
        formatDate(item['recorded_at']);

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 6,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
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
                  formatPrice(item['price']),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 4),

            Row(
              children: [
                Expanded(
                  child: Text(
                    crop,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ),
                if (priceChange != null)
                  Text(
                    formatPriceChange(priceChange),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: _changeColor(priceChange),
                    ),
                  ),
              ],
            ),

            const Divider(height: 20),

            Row(
              children: [
                Expanded(
                  child: _SmallStat(
                    title: 'Arrivals',
                    value: formatArrival(
                      item['arrival_volume'],
                    ),
                  ),
                ),
                Expanded(
                  child: _SmallStat(
                    title: 'Demand',
                    value: demand,
                  ),
                ),
                if (date.isNotEmpty)
                  Expanded(
                    child: _SmallStat(
                      title: 'Updated',
                      value: date,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _changeColor(dynamic rawChange) {
    final change = double.tryParse(
          rawChange?.toString() ?? '',
        ) ??
        0;

    if (change > 0) {
      return AppColors.primary;
    }

    if (change < 0) {
      return AppColors.error;
    }

    return AppColors.onSurfaceVariant;
  }
}

class _SmallStat extends StatelessWidget {
  final String title;
  final String value;

  const _SmallStat({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}