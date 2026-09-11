import 'package:flutter/material.dart';
import '../../services/market_price_service.dart';
import '../../theme/app_colors.dart';
import '../../localization/language_scope.dart';
import '../../widgets/language_toggle_button.dart';
import 'simulator_screen.dart';

class RecommendationScreen extends StatefulWidget {
  const RecommendationScreen({super.key});

  @override
  State<RecommendationScreen> createState() => _RecommendationScreenState();
}

class _RecommendationScreenState extends State<RecommendationScreen> {
  final MarketPriceService _marketPriceService = MarketPriceService();

  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic>? _wheatData;

  @override
  void initState() {
    super.initState();
    _fetchRecommendationData();
  }

  Future<void> _fetchRecommendationData() async {
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
          (item) => (item['crop']?.toString().toLowerCase().trim() ?? '') == 'wheat',
          orElse: () => <String, dynamic>{},
        ),
      );

      setState(() {
        _wheatData = wheatRecord.isNotEmpty ? wheatRecord : null;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Failed to load recommendation data: $e';
        _isLoading = false;
      });
    }
  }

  double _parseDouble(dynamic val) {
    if (val == null) return 0.0;
    if (val is num) return val.toDouble();
    return double.tryParse(val.toString().replaceAll(RegExp(r'[^0-9.-]'), '')) ?? 0.0;
  }

  double _parsePercent(dynamic val) {
    if (val == null) return 0.0;
    final cleaned = val.toString().replaceAll('%', '').trim();
    return double.tryParse(cleaned) ?? 0.0;
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

  (String action, String reason, Color color, Color containerColor) _calculateRecommendation(
    double priceChange,
    String demandLevel,
  ) {
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

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: context.tr('common_back'),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(context.tr('market_advisory_title')),
        actions: [
          const Center(child: LanguageToggleButton(isLightSurface: false)),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: context.tr('refresh_tooltip'),
            onPressed: _fetchRecommendationData,
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchRecommendationData,
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
                  ? ListView(
                      padding: const EdgeInsets.all(24),
                      children: [
                        Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
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
                                onPressed: _fetchRecommendationData,
                                child: Text(context.tr('common_retry')),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : _wheatData == null
                      ? ListView(
                          padding: const EdgeInsets.all(24),
                          children: [
                            Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.insights_rounded,
                                    size: 56,
                                    color: AppColors.outline,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    context.tr('no_market_data_wheat'),
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    context.tr('rec_requires_live_mandi'),
                                    textAlign: TextAlign.center,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: AppColors.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      : _buildContent(context, _wheatData!),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, Map<String, dynamic> data) {
    final theme = Theme.of(context);

    final market = data['market']?.toString() ?? 'Meerut Mandi';
    final currentPrice = _formatPrice(data['price']);
    final priceChangeVal = _parsePercent(data['price_change']);
    final priceChangeStr = data['price_change']?.toString() ?? '$priceChangeVal%';
    final demandLevel = data['demand_level']?.toString() ?? 'Moderate';
    final arrivalVolume = _formatArrival(data['arrival_volume']);

    final (action, reason, badgeColor, badgeContainerColor) =
        _calculateRecommendation(priceChangeVal, demandLevel);

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      children: [
        // Action Signal Card
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
                      '${context.tr("crop_wheat")} • $market',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: badgeContainerColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        action,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: badgeColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  currentPrice,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  reason,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Live Market Fundamentals
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            context.tr('underlying_market_factors'),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8),

        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _DetailRow(
                  label: 'Benchmark Spot Rate',
                  value: currentPrice,
                  isBold: true,
                  valueColor: AppColors.primary,
                ),
                const Divider(height: 20, color: AppColors.outlineVariant),
                _DetailRow(
                  label: 'Recent Price Change',
                  value: priceChangeStr,
                  valueColor: priceChangeVal >= 0 ? AppColors.primary : AppColors.error,
                  isBold: true,
                ),
                const Divider(height: 20, color: AppColors.outlineVariant),
                _DetailRow(
                  label: 'Market Demand Level',
                  value: demandLevel,
                ),
                const Divider(height: 20, color: AppColors.outlineVariant),
                _DetailRow(
                  label: 'Arrival Volume',
                  value: arrivalVolume,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Simulator Navigation Card
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
                          context.tr('price_realisation_simulator'),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          context.tr('model_net_returns_desc'),
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

        const SizedBox(height: 24),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final Color? valueColor;

  const _DetailRow({
    required this.label,
    required this.value,
    this.isBold = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 15 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: valueColor ?? AppColors.onSurface,
          ),
        ),
      ],
    );
  }
}