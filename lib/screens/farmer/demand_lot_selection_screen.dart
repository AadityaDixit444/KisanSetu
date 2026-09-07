import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/lot_service.dart';
import '../../theme/app_colors.dart';
import '../buyer/make_offer_screen.dart';

class DemandLotSelectionScreen extends StatefulWidget {
  final String demandId;
  final String crop;
  final double requiredQuantity;
  final String quality;
  final double targetPrice;
  final String location;

  const DemandLotSelectionScreen({
    super.key,
    required this.demandId,
    required this.crop,
    required this.requiredQuantity,
    required this.quality,
    required this.targetPrice,
    required this.location,
  });

  @override
  State<DemandLotSelectionScreen> createState() =>
      _DemandLotSelectionScreenState();
}

class _DemandLotSelectionScreenState extends State<DemandLotSelectionScreen> {
  final LotService _lotService = LotService();

  bool _isLoading = true;
  String? _errorMessage;
  List<Map<String, dynamic>> _matchingLots = [];
  Map<String, dynamic>? _selectedLot;

  @override
  void initState() {
    super.initState();
    _fetchFarmerMatchingLots();
  }

  Future<void> _fetchFarmerMatchingLots() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final currentUserId = Supabase.instance.client.auth.currentUser?.id;
      final allLots = await _lotService.getActiveLots();

      final filteredLots = allLots.where((lot) {
        final farmerId = lot['farmer_id']?.toString();
        final lotCrop = lot['crop']?.toString().toLowerCase().trim() ?? '';
        final status = lot['status']?.toString().toLowerCase().trim() ?? '';
        final quantity = _parseDouble(lot['quantity']);

        final isOwner = currentUserId != null && farmerId == currentUserId;
        final isMatchingCrop =
            lotCrop == widget.crop.toLowerCase().trim();
        final isActive = status == 'active';
        final hasQuantity = quantity > 0;

        return isOwner && isMatchingCrop && isActive && hasQuantity;
      }).toList();

      if (!mounted) return;

      setState(() {
        _matchingLots = filteredLots;
        if (_selectedLot != null &&
            !_matchingLots.any(
                (lot) => lot['id']?.toString() == _selectedLot!['id']?.toString())) {
          _selectedLot = null;
        }
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Failed to load matching lots: $e';
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

  String _formatQuantity(dynamic rawQty) {
    final val = _parseDouble(rawQty);
    return val % 1 == 0 ? '${val.toInt()} qtl' : '$val qtl';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Lot'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh Lots',
            onPressed: _fetchFarmerMatchingLots,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                onRefresh: _fetchFarmerMatchingLots,
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  children: [
                    // Buyer Demand Summary Card
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
                                  'Buyer Demand Overview',
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
                                  child: const Text(
                                    'Active Demand',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(
                              height: 20,
                              color: AppColors.outlineVariant,
                            ),
                            _SummaryRow(
                              label: 'Crop Commodity',
                              value: widget.crop,
                            ),
                            const SizedBox(height: 6),
                            _SummaryRow(
                              label: 'Required Quantity',
                              value: _formatQuantity(widget.requiredQuantity),
                            ),
                            const SizedBox(height: 6),
                            _SummaryRow(
                              label: 'Target Buying Price',
                              value: _formatPrice(widget.targetPrice),
                              valueColor: AppColors.primary,
                              isBold: true,
                            ),
                            const SizedBox(height: 6),
                            _SummaryRow(
                              label: 'Minimum Quality',
                              value: widget.quality,
                            ),
                            const SizedBox(height: 6),
                            _SummaryRow(
                              label: 'Destination',
                              value: widget.location,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Your Matching Lots',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
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
                                onPressed: _fetchFarmerMatchingLots,
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        ),
                      )
                    else if (_matchingLots.isEmpty)
                      Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Center(
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.inventory_2_outlined,
                                  size: 48,
                                  color: AppColors.outline,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'No matching active lots found',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'You need an active lot of ${widget.crop} with available quantity to respond to this buyer demand.',
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
                      ..._matchingLots.map((lot) {
                        final lotId = lot['id']?.toString() ?? '';
                        final shortId = lotId.length > 8
                            ? lotId.substring(0, 8)
                            : lotId;
                        final crop = lot['crop']?.toString() ?? 'Produce';
                        final quantity = _formatQuantity(lot['quantity']);
                        final quality =
                            lot['quality']?.toString() ?? 'Standard';
                        final askingPrice = _formatPrice(lot['asking_price']);
                        final location =
                            lot['location']?.toString() ?? 'Not specified';

                        final isSelected =
                            _selectedLot?['id']?.toString() == lotId;

                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.outlineVariant,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              setState(() {
                                _selectedLot = lot;
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Radio<String>(
                                        value: lotId,
                                        groupValue:
                                            _selectedLot?['id']?.toString(),
                                        activeColor: AppColors.primary,
                                        onChanged: (_) {
                                          setState(() {
                                            _selectedLot = lot;
                                          });
                                        },
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              crop,
                                              style: theme
                                                  .textTheme.titleMedium
                                                  ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              'Lot ID: $shortId',
                                              style: theme
                                                  .textTheme.bodySmall
                                                  ?.copyWith(
                                                color:
                                                    AppColors.onSurfaceVariant,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        askingPrice,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Divider(
                                    height: 18,
                                    color: AppColors.outlineVariant,
                                  ),
                                  _SummaryRow(
                                    label: 'Available Quantity',
                                    value: quantity,
                                    isBold: true,
                                  ),
                                  const SizedBox(height: 6),
                                  _SummaryRow(
                                    label: 'Quality Grade',
                                    value: quality,
                                  ),
                                  const SizedBox(height: 6),
                                  _SummaryRow(
                                    label: 'Warehouse Location',
                                    value: location,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                  ],
                ),
              ),
            ),

            // Bottom Action Bar
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: AppColors.outlineVariant),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _selectedLot == null
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MakeOfferScreen(
                                demandId: widget.demandId,
                                lotId: _selectedLot!['id'].toString(),
                                crop: _selectedLot!['crop']?.toString() ??
                                    widget.crop,
                                quantity:
                                    _selectedLot!['quantity']?.toString() ??
                                        '0',
                                askingPrice:
                                    _selectedLot!['asking_price']?.toString() ??
                                        '0',
                                location:
                                    _selectedLot!['location']?.toString() ??
                                        widget.location,
                              ),
                            ),
                          );
                        },
                  child: const Text(
                    'Continue to Make Offer',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final Color? valueColor;

  const _SummaryRow({
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
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: isBold ? 14 : 13,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              color: valueColor ?? AppColors.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}