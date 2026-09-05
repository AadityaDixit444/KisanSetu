import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import 'offer_review_screen.dart';

class MakeOfferScreen extends StatefulWidget {
  final String lotId;
  final String crop;
  final String quantity;
  final String askingPrice;
  final String location;

  const MakeOfferScreen({
    super.key,
    required this.lotId,
    required this.crop,
    required this.quantity,
    required this.askingPrice,
    required this.location,
  });

  @override
  State<MakeOfferScreen> createState() => _MakeOfferScreenState();
}

class _MakeOfferScreenState extends State<MakeOfferScreen> {
  final _formKey = GlobalKey<FormState>();
  final _offerPriceController = TextEditingController();
  final _quantityController = TextEditingController();

  double _totalEstimatedValue = 0.0;

  @override
  void initState() {
    super.initState();
    final numericQty = widget.quantity.replaceAll(RegExp(r'[^0-9.]'), '');
    _quantityController.text = numericQty;

    final numericPrice = widget.askingPrice.replaceAll(RegExp(r'[^0-9.]'), '');
    _offerPriceController.text = numericPrice;

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

  void _calculateTotal() {
    final price = double.tryParse(_offerPriceController.text.trim()) ?? 0.0;
    final qty = double.tryParse(_quantityController.text.trim()) ?? 0.0;
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
    if (!_formKey.currentState!.validate()) {
      return;
    }

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
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Make an Offer'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 16),
            children: [
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                color: AppColors.primaryContainer.withValues(alpha: 0.5),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Target Produce Summary',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            widget.crop,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'Asking: ${widget.askingPrice}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${widget.location} • Max Available: ${widget.quantity}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bid Specifications',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _offerPriceController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Your Offer Price (₹/qtl)',
                            hintText: 'Enter amount per quintal',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.currency_rupee_rounded),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your offer price';
                            }
                            final parsed = double.tryParse(value.trim());
                            if (parsed == null || parsed <= 0) {
                              return 'Enter a valid price greater than 0';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _quantityController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Required Quantity (Quintals)',
                            hintText: 'Enter quantity you wish to buy',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.scale_outlined),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter quantity';
                            }
                            final parsed = double.tryParse(value.trim());
                            if (parsed == null || parsed <= 0) {
                              return 'Enter a valid quantity greater than 0';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Estimated Total Value',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatCurrency(_totalEstimatedValue),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        const Icon(
                          Icons.calculate_outlined,
                          size: 30,
                          color: AppColors.outline,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
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
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}