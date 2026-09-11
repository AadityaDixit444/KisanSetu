import 'package:flutter/material.dart';
import '../../services/lot_service.dart';
import '../../theme/app_colors.dart';
import '../../localization/language_scope.dart';
import '../../widgets/language_toggle_button.dart';
import 'buyer_offers_screen.dart';
import 'create_lot_screen.dart';
import 'simulator_screen.dart';

class LotsScreen extends StatefulWidget {
  const LotsScreen({super.key});

  @override
  State<LotsScreen> createState() => _LotsScreenState();
}

class _LotsScreenState extends State<LotsScreen> {
  final LotService _lotService = LotService();

  bool _isLoading = true;
  String? _errorMessage;
  List<Map<String, dynamic>> _lots = [];

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
      final lots = await _lotService.getFarmerLots();
      if (!mounted) return;
      setState(() {
        _lots = lots;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Failed to load produce lots: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _navigateToCreateLot(BuildContext context) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateLotScreen(),
      ),
    );

    if (result == true) {
      await _fetchLots();
    }
  }

  void _navigateToBuyerOffers() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const BuyerOffersScreen(),
      ),
    );
  }

  double _parseDouble(dynamic val) {
    if (val == null) return 0.0;
    if (val is num) return val.toDouble();
    return double.tryParse(val.toString().replaceAll(RegExp(r'[^0-9.-]'), '')) ?? 0.0;
  }

  String _formatQuantity(dynamic rawQty) {
    final val = _parseDouble(rawQty);
    return val % 1 == 0 ? '${val.toInt()} qtl' : '$val qtl';
  }

  String _formatPrice(dynamic rawPrice) {
    final val = _parseDouble(rawPrice);
    if (val % 1 == 0) {
      return '₹${val.toInt().toString().replaceAllMapped(RegExp(r'(\d+?)(?=(\d\d)+(\d)(?!\d))(\.\d+)?'), (m) => '${m[1]},')}/qtl';
    }
    return '₹${val.toStringAsFixed(2)}/qtl';
  }

  String _formatLotId(dynamic rawId) {
    if (rawId == null) return 'LOT-N/A';
    final idStr = rawId.toString();
    if (idStr.length > 8) {
      return 'LOT-${idStr.substring(0, 8).toUpperCase()}';
    }
    return 'LOT-${idStr.toUpperCase()}';
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
        title: Text(context.tr('my_produce_lots_title')),
        actions: [
          const Center(child: LanguageToggleButton(isLightSurface: false)),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: context.tr('refresh_tooltip'),
            onPressed: _fetchLots,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToCreateLot(context),
        icon: const Icon(Icons.add),
        label: Text(context.tr('post_new_lot_btn')),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchLots,
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 16),
            children: [
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
                            context.tr('active_inventory'),
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primaryContainer,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              context.trWithArgs('listed_lots_count', {'count': '${_lots.length}'}),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        context.tr('manage_produce_batches'),
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        context.tr('track_realtime_lots_desc'),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 14),
                      OutlinedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SimulatorScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.calculate_outlined, size: 18),
                        label: Text(context.tr('run_what_if_simulator')),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  context.tr('harvested_produce_lots'),
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
                          onPressed: _fetchLots,
                          child: Text(context.tr('common_retry')),
                        ),
                      ],
                    ),
                  ),
                )
              else if (_lots.isEmpty)
                Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: Column(
                        children: [
                          const Icon(
                            Icons.inventory_2_outlined,
                            size: 56,
                            color: AppColors.outline,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            context.tr('no_produce_lots_found'),
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            context.tr('post_crops_broadcast_desc'),
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () => _navigateToCreateLot(context),
                            icon: const Icon(Icons.add),
                            label: Text(context.tr('post_produce_lot_btn')),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                ..._lots.map((lot) {
                  final rawId = lot['id'];
                  final readableLotId = _formatLotId(rawId);
                  final crop = lot['crop']?.toString() ?? 'Produce';
                  final quantity = _formatQuantity(lot['quantity']);
                  final askingPrice = _formatPrice(lot['asking_price']);
                  final quality = lot['quality']?.toString() ?? 'Standard';
                  final rawStatus = lot['status']?.toString() ?? 'Active';
                  final isActive =
                      (lot['status']?.toString().toLowerCase().trim() == 'active');

                  final dynamic offersRaw = lot['offers'];
                  int offerCount = 0;
                  if (offersRaw is List) {
                    offerCount = offersRaw.length;
                  } else if (lot['offers_count'] != null) {
                    offerCount = _parseDouble(lot['offers_count']).toInt();
                  }

                  final offerText = offerCount > 0 ? '$offerCount Offers' : 'View Offers';

                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: _navigateToBuyerOffers,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  crop,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Row(
                                  children: [
                                    InkWell(
                                      borderRadius: BorderRadius.circular(6),
                                      onTap: _navigateToBuyerOffers,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.secondaryContainer,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                              Icons.local_offer_outlined,
                                              size: 13,
                                              color: AppColors.secondary,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              offerText,
                                              style: const TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.secondary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isActive
                                            ? AppColors.primaryContainer
                                            : AppColors.surfaceVariant,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        rawStatus.toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: isActive
                                              ? AppColors.primary
                                              : AppColors.onSurfaceVariant,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              readableLotId,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.outline,
                                fontFamily: 'monospace',
                              ),
                            ),
                            const Divider(height: 20, color: AppColors.outlineVariant),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  context.tr('available_volume'),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ),
                                Text(
                                  quantity,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  context.tr('quality_grade'),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ),
                                Text(
                                  quality,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  context.tr('asking_rate'),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ),
                                Text(
                                  askingPrice,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const SimulatorScreen(),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.analytics_outlined, size: 16),
                                label: Text(context.tr('test_what_if_return')),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}