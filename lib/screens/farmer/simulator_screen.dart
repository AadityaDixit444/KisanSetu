import 'package:flutter/material.dart';
import '../../services/market_price_service.dart';
import '../../theme/app_colors.dart';

class SimulatorScreen extends StatefulWidget {
  const SimulatorScreen({super.key});

  @override
  State<SimulatorScreen> createState() => _SimulatorScreenState();
}

class _SimulatorScreenState extends State<SimulatorScreen> {
  final MarketPriceService _marketPriceService = MarketPriceService();
  final TextEditingController _quantityController =
      TextEditingController(text: '100');

  bool _isLoading = true;
  String? _errorMessage;

  final String _crop = 'Wheat';
  double _stockQuantity = 100.0;

  double? _currentMandiPrice;
  double _priceChangePercent = 0.0;
  String _demandLevel = 'Moderate';
  String _marketName = 'Meerut Mandi';

  @override
  void initState() {
    super.initState();
    _fetchMarketBaseline();
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _fetchMarketBaseline() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final records = await _marketPriceService.getMarketPrices();
      if (!mounted) return;

      final wheatRecord = records.firstWhere(
        (item) {
          final crop = item['crop']?.toString().toLowerCase().trim() ?? '';
          final market = item['market']?.toString().toLowerCase().trim() ?? '';
          return crop == 'wheat' && market.contains('meerut');
        },
        orElse: () => records.firstWhere(
          (item) =>
              (item['crop']?.toString().toLowerCase().trim() ?? '') == 'wheat',
          orElse: () => <String, dynamic>{},
        ),
      );

      setState(() {
        if (wheatRecord.isNotEmpty && wheatRecord['price'] != null) {
          _currentMandiPrice = _parseDouble(wheatRecord['price']);
          _priceChangePercent = _parsePercent(wheatRecord['price_change']);
          _demandLevel = wheatRecord['demand_level']?.toString() ?? 'Moderate';
          _marketName = wheatRecord['market']?.toString() ?? 'Meerut Mandi';
        } else {
          _currentMandiPrice = null;
        }
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

  double _parseDouble(dynamic val, {double fallback = 0.0}) {
    if (val == null) return fallback;
    if (val is num) return val.toDouble();
    return double.tryParse(val.toString().replaceAll(RegExp(r'[^0-9.-]'), '')) ??
        fallback;
  }

  double _parsePercent(dynamic val) {
    if (val == null) return 0.0;
    final cleaned = val.toString().replaceAll('%', '').trim();
    return double.tryParse(cleaned) ?? 0.0;
  }

  String _formatCurrency(double amount) {
    return '₹${amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d+?)(?=(\d\d)+(\d)(?!\d))(\.\d+)?'),
          (match) => '${match[1]},',
        )}';
  }

  String _formatPrice(double price) {
    if (price % 1 == 0) {
      return '₹${price.toInt().toString().replaceAllMapped(RegExp(r'(\d+?)(?=(\d\d)+(\d)(?!\d))(\.\d+)?'), (m) => '${m[1]},')}/qtl';
    }
    return '₹${price.toStringAsFixed(2)}/qtl';
  }

