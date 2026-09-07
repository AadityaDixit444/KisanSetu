import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Make an Offer'),
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
                                  child: const Text(
                                    'Produce Lot',
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
                            _LotInfoRow(label: 'Available Quantity', value: '${widget.quantity} qtl'),
                            const SizedBox(height: 6),
                            _LotInfoRow(label: 'Farmer Asking Price', value: '₹${widget.askingPrice}/qtl'),
                            const SizedBox(height: 6),
                            _LotInfoRow(label: 'Produce Location', value: widget.location),
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
                              'Offer Terms',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _offerPriceController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: const InputDecoration(
                                labelText: 'Offered Price (₹/qtl)',
                                prefixIcon: Icon(Icons.currency_rupee_rounded),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Offer price is required';
                                }
                                final val = double.tryParse(value.trim());
                                if (val == null || val <= 0) {
                                  return 'Enter a valid price greater than 0';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: _quantityController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: InputDecoration(
                                labelText: 'Offered Quantity (qtl)',
                                helperText: 'Max available: ${widget.quantity} qtl',
                                prefixIcon: const Icon(Icons.scale_rounded),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Quantity is required';
                                }
                                final val = double.tryParse(value.trim());
                                if (val == null || val <= 0) {
                                  return 'Enter a valid quantity greater than 0';
                                }
                                if (val > availableQuantity) {
                                  return 'Cannot exceed available lot quantity (${widget.quantity} qtl)';
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
                              'Estimated Contract Total',
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
                    child: const Text(
                      'Review Offer',
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