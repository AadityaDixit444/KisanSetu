import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import 'offer_review_screen.dart';

class MakeOfferScreen extends StatefulWidget {
  final String crop;
  final String quantity;
  final String askingPrice;
  final String location;

  const MakeOfferScreen({
    super.key,
    required this.crop,
    required this.quantity,
    required this.askingPrice,
    required this.location,
  });

  @override
  State<MakeOfferScreen> createState() => _MakeOfferScreenState();
}

class _MakeOfferScreenState extends State<MakeOfferScreen> {
  late final TextEditingController _priceController;
  late final TextEditingController _quantityController;

  @override
  void initState() {
    super.initState();
    final numericPrice = widget.askingPrice.replaceAll(RegExp(r'[^0-9]'), '');
    final numericQty = widget.quantity.replaceAll(RegExp(r'[^0-9]'), '');

    _priceController = TextEditingController(text: numericPrice);
    _quantityController = TextEditingController(text: numericQty);
  }

  @override
  void dispose() {
    _priceController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  double get _estimatedTotal {
    final price = double.tryParse(_priceController.text.trim()) ?? 0.0;
    final qty = double.tryParse(_quantityController.text.trim()) ?? 0.0;
    return price * qty;
  }

  String _formatCurrency(double amount) {
    return '₹${amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d+?)(?=(\d\d)+(\d)(?!\d))(\.\d+)?'),
          (match) => '${match[1]},',
        )}';
  }

  void _onReviewOffer(BuildContext context) {
    final offerPrice = _priceController.text.trim();
    final quantity = _quantityController.text.trim();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OfferReviewScreen(
          crop: widget.crop,
          quantity: quantity,
          offerPrice: offerPrice,
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
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          children: [
            // Lot Summary Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Lot Summary',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: AppColors.onSurfaceVariant,
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
                            'Active Lot',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.onPrimaryContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          widget.crop,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Current Asking Price',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontSize: 11,
                                color: AppColors.outline,
                              ),
                            ),
                            Text(
                              widget.askingPrice,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Available Quantity',
                                  style: theme.textTheme.bodyMedium?.copyWith(fontSize: 11),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  widget.quantity,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.onSurface,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            height: 28,
                            width: 1,
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            color: AppColors.outlineVariant,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Lot Location',
                                  style: theme.textTheme.bodyMedium?.copyWith(fontSize: 11),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  widget.location,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.onSurface,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Offer Input Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Counter Offer',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Your Offer Price (per qtl)',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.currency_rupee_rounded,
                          size: 18,
                          color: AppColors.primary,
                        ),
                        hintText: 'e.g. 2400',
                        filled: true,
                        fillColor: AppColors.background,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppColors.outlineVariant),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppColors.outlineVariant),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Quantity You Want (qtl)',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _quantityController,
                      keyboardType: TextInputType.number,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.scale_rounded,
                          size: 18,
                          color: AppColors.primary,
                        ),
                        hintText: 'e.g. 100',
                        filled: true,
                        fillColor: AppColors.background,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppColors.outlineVariant),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppColors.outlineVariant),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Estimated Offer Value',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.onPrimaryContainer,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${_quantityController.text.trim().isEmpty ? "0" : _quantityController.text.trim()} qtl at ${_priceController.text.trim().isEmpty ? "₹0" : "₹${_priceController.text.trim()}"}/qtl',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontSize: 11,
                                  color: AppColors.onPrimaryContainer,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            _formatCurrency(_estimatedTotal),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Negotiation Note Card
            Card(
              color: AppColors.background,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: const BorderSide(color: AppColors.outlineVariant, width: 0.8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    const Icon(
                      Icons.handshake_outlined,
                      size: 20,
                      color: AppColors.secondary,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'You can negotiate with the farmer through KisanSetu once this offer is submitted.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 12,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Review Offer Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton.icon(
                onPressed: () => _onReviewOffer(context),
                icon: const Icon(Icons.arrow_forward_rounded),
                label: const Text('Review Offer'),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}