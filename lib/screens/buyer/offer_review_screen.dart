import 'package:flutter/material.dart';
import '../../services/offer_service.dart';
import '../../theme/app_colors.dart';
import 'offer_submitted_screen.dart';

class OfferReviewScreen extends StatefulWidget {
  final String lotId;
  final String crop;
  final String quantity;
  final String offerPrice;
  final String location;
  final String askingPrice;

  const OfferReviewScreen({
    super.key,
    required this.lotId,
    required this.crop,
    required this.quantity,
    required this.offerPrice,
    required this.location,
    required this.askingPrice,
  });

  @override
  State<OfferReviewScreen> createState() => _OfferReviewScreenState();
}

class _OfferReviewScreenState extends State<OfferReviewScreen> {
  final OfferService _offerService = OfferService();
  bool _isSubmitting = false;

  double get _totalOfferValue {
    final price = double.tryParse(widget.offerPrice.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
    final qty = double.tryParse(widget.quantity.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
    return price * qty;
  }

  String _formatCurrency(double amount) {
    return '₹${amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d+?)(?=(\d\d)+(\d)(?!\d))(\.\d+)?'),
          (match) => '${match[1]},',
        )}';
  }

  Future<void> _onSubmitOffer() async {
    if (_isSubmitting) return;

    final parsedPrice = double.tryParse(widget.offerPrice.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
    final parsedQty = double.tryParse(widget.quantity.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;

    if (parsedPrice <= 0 || parsedQty <= 0) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid offer price or quantity.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await _offerService.createOffer(
        lotId: widget.lotId,
        offerPrice: parsedPrice,
        quantity: parsedQty,
      );

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OfferSubmittedScreen(
            lotId: widget.lotId,
            crop: widget.crop,
            quantity: widget.quantity,
            offerPrice: widget.offerPrice,
            location: widget.location,
            askingPrice: widget.askingPrice,
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to submit offer. Please try again.'),
          duration: Duration(seconds: 2),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Offer'),
      ),
      body: SafeArea(
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
                      'Review Your Offer Details',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Please verify all offer parameters before submitting your bid to the farmer.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Summary Breakdown',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _ReviewItemRow(
                      label: 'Crop Name',
                      value: widget.crop,
                      icon: Icons.eco_outlined,
                    ),
                    const SizedBox(height: 10),
                    _ReviewItemRow(
                      label: 'Offered Quantity',
                      value: widget.quantity.contains('qtl') ? widget.quantity : '${widget.quantity} qtl',
                      icon: Icons.scale_outlined,
                    ),
                    const SizedBox(height: 10),
                    _ReviewItemRow(
                      label: 'Mandi / Location',
                      value: widget.location,
                      icon: Icons.location_on_outlined,
                    ),
                    const SizedBox(height: 10),
                    _ReviewItemRow(
                      label: 'Farmer Asking Price',
                      value: widget.askingPrice.contains('/qtl') ? widget.askingPrice : '${widget.askingPrice}/qtl',
                      icon: Icons.sell_outlined,
                    ),
                    const SizedBox(height: 10),
                    _ReviewItemRow(
                      label: 'Your Offer Price',
                      value: widget.offerPrice.contains('/qtl') ? widget.offerPrice : '₹${widget.offerPrice}/qtl',
                      icon: Icons.currency_rupee_rounded,
                      isHighlighted: true,
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Divider(color: AppColors.outlineVariant),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Estimated Total Offer Value',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _formatCurrency(_totalOfferValue),
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
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _onSubmitOffer,
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.onPrimary,
                          ),
                        )
                      : const Text(
                          'Confirm & Send Offer',
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
    );
  }
}

class _ReviewItemRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool isHighlighted;

  const _ReviewItemRow({
    required this.label,
    required this.value,
    required this.icon,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: isHighlighted ? AppColors.primary : AppColors.outline,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isHighlighted ? 15 : 14,
            fontWeight: isHighlighted ? FontWeight.w800 : FontWeight.w600,
            color: isHighlighted ? AppColors.primary : AppColors.onSurface,
          ),
        ),
      ],
    );
  }
}