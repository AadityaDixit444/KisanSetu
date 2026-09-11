import 'package:flutter/material.dart';
import '../../services/offer_service.dart';
import '../../theme/app_colors.dart';
import '../../localization/language_scope.dart';
import '../../widgets/language_toggle_button.dart';
import 'offer_submitted_screen.dart';

class OfferReviewScreen extends StatefulWidget {
  final String lotId;
  final String crop;
  final String quantity;
  final String offerPrice;
  final String location;
  final String askingPrice;
  final String? demandId;

  const OfferReviewScreen({
    super.key,
    required this.lotId,
    required this.crop,
    required this.quantity,
    required this.offerPrice,
    required this.location,
    required this.askingPrice,
    this.demandId,
  });

  @override
  State<OfferReviewScreen> createState() => _OfferReviewScreenState();
}

class _OfferReviewScreenState extends State<OfferReviewScreen> {
  final OfferService _offerService = OfferService();
  bool _isSubmitting = false;

  double _parseDouble(dynamic val) {
    if (val == null) return 0.0;
    if (val is num) return val.toDouble();
    return double.tryParse(val.toString().replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
  }

  String _formatCurrency(double amount) {
    return '₹${amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d+?)(?=(\d\d)+(\d)(?!\d))(\.\d+)?'),
          (match) => '${match[1]},',
        )}';
  }

  Future<void> _onSubmitOffer() async {
    if (_isSubmitting) return;

    final parsedPrice = _parseDouble(widget.offerPrice);
    final parsedQty = _parseDouble(widget.quantity);

    if (parsedPrice <= 0 || parsedQty <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('err_invalid_price_or_qty'))),
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
        demandId: widget.demandId,
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
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          duration: const Duration(seconds: 3),
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
    final parsedPrice = _parseDouble(widget.offerPrice);
    final parsedQty = _parseDouble(widget.quantity);
    final totalAmount = parsedPrice * parsedQty;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('review_offer_title')),
        actions: const [
          Center(child: LanguageToggleButton(isLightSurface: false)),
          SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
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
                                widget.crop,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.secondaryContainer,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(context.tr('badge_ready_to_submit'),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.secondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 24, color: AppColors.outlineVariant),
                          _DetailRow(
                            label: context.tr('offered_unit_price'),
                            value: '₹${widget.offerPrice}/qtl',
                            isBold: true,
                            valueColor: AppColors.primary,
                          ),
                          const SizedBox(height: 10),
                          _DetailRow(
                            label: context.tr('offered_volume'),
                            value: '${widget.quantity} qtl',
                          ),
                          const SizedBox(height: 10),
                          _DetailRow(
                            label: context.tr('farmer_asking_price'),
                            value: '₹${widget.askingPrice}/qtl',
                          ),
                          const SizedBox(height: 10),
                          _DetailRow(
                            label: context.tr('produce_location'),
                            value: widget.location,
                          ),
                          const Divider(height: 24, color: AppColors.outlineVariant),
                          _DetailRow(
                            label: context.tr('total_contract_value'),
                            value: _formatCurrency(totalAmount),
                            isBold: true,
                            fontSize: 16,
                            valueColor: AppColors.primary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
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
                      : Text(context.tr('confirm_and_submit_offer'),
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

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final double fontSize;
  final Color? valueColor;

  const _DetailRow({
    required this.label,
    required this.value,
    this.isBold = false,
    this.fontSize = 14,
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
            fontSize: fontSize,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: valueColor ?? AppColors.onSurface,
          ),
        ),
      ],
    );
  }
}