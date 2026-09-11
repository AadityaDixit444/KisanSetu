import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../theme/app_colors.dart';
import '../../localization/language_scope.dart';
import '../../widgets/language_toggle_button.dart';
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

class _DemandLotSelectionScreenState
    extends State<DemandLotSelectionScreen> {
  final SupabaseClient _client = Supabase.instance.client;

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
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final user = _client.auth.currentUser;

      if (user == null) {
        throw Exception('No authenticated farmer found');
      }

      final data = await _client
          .from('lots')
          .select('''
            id,
            farmer_id,
            crop,
            quantity,
            quality,
            asking_price,
            location,
            status,
            created_at
          ''')
          .eq('farmer_id', user.id)
          .eq('status', 'active')
          .order('created_at', ascending: false);

      final demandCrop = _normalizeCrop(widget.crop);

      final filteredLots =
          List<Map<String, dynamic>>.from(data).where((lot) {
        final lotCrop = _normalizeCrop(lot['crop']?.toString() ?? '');
        final quantity = _parseDouble(lot['quantity']);

        return lotCrop == demandCrop && quantity > 0;
      }).toList();

      if (!mounted) return;

      setState(() {
        _matchingLots = filteredLots;

        if (_selectedLot != null &&
            !_matchingLots.any(
              (lot) =>
                  lot['id']?.toString() ==
                  _selectedLot!['id']?.toString(),
            )) {
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

  String _normalizeCrop(String value) {
    return value
        .toLowerCase()
        .trim()
        .replaceAll(RegExp(r'\s+'), ' ');
  }

  double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  String _formatPrice(dynamic rawPrice) {
    final value = _parseDouble(rawPrice);

    if (value % 1 == 0) {
      return '₹${value.toInt().toString().replaceAllMapped(
            RegExp(r'(\d+?)(?=(\d\d)+(\d)(?!\d))'),
            (match) => '${match[1]},',
          )}/qtl';
    }

    return '₹${value.toStringAsFixed(2)}/qtl';
  }

  String _formatQuantity(dynamic rawQuantity) {
    final value = _parseDouble(rawQuantity);

    return value % 1 == 0
        ? '${value.toInt()} qtl'
        : '$value qtl';
  }

  void _selectLot(Map<String, dynamic> lot) {
    setState(() {
      _selectedLot = lot;
    });
  }

  void _continueToOffer() {
    if (_selectedLot == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MakeOfferScreen(
          demandId: widget.demandId,
          lotId: _selectedLot!['id'].toString(),
          crop: _selectedLot!['crop']?.toString() ?? widget.crop,

          // IMPORTANT:
          // Offer only the quantity requested by the buyer,
          // not the entire farmer lot quantity.
          quantity: widget.requiredQuantity.toString(),

          askingPrice:
              _selectedLot!['asking_price']?.toString() ?? '0',
          location:
              _selectedLot!['location']?.toString() ?? widget.location,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('select_lot_title')),
        actions: [
          const Center(child: LanguageToggleButton(isLightSurface: false)),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: context.tr('refresh_lots'),
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
                    Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  context.tr('buyer_demand_overview'),
                                  style: theme.textTheme.titleMedium
                                      ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        AppColors.primaryContainer,
                                    borderRadius:
                                        BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    context.tr('active_demand_badge'),
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 20),
                            _SummaryRow(
                              label: 'Crop Commodity',
                              value: widget.crop,
                            ),
                            const SizedBox(height: 6),
                            _SummaryRow(
                              label: 'Required Quantity',
                              value:
                                  _formatQuantity(
                                widget.requiredQuantity,
                              ),
                            ),
                            const SizedBox(height: 6),
                            _SummaryRow(
                              label: 'Target Buying Price',
                              value:
                                  _formatPrice(widget.targetPrice),
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
                      padding:
                          const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        context.tr('your_matching_lots'),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_isLoading)
                      const Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 48),
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
                                style:
                                    theme.textTheme.bodyMedium?.copyWith(
                                  color: AppColors.error,
                                ),
                              ),
                              const SizedBox(height: 12),
                              OutlinedButton(
                                onPressed:
                                    _fetchFarmerMatchingLots,
                                child: Text(context.tr('common_retry')),
                              ),
                            ],
                          ),
                        ),
                      )
                    else if (_matchingLots.isEmpty)
                      Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                        ),
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
                                  context.tr('no_matching_active_lots'),
                                  style: theme
                                      .textTheme.titleSmall
                                      ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  context.trWithArgs('need_active_lot_desc', {'crop': widget.crop}),
                                  textAlign: TextAlign.center,
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
                        ),
                      )
                    else
                      ..._matchingLots.map((lot) {
                        final lotId =
                            lot['id']?.toString() ?? '';

                        final shortId = lotId.length > 8
                            ? lotId.substring(0, 8)
                            : lotId;

                        final crop =
                            lot['crop']?.toString() ?? 'Produce';

                        final quantity =
                            _formatQuantity(lot['quantity']);

                        final quality =
                            lot['quality']?.toString() ??
                                'Standard';

                        final askingPrice =
                            _formatPrice(lot['asking_price']);

                        final location =
                            lot['location']?.toString() ??
                                'Not specified';

                        final lotQuantity =
                            _parseDouble(lot['quantity']);

                        final isSelected =
                            _selectedLot?['id']?.toString() ==
                                lotId;

                        final canFulfill =
                            lotQuantity >=
                                widget.requiredQuantity;

                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(12),
                            side: BorderSide(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.outlineVariant,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: InkWell(
                            borderRadius:
                                BorderRadius.circular(12),
                            onTap: () => _selectLot(lot),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Radio<String>(
                                        value: lotId,
                                        groupValue:
                                            _selectedLot?['id']
                                                ?.toString(),
                                        activeColor:
                                            AppColors.primary,
                                        onChanged: (_) =>
                                            _selectLot(lot),
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              crop,
                                              style: theme.textTheme
                                                  .titleMedium
                                                  ?.copyWith(
                                                fontWeight:
                                                    FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              context.trWithArgs('lot_id_format', {'id': shortId}),
                                              style: theme.textTheme
                                                  .bodySmall
                                                  ?.copyWith(
                                                color: AppColors
                                                    .onSurfaceVariant,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        askingPrice,
                                        style: const TextStyle(
                                          fontWeight:
                                              FontWeight.bold,
                                          fontSize: 15,
                                          color:
                                              AppColors.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Divider(height: 18),
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
                                  const SizedBox(height: 10),
                                  Container(
                                    width: double.infinity,
                                    padding:
                                        const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: canFulfill
                                          ? AppColors
                                              .primaryContainer
                                          : AppColors.error
                                              .withValues(
                                            alpha: 0.10,
                                          ),
                                      borderRadius:
                                          BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      canFulfill
                                          ? '✓ Sufficient quantity for this demand'
                                          : 'Partial quantity available — you can still respond',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight:
                                            FontWeight.w600,
                                        color: canFulfill
                                            ? AppColors.primary
                                            : AppColors.error,
                                      ),
                                    ),
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
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(
                    color: AppColors.outlineVariant,
                  ),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _selectedLot == null
                      ? null
                      : _continueToOffer,
                  child: Text(context.tr('continue_to_make_offer'),
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
      mainAxisAlignment:
          MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style:
              Theme.of(context).textTheme.bodyMedium?.copyWith(
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
              fontWeight:
                  isBold ? FontWeight.bold : FontWeight.w500,
              color:
                  valueColor ?? AppColors.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}