  (String action, String reason, Color color, Color containerColor)
      _calculateRecommendation(double priceChange, String demandLevel) {
    final normalizedDemand = demandLevel.trim().toLowerCase();

    if (priceChange >= 3.0 && normalizedDemand == 'high') {
      return (
        'HOLD',
        'Price is rising and demand is high. Consider holding the produce.',
        AppColors.primary,
        AppColors.primaryContainer,
      );
    } else if (priceChange < 0 || normalizedDemand == 'low') {
      return (
        'SELL',
        'Market conditions are weakening. Consider selling the produce.',
        AppColors.error,
        AppColors.error.withValues(alpha: 0.15),
      );
    } else {
      return (
        'HOLD',
        'Market conditions are relatively stable. Continue monitoring the market.',
        AppColors.secondary,
        AppColors.secondaryContainer,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentPrice = _currentMandiPrice;

    final price7Days = currentPrice != null
        ? currentPrice * (1.0 + (_priceChangePercent / 100.0 * 0.5))
        : 0.0;
    final price15Days = currentPrice != null
        ? currentPrice * (1.0 + (_priceChangePercent / 100.0 * 0.8))
        : 0.0;

    // Scenario 1: SELL NOW
    final grossSellNow = (currentPrice ?? 0.0) * _stockQuantity;
    const storageSellNow = 0.0;
    const transportSellNow = 2500.0;
    final netSellNow = grossSellNow - storageSellNow - transportSellNow;

    // Scenario 2: HOLD 7 DAYS
    final grossHold7 = price7Days * _stockQuantity;
    final storageHold7 = 100.0 * _stockQuantity;
    const transportHold7 = 2500.0;
    final netHold7 = grossHold7 - storageHold7 - transportHold7;

    // Scenario 3: HOLD 15 DAYS
    final grossHold15 = price15Days * _stockQuantity;
    final storageHold15 = 200.0 * _stockQuantity;
    const transportHold15 = 2500.0;
    final netHold15 = grossHold15 - storageHold15 - transportHold15;

    // Determine Best Scenario
    String bestScenarioTitle = 'Sell Now';
    if (netHold7 > netSellNow && netHold7 >= netHold15) {
      bestScenarioTitle = 'Hold for 7 Days';
    } else if (netHold15 > netSellNow && netHold15 > netHold7) {
      bestScenarioTitle = 'Hold for 15 Days';
    }

    final (recAction, recReason, recBadgeColor, recBadgeContainerColor) =
        _calculateRecommendation(_priceChangePercent, _demandLevel);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back',
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('What-If Price Simulator'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
            onPressed: _fetchMarketBaseline,
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchMarketBaseline,
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 16),
            children: [
              // Baseline Header & Quantity Input Card
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
                          Text(
                            'Market Assumptions',
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
                              color: AppColors.primaryContainer,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              _crop,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24, color: AppColors.outlineVariant),
                      _ParamRow(
                        label: 'Current Mandi Rate',
                        value: currentPrice != null
                            ? _formatPrice(currentPrice)
                            : 'N/A',
                        subvalue: _marketName,
                      ),
                      const SizedBox(height: 10),
                      _ParamRow(
                        label: 'Recorded Price Trend',
                        value: '${_priceChangePercent >= 0 ? '+' : ''}$_priceChangePercent%',
                        subvalue: 'Recent Mandi movement',
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Harvest Lot Volume (Quintals)',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _quantityController,
                        keyboardType:
                            const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          hintText: 'Enter quantity in quintals',
                          suffixText: 'qtl',
                          prefixIcon: Icon(Icons.scale_rounded),
                        ),
                        onChanged: (val) {
                          final parsed = double.tryParse(val.trim());
                          setState(() {
                            _stockQuantity =
                                (parsed != null && parsed > 0) ? parsed : 0.0;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Prototype Cost Assumptions Card
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Estimated Prototype Costs',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Icon(
                            Icons.info_outline_rounded,
                            size: 18,
                            color: AppColors.outline,
                          ),
                        ],
                      ),
                      const Divider(height: 18, color: AppColors.outlineVariant),
                      Text(
                        '• Transport: ₹2,500 flat per haulage\n• Storage (Hold 7d): ₹100/quintal\n• Storage (Hold 15d): ₹200/quintal',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Scenario Comparison',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Scenario estimate based on current market trend',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(height: 12),

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
                          onPressed: _fetchMarketBaseline,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              else if (currentPrice == null)
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
                            'No market data found for Wheat',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Simulation requires live mandi rates. Please ensure Wheat rates are recorded in the database.',
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
              else ...[
                // Best Scenario Callout Banner
                Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  color: AppColors.primaryContainer.withValues(alpha: 0.35),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.stars_rounded,
                          color: AppColors.primary,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Best Scenario: $bestScenarioTitle',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Yields the highest estimated net realisable value for $_stockQuantity qtl.',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // Scenario 1: SELL NOW
                _ScenarioCard(
                  title: '1. Sell Now',
                  badgeText: 'Spot Market',
                  badgeColor: AppColors.secondaryContainer,
                  badgeTextColor: AppColors.secondary,
                  scenarioPrice: _formatPrice(currentPrice),
                  grossValue: _formatCurrency(grossSellNow),
                  storageCost: _formatCurrency(storageSellNow),
                  transportCost: _formatCurrency(transportSellNow),
                  netRealisableValue: _formatCurrency(netSellNow),
                  isBest: bestScenarioTitle == 'Sell Now',
                ),

                // Scenario 2: HOLD 7 DAYS
                _ScenarioCard(
                  title: '2. Hold for 7 Days',
                  badgeText: 'Short Hold',
                  badgeColor: AppColors.primaryContainer,
                  badgeTextColor: AppColors.primary,
                  scenarioPrice: _formatPrice(price7Days),
                  grossValue: _formatCurrency(grossHold7),
                  storageCost: _formatCurrency(storageHold7),
                  transportCost: _formatCurrency(transportHold7),
                  netRealisableValue: _formatCurrency(netHold7),
                  isBest: bestScenarioTitle == 'Hold for 7 Days',
                ),

                // Scenario 3: HOLD 15 DAYS
                _ScenarioCard(
                  title: '3. Hold for 15 Days',
                  badgeText: 'Extended Hold',
                  badgeColor: AppColors.tertiaryContainer,
                  badgeTextColor: AppColors.tertiary,
                  scenarioPrice: _formatPrice(price15Days),
                  grossValue: _formatCurrency(grossHold15),
                  storageCost: _formatCurrency(storageHold15),
                  transportCost: _formatCurrency(transportHold15),
                  netRealisableValue: _formatCurrency(netHold15),
                  isBest: bestScenarioTitle == 'Hold for 15 Days',
                ),

                const SizedBox(height: 16),

                // Current Market Recommendation Card
                Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Current Market Recommendation',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: recBadgeContainerColor,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                recAction,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: recBadgeColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 18, color: AppColors.outlineVariant),
                        Text(
                          recReason,
                          style: theme.textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Based on live price trend ($_priceChangePercent%) and demand level ($_demandLevel).',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _ParamRow extends StatelessWidget {
  final String label;
  final String value;
  final String subvalue;

  const _ParamRow({
    required this.label,
    required this.value,
    required this.subvalue,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            Text(
              subvalue,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
            ),
          ],
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _ScenarioCard extends StatelessWidget {
  final String title;
  final String badgeText;
  final Color badgeColor;
  final Color badgeTextColor;
  final String scenarioPrice;
  final String grossValue;
  final String storageCost;
  final String transportCost;
  final String netRealisableValue;
  final bool isBest;

  const _ScenarioCard({
    required this.title,
    required this.badgeText,
    required this.badgeColor,
    required this.badgeTextColor,
    required this.scenarioPrice,
    required this.grossValue,
    required this.storageCost,
    required this.transportCost,
    required this.netRealisableValue,
    this.isBest = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isBest ? AppColors.primary : AppColors.outlineVariant,
          width: isBest ? 2 : 1,
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
                    Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (isBest) ...[
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.check_circle_rounded,
                        size: 16,
                        color: AppColors.primary,
                      ),
                    ],
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    badgeText,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: badgeTextColor,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 20, color: AppColors.outlineVariant),
            _LineRow(label: 'Price per Quintal', value: scenarioPrice),
            const SizedBox(height: 6),
            _LineRow(label: 'Gross Produce Value', value: grossValue),
            const SizedBox(height: 6),
            _LineRow(
              label: 'Storage Cost',
              value: '-$storageCost',
              valueColor: AppColors.onSurfaceVariant,
            ),
            const SizedBox(height: 6),
            _LineRow(
              label: 'Transport Cost',
              value: '-$transportCost',
              valueColor: AppColors.onSurfaceVariant,
            ),
            const Divider(height: 20, color: AppColors.outlineVariant),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Net Realisable Value',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  netRealisableValue,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: isBest ? AppColors.primary : AppColors.onSurface,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LineRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _LineRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: valueColor ?? AppColors.onSurface,
          ),
        ),
      ],
    );
  }
}