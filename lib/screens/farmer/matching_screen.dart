import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/demand_service.dart';
import '../../services/lot_service.dart';
import '../../theme/app_colors.dart';
import 'demand_lot_selection_screen.dart';

class _ScoredDemand {
  final Map<String, dynamic> demand;
  final Map<String, dynamic> matchedLot;
  final int score;

  const _ScoredDemand({
    required this.demand,
    required this.matchedLot,
    required this.score,
  });
}

class MatchingScreen extends StatefulWidget {
  const MatchingScreen({super.key});

  @override
  State<MatchingScreen> createState() => _MatchingScreenState();
}

class _MatchingScreenState extends State<MatchingScreen> {
  final DemandService _demandService = DemandService();
  final LotService _lotService = LotService();

  bool _isLoading = true;
  String? _errorMessage;
  List<_ScoredDemand> _opportunities = [];

  @override
  void initState() {
    super.initState();
    _fetchAndMatchOpportunities();
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

  String _formatQuantity(dynamic rawQty) {
    final val = _parseDouble(rawQty);
    return val % 1 == 0 ? '${val.toInt()} qtl' : '$val qtl';
  }

  Future<void> _fetchAndMatchOpportunities() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final currentUserId = Supabase.instance.client.auth.currentUser?.id;
      final activeLots = await _lotService.getActiveLots();

      // Only evaluate lots owned by the authenticated farmer with quantity > 0
      final farmerLots = activeLots.where((lot) {
        final farmerId = lot['farmer_id']?.toString();
        final qty = _parseDouble(lot['quantity']);
        final isOwner = farmerId == currentUserId;
        return isOwner && qty > 0;
      }).toList();

      final activeDemands = await _demandService.getActiveDemands();

      final List<_ScoredDemand> scoredList = [];

      for (final demand in activeDemands) {
        final demandCrop = (demand['crop']?.toString() ?? '').toLowerCase().trim();
        if (demandCrop.isEmpty) continue;

        // Find farmer lots matching crop exactly
        final compatibleLots = farmerLots.where((lot) {
          final lotCrop = (lot['crop']?.toString() ?? '').toLowerCase().trim();
          return lotCrop == demandCrop;
        }).toList();

        if (compatibleLots.isEmpty) continue;

        // Evaluate the highest scoring lot for this demand
        _ScoredDemand? bestForDemand;

        for (final lot in compatibleLots) {
          int score = 40; // Crop matches exactly

          // Quality match (20 points)
          final demandQuality = (demand['quality']?.toString() ?? '').toLowerCase().trim();
          final lotQuality = (lot['quality']?.toString() ?? '').toLowerCase().trim();
          if (demandQuality.isEmpty || demandQuality == lotQuality) {
            score += 20;
          } else if (lotQuality.isNotEmpty && demandQuality.contains(lotQuality)) {
            score += 10;
          }

          // Quantity suitability (20 points)
          final demandQty = _parseDouble(demand['quantity']);
          final lotQty = _parseDouble(lot['quantity']);
          if (demandQty <= lotQty) {
            score += 20;
          } else if (lotQty > 0) {
            score += ((lotQty / demandQty) * 20).round().clamp(0, 20);
          }

          // Location match (10 points)
          final demandLoc = (demand['location']?.toString() ?? '').toLowerCase().trim();
          final lotLoc = (lot['location']?.toString() ?? '').toLowerCase().trim();
          if (demandLoc.isNotEmpty && lotLoc.isNotEmpty && (demandLoc == lotLoc || demandLoc.contains(lotLoc) || lotLoc.contains(demandLoc))) {
            score += 10;
          }

          // Price suitability (10 points)
          final askingPrice = _parseDouble(lot['asking_price']);
          final targetPrice = _parseDouble(demand['target_price']);
          if (askingPrice > 0 && targetPrice > 0 && askingPrice <= targetPrice) {
            score += 10;
          }

          if (bestForDemand == null || score > bestForDemand.score) {
            bestForDemand = _ScoredDemand(
              demand: demand,
              matchedLot: lot,
              score: score.clamp(0, 100),
            );
          }
        }

        if (bestForDemand != null) {
          scoredList.add(bestForDemand);
        }
      }

      scoredList.sort((a, b) => b.score.compareTo(a.score));

      if (!mounted) return;
      setState(() {
        _opportunities = scoredList;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Failed to load smart buyer matches: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back',
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Smart Buyer Matches'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
            onPressed: _fetchAndMatchOpportunities,
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchAndMatchOpportunities,
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
                                onPressed: _fetchAndMatchOpportunities,
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : _opportunities.isEmpty
                      ? ListView(
                          padding: const EdgeInsets.all(24),
                          children: [
                            Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.hub_outlined,
                                    size: 56,
                                    color: AppColors.outline,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'No active buyer demands found.',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'When buyers broadcast requirements matching your harvested crops, compatible procurement opportunities will rank here.',
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
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          itemCount: _opportunities.length,
                          itemBuilder: (context, index) {
                            final item = _opportunities[index];
                            final demand = item.demand;
                            final crop = demand['crop']?.toString() ?? 'Produce';
                            final quantity = _formatQuantity(demand['quantity']);
                            final quality = demand['quality']?.toString() ?? 'Standard';
                            final targetPrice = _formatPrice(demand['target_price']);
                            final location = demand['location']?.toString() ?? 'Not specified';

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
                                            crop,
                                            style: theme.textTheme.titleMedium?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: item.score >= 80
                                                ? AppColors.primaryContainer
                                                : AppColors.secondaryContainer,
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            'Compatibility Score: ${item.score}%',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: item.score >= 80
                                                  ? AppColors.primary
                                                  : AppColors.secondary,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Divider(height: 20, color: AppColors.outlineVariant),
                                    _MatchRow(
                                      label: 'Required Volume',
                                      value: quantity,
                                    ),
                                    const SizedBox(height: 6),
                                    _MatchRow(
                                      label: 'Target Buying Price',
                                      value: targetPrice,
                                      isBold: true,
                                      valueColor: AppColors.primary,
                                    ),
                                    const SizedBox(height: 6),
                                    _MatchRow(
                                      label: 'Quality Grade',
                                      value: quality,
                                    ),
                                    const SizedBox(height: 6),
                                    _MatchRow(
                                      label: 'Delivery Depot',
                                      value: location,
                                    ),
                                    const SizedBox(height: 14),
                                    SizedBox(
                                      width: double.infinity,
                                      height: 40,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => DemandLotSelectionScreen(
                                                demandId: demand['id'].toString(),
                                                crop: crop,
                                                requiredQuantity: _parseDouble(demand['quantity']),
                                                quality: quality,
                                                targetPrice: _parseDouble(demand['target_price']),
                                                location: location,
                                              ),
                                            ),
                                          );
                                        },
                                        child: const Text(
                                          'Select Lot & Respond',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
        ),
      ),
    );
  }
}

class _MatchRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final Color? valueColor;

  const _MatchRow({
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