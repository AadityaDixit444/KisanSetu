import 'package:flutter/material.dart';
import '../../services/offer_service.dart';
import '../../services/transaction_service.dart';
import '../../theme/app_colors.dart';
import '../../localization/language_scope.dart';
import '../../widgets/language_toggle_button.dart';

class BuyerOffersScreen extends StatefulWidget {
  const BuyerOffersScreen({super.key});

  @override
  State<BuyerOffersScreen> createState() => _BuyerOffersScreenState();
}

class _BuyerOffersScreenState extends State<BuyerOffersScreen> {
  final OfferService _offerService = OfferService();
  final TransactionService _transactionService = TransactionService();

  bool _isLoading = true;
  String? _errorMessage;
  List<Map<String, dynamic>> _offers = [];
  final Set<String> _processingOfferIds = {};

  @override
  void initState() {
    super.initState();
    _fetchFarmerOffers();
  }

  Future<void> _fetchFarmerOffers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await _offerService.getOffersForFarmerLots();
      if (!mounted) return;
      setState(() {
        _offers = data;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Failed to load received buyer offers. Please try again.';
        _isLoading = false;
      });
    }
  }

  Map<String, dynamic>? _safeMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return null;
  }

  double _parseDouble(dynamic val) {
    if (val == null) return 0.0;
    if (val is num) return val.toDouble();
    return double.tryParse(val.toString().replaceAll(RegExp(r'[^0-9.-]'), '')) ?? 0.0;
  }

  double _extractPrice(Map<String, dynamic> offer) {
    if (offer['offer_price'] != null) {
      final p = _parseDouble(offer['offer_price']);
      if (p > 0) return p;
    }
    if (offer['offered_price'] != null) {
      final p = _parseDouble(offer['offered_price']);
      if (p > 0) return p;
    }
    if (offer['price'] != null) {
      final p = _parseDouble(offer['price']);
      if (p > 0) return p;
    }
    return 0.0;
  }

  double _extractQuantity(Map<String, dynamic> offer, Map<String, dynamic>? lot) {
    if (offer['quantity'] != null) {
      final q = _parseDouble(offer['quantity']);
      if (q > 0) return q;
    }
    if (lot != null && lot['quantity'] != null) {
      final q = _parseDouble(lot['quantity']);
      if (q > 0) return q;
    }
    return 0.0;
  }

  String _extractCrop(Map<String, dynamic> offer, Map<String, dynamic>? lot) {
    if (lot != null && lot['crop'] != null && lot['crop'].toString().trim().isNotEmpty) {
      return lot['crop'].toString().trim();
    }
    if (offer['crop'] != null && offer['crop'].toString().trim().isNotEmpty) {
      return offer['crop'].toString().trim();
    }
    return 'Produce';
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

  String _formatStatus(dynamic rawStatus) {
    final status = rawStatus?.toString().toLowerCase().trim() ?? 'pending';
    switch (status) {
      case 'accepted':
        return 'Accepted';
      case 'rejected':
      case 'declined':
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

  Future<void> _onDecline(String offerId) async {
    if (_processingOfferIds.contains(offerId)) return;

    setState(() {
      _processingOfferIds.add(offerId);
    });

    try {
      await _transactionService.rejectOffer(offerId);
      if (!mounted) return;

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr('offer_declined_msg')),
          duration: const Duration(seconds: 2),
        ),
      );

      await _fetchFarmerOffers();
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr('failed_decline_offer')),
          duration: const Duration(seconds: 2),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _processingOfferIds.remove(offerId);
        });
      }
    }
  }

  Future<void> _onAcceptOffer(String offerId) async {
    if (_processingOfferIds.contains(offerId)) return;

    final offer = _offers.firstWhere(
      (o) => o['id']?.toString() == offerId,
      orElse: () => <String, dynamic>{},
    );

    if (offer.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr('err_offer_not_found')),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    final lotData = _safeMap(offer['lots']);
    final lotId = offer['lot_id']?.toString() ?? lotData?['id']?.toString() ?? '';
    final buyerId = offer['buyer_id']?.toString() ?? '';
    final crop = _extractCrop(offer, lotData);
    final quantity = _extractQuantity(offer, lotData);
    final agreedPrice = _extractPrice(offer);

    if (lotId.isEmpty || buyerId.isEmpty || quantity <= 0 || agreedPrice <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr('err_incomplete_offer_details')),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      _processingOfferIds.add(offerId);
    });

    try {
      await _transactionService.acceptOfferAndCreateTransaction(
        offerId: offerId,
        lotId: lotId,
        buyerId: buyerId,
        crop: crop,
        quantity: quantity,
        agreedPrice: agreedPrice,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr('offer_accepted_success')),
          duration: const Duration(seconds: 2),
        ),
      );

      await _fetchFarmerOffers();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.trWithArgs('failed_accept_offer', {'error': e.toString().replaceAll('Exception: ', '')})),
          duration: const Duration(seconds: 2),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _processingOfferIds.remove(offerId);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final latestLot = _offers.isNotEmpty ? _safeMap(_offers.first['lots']) : null;
    final summaryCrop = latestLot != null ? _extractCrop(_offers.first, latestLot) : 'Crop Produce';
    final summaryQty = latestLot != null ? _formatQuantity(_extractQuantity(_offers.first, latestLot)) : '0 qtl';
    final summaryQuality = latestLot?['quality']?.toString() ?? 'Standard';
    final summaryLocation = latestLot?['location']?.toString() ?? 'Local Mandi';

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('buyer_offers_title')),
        actions: const [
          Center(widthFactor: 1, child: LanguageToggleButton(isLightSurface: false)),
          SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchFarmerOffers,
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
                                onPressed: _fetchFarmerOffers,
                                child: Text(context.tr('common_retry')),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : ListView(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      children: [
                        if (_offers.isNotEmpty)
                          Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            color: AppColors.primaryContainer.withValues(alpha: 0.5),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        summaryCrop,
                                        style: theme.textTheme.headlineSmall?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.onPrimaryContainer,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          context.trWithArgs('offers_count_badge', {'count': '${_offers.length}'}),
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.onPrimary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Quantity: $summaryQty • Quality: $summaryQuality • $summaryLocation',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: AppColors.onPrimaryContainer,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            context.tr('received_offers_heading'),
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (_offers.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.gavel_outlined,
                                    size: 56,
                                    color: AppColors.outline,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    context.tr('no_buyer_offers_yet'),
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    context.tr('offers_appear_here_desc'),
                                    textAlign: TextAlign.center,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: AppColors.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          ..._offers.map((offer) {
                            final offerId = offer['id']?.toString() ?? '';
                            final lot = _safeMap(offer['lots']);
                            final profile = _safeMap(offer['profiles']);

                            final buyerName = profile?['name']?.toString() ?? 'Verified Buyer';
                            final buyerLocation = profile?['location']?.toString() ?? lot?['location']?.toString() ?? 'Direct Buyer';
                            final demand = _formatQuantity(_extractQuantity(offer, lot));
                            final offeredPrice = _formatPrice(_extractPrice(offer));
                            final status = _formatStatus(offer['status']);
                            final isPending = status.toLowerCase() == 'pending';
                            final isProcessing = _processingOfferIds.contains(offerId);

                            return Card(
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            CircleAvatar(
                                              radius: 18,
                                              backgroundColor: AppColors.secondaryContainer,
                                              child: const Icon(
                                                Icons.storefront_rounded,
                                                color: AppColors.secondary,
                                                size: 20,
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  buyerName,
                                                  style: theme.textTheme.titleMedium?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Text(
                                                  buyerLocation,
                                                  style: theme.textTheme.bodySmall?.copyWith(
                                                    color: AppColors.onSurfaceVariant,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
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
                                              fontWeight: FontWeight.bold,
                                              color: _getStatusColor(status),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    _OfferSpecRow(
                                      label: 'Offered Demand',
                                      value: demand,
                                      icon: Icons.scale_outlined,
                                    ),
                                    const SizedBox(height: 6),
                                    _OfferSpecRow(
                                      label: 'Offered Price',
                                      value: offeredPrice,
                                      icon: Icons.currency_rupee_rounded,
                                      isHighlighted: true,
                                    ),
                                    const SizedBox(height: 6),
                                    _OfferSpecRow(
                                      label: 'Est. Logistics Cost',
                                      value: context.tr('not_calculated'),
                                      icon: Icons.local_shipping_outlined,
                                    ),
                                    const SizedBox(height: 6),
                                    _OfferSpecRow(
                                      label: 'Net Realisable Price',
                                      value: context.tr('not_calculated'),
                                      icon: Icons.account_balance_wallet_outlined,
                                      isHighlighted: true,
                                    ),
                                    if (isPending) ...[
                                      const SizedBox(height: 14),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: OutlinedButton(
                                              onPressed: isProcessing ? null : () => _onDecline(offerId),
                                              child: Text(context.tr('decline_offer_btn')),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: ElevatedButton(
                                              onPressed: isProcessing ? null : () => _onAcceptOffer(offerId),
                                              child: isProcessing
                                                  ? const SizedBox(
                                                      width: 20,
                                                      height: 20,
                                                      child: CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                        color: AppColors.onPrimary,
                                                      ),
                                                    )
                                                  : Text(context.tr('accept_offer_btn')),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          }),
                        const SizedBox(height: 20),
                      ],
                    ),
        ),
      ),
    );
  }
}

class _OfferSpecRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool isHighlighted;

  const _OfferSpecRow({
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
          size: 16,
          color: isHighlighted ? AppColors.primary : AppColors.outline,
        ),
        const SizedBox(width: 8),
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
            fontSize: isHighlighted ? 14 : 13,
            fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w600,
            color: isHighlighted ? AppColors.primary : AppColors.onSurface,
          ),
        ),
      ],
    );
  }
}