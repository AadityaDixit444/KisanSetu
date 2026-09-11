import 'package:flutter/material.dart';
import '../../services/offer_service.dart';
import '../../theme/app_colors.dart';
import 'offer_details_screen.dart';

class MyOffersScreen extends StatefulWidget {
  const MyOffersScreen({super.key});

  @override
  State<MyOffersScreen> createState() => _MyOffersScreenState();
}

class _MyOffersScreenState extends State<MyOffersScreen> {
  final OfferService _offerService = OfferService();

  bool _isLoading = true;
  String? _errorMessage;
  List<Map<String, dynamic>> _offers = [];

  @override
  void initState() {
    super.initState();
    _fetchOffers();
  }

  Future<void> _fetchOffers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await _offerService.getMyOffers();
      if (!mounted) return;
      setState(() {
        _offers = data;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Failed to load your offers. Please try again.';
        _isLoading = false;
      });
    }
  }

  String _formatPrice(dynamic rawPrice) {
    if (rawPrice == null) return '₹0/qtl';
    final val = rawPrice is num ? rawPrice.toDouble() : double.tryParse(rawPrice.toString()) ?? 0.0;
    if (val % 1 == 0) {
      return '₹${val.toInt().toString().replaceAllMapped(RegExp(r'(\d+?)(?=(\d\d)+(\d)(?!\d))(\.\d+)?'), (m) => '${m[1]},')}/qtl';
    }
    return '₹${val.toStringAsFixed(2)}/qtl';
  }

  String _formatQuantity(dynamic rawQty) {
    if (rawQty == null) return '0 qtl';
    final val = rawQty is num ? rawQty.toDouble() : double.tryParse(rawQty.toString()) ?? 0.0;
    return val % 1 == 0 ? '${val.toInt()} qtl' : '$val qtl';
  }

  String _formatTotalValue(double price, double qty) {
    final total = price * qty;
    return '₹${total.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d+?)(?=(\d\d)+(\d)(?!\d))(\.\d+)?'),
          (m) => '${m[1]},',
        )}';
  }

  String _formatStatus(dynamic rawStatus) {
    final status = rawStatus?.toString().toLowerCase().trim() ?? 'pending';
    switch (status) {
      case 'accepted':
        return 'Accepted';
      case 'rejected':
        return 'Rejected';
      default:
        return 'Pending';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Accepted':
        return AppColors.primary;
      case 'Rejected':
        return AppColors.error;
      default:
        return AppColors.tertiary;
    }
  }

  Color _getStatusBgColor(String status) {
    switch (status) {
      case 'Accepted':
        return AppColors.primaryContainer;
      case 'Rejected':
        return AppColors.error.withValues(alpha: 0.15);
      default:
        return AppColors.tertiaryContainer;
    }
  }

  void _openOfferDetails(Map<String, dynamic> offer) {
    final lot = offer['lots'] as Map<String, dynamic>?;

    final crop = lot?['crop']?.toString() ?? 'Produce';
    final rawQty = offer['quantity'];
    final rawPrice = offer['offer_price'];
    final rawAskingPrice = lot?['asking_price'];

    final qtyVal = rawQty is num
        ? rawQty.toDouble()
        : double.tryParse(rawQty?.toString() ?? '0') ?? 0.0;
    final priceVal = rawPrice is num
        ? rawPrice.toDouble()
        : double.tryParse(rawPrice?.toString() ?? '0') ?? 0.0;

    final quantity = _formatQuantity(rawQty);
    final offerPrice = _formatPrice(rawPrice);
    final askingPrice = _formatPrice(rawAskingPrice);
    final location = lot?['location']?.toString() ?? 'Local Mandi';
    final status = _formatStatus(offer['status']);
    final totalValue = _formatTotalValue(priceVal, qtyVal);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OfferDetailsScreen(
          crop: crop,
          quantity: quantity,
          yourOffer: offerPrice,
          askingPrice: askingPrice,
          location: location,
          status: status,
          totalValue: totalValue,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Submitted Offers'),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchOffers,
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
                  ? ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
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
                                onPressed: _fetchOffers,
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : _offers.isEmpty
                      ? ListView(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
                          children: [
                            Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.receipt_long_outlined,
                                    size: 56,
                                    color: AppColors.outline,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'No offers submitted yet',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Browse available lots to make bids and negotiate with farmers.',
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
                          itemCount: _offers.length,
                          itemBuilder: (context, index) {
                            final offer = _offers[index];
                            final lot = offer['lots'] as Map<String, dynamic>?;

                            final crop = lot?['crop']?.toString() ?? 'Produce';
                            final location = lot?['location']?.toString() ?? 'Local Mandi';
                            final rawQty = offer['quantity'];
                            final rawPrice = offer['offer_price'];
                            final rawAskingPrice = lot?['asking_price'];

                            final qtyVal = rawQty is num
                                ? rawQty.toDouble()
                                : double.tryParse(rawQty?.toString() ?? '0') ?? 0.0;
                            final priceVal = rawPrice is num
                                ? rawPrice.toDouble()
                                : double.tryParse(rawPrice?.toString() ?? '0') ?? 0.0;

                            final quantity = _formatQuantity(rawQty);
                            final offerPrice = _formatPrice(rawPrice);
                            final askingPrice = _formatPrice(rawAskingPrice);
                            final totalValue = _formatTotalValue(priceVal, qtyVal);
                            final status = _formatStatus(offer['status']);

                            return Card(
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () => _openOfferDetails(offer),
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
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: _getStatusBgColor(status),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              status,
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700,
                                                color: _getStatusColor(status),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.location_on_outlined,
                                            size: 14,
                                            color: AppColors.outline,
                                          ),
                                          const SizedBox(width: 2),
                                          Text(
                                            location,
                                            style: theme.textTheme.bodyMedium?.copyWith(
                                              color: AppColors.onSurfaceVariant,
                                              fontSize: 12,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            '• $quantity',
                                            style: theme.textTheme.bodyMedium?.copyWith(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Divider(height: 20, color: AppColors.outlineVariant),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Asking: $askingPrice',
                                                style: theme.textTheme.bodySmall?.copyWith(
                                                  color: AppColors.onSurfaceVariant,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Row(
                                                children: [
                                                  Text(
                                                    'Your Offer: ',
                                                    style: theme.textTheme.bodyMedium?.copyWith(
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                  Text(
                                                    offerPrice,
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w800,
                                                      color: AppColors.primary,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                'Total Value',
                                                style: theme.textTheme.bodySmall?.copyWith(
                                                  color: AppColors.onSurfaceVariant,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                totalValue,
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w800,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
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