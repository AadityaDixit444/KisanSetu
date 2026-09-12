import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../localization/language_scope.dart';
import '../../widgets/language_toggle_button.dart';
import 'offer_review_screen.dart';

class MakeOfferScreen extends StatefulWidget {
  final String lotId;
  final String crop;
  final String quantity;
  final String askingPrice;
  final String location;
  final String? demandId;

  const MakeOfferScreen({
    super.key,
    required this.lotId,
    required this.crop,
    required this.quantity,
    required this.askingPrice,
    required this.location,
    this.demandId,
  });

  @override
  State<MakeOfferScreen> createState() => _MakeOfferScreenState();
}

class _MakeOfferScreenState extends State<MakeOfferScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _offerPriceController;
  late final TextEditingController _quantityController;

  double _totalEstimatedValue = 0.0;

  @override
  void initState() {
    super.initState();
    _offerPriceController = TextEditingController(text: _sanitizeNumeric(widget.askingPrice));
    _quantityController = TextEditingController(text: _sanitizeNumeric(widget.quantity));

    _calculateTotal();

    _offerPriceController.addListener(_calculateTotal);
    _quantityController.addListener(_calculateTotal);
  }

  @override
  void dispose() {
    _offerPriceController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  String _sanitizeNumeric(String value) {
    return value.replaceAll(RegExp(r'[^0-9.]'), '');
  }

  /// '40' or '40 qtl' -> '40 qtl'
  String _formatQuantity(String value) {
    final qty = _parseDouble(_sanitizeNumeric(value));
    final text = qty % 1 == 0 ? qty.toInt().toString() : qty.toString();
    return '$text qtl';
  }

  /// '2500' or '₹2,500/qtl' -> '₹2,500/qtl'
  String _formatPrice(String value) {
    final price = _parseDouble(_sanitizeNumeric(value.replaceAll(',', '')));
    final whole = price % 1 == 0
        ? price.toInt().toString()
        : price.toStringAsFixed(2);
    final grouped = whole.replaceAllMapped(
      RegExp(r'(\d+?)(?=(\d\d)+(\d)(?!\d))(\.\d+)?'),
      (m) => '${m[1]},',
    );
    return '₹$grouped/qtl';
  }

  double _parseDouble(dynamic val) {
    if (val == null) return 0.0;
    if (val is num) return val.toDouble();
    return double.tryParse(val.toString()) ?? 0.0;
  }

  void _calculateTotal() {
    final price = _parseDouble(_offerPriceController.text.trim());
    final qty = _parseDouble(_quantityController.text.trim());
    setState(() {
      _totalEstimatedValue = price * qty;
    });
  }

  String _formatCurrency(double amount) {
    return '₹${amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d+?)(?=(\d\d)+(\d)(?!\d))(\.\d+)?'),
          (match) => '${match[1]},',
        )}';
  }

  void _onReviewOffer() {
    if (!_formKey.currentState!.validate()) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OfferReviewScreen(
          lotId: widget.lotId,
          crop: widget.crop,
          quantity: _quantityController.text.trim(),
          offerPrice: _offerPriceController.text.trim(),
          location: widget.location,
          askingPrice: widget.askingPrice,
          demandId: widget.demandId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final availableQuantity = _parseDouble(_sanitizeNumeric(widget.quantity));
    // Callers pass either a raw number or a string that already carries its
    // unit, so strip first and add the unit exactly once.
    final quantityLabel = _formatQuantity(widget.quantity);
    final askingPriceLabel = _formatPrice(widget.askingPrice);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('make_offer_title')),
        actions: const [
          Center(widthFactor: 1, child: LanguageToggleButton(isLightSurface: false)),
          SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Lot Summary Card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  widget.crop,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryContainer,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    context.tr('badge_produce_lot'),
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 20, color: AppColors.outlineVariant),
                            _LotInfoRow(label: context.tr('available_quantity'), value: quantityLabel),
                            const SizedBox(height: 6),
                            _LotInfoRow(label: context.tr('farmer_asking_price'), value: askingPriceLabel),
                            const SizedBox(height: 6),
                            _LotInfoRow(label: context.tr('produce_location'), value: widget.location),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Offer Configuration Card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.tr('offer_terms'),
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _offerPriceController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: InputDecoration(
                                labelText: context.tr('offered_price_label'),
                                prefixIcon: Icon(Icons.currency_rupee_rounded),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return context.tr('err_offer_price_req');
                                }
                                final val = double.tryParse(value.trim());
                                if (val == null || val <= 0) {
                                  return context.tr('err_valid_price');
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: _quantityController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: InputDecoration(
                                labelText: context.tr('offered_quantity_label'),
                                helperText: context.trWithArgs('max_available_helper', {'qty': quantityLabel}),
                                prefixIcon: const Icon(Icons.scale_rounded),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return context.tr('err_qty_req');
                                }
                                final val = double.tryParse(value.trim());
                                if (val == null || val <= 0) {
                                  return context.tr('err_valid_qty');
                                }
                                if (val > availableQuantity) {
                                  return context.trWithArgs('err_cannot_exceed_qty', {'qty': _formatQuantity(widget.quantity)});
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Calculated Total Summary Card
                    Card(
                      color: AppColors.primaryContainer.withValues(alpha: 0.3),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              context.tr('estimated_contract_total'),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              _formatCurrency(_totalEstimatedValue),
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
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
                    onPressed: _onReviewOffer,
                    child: Text(
                      context.tr('review_offer_btn'),
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
      ),
    );
  }
}

class _LotInfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _LotInfoRow({
    required this.label,
    required this.value,
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
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}