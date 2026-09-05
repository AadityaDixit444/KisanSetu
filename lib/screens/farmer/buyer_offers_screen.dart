import 'package:flutter/material.dart';
import '../../services/offer_service.dart';
import '../../theme/app_colors.dart';

class BuyerOffersScreen extends StatefulWidget {
  const BuyerOffersScreen({super.key});

  @override
  State<BuyerOffersScreen> createState() => _BuyerOffersScreenState();
}

class _BuyerOffersScreenState extends State<BuyerOffersScreen> {
  final OfferService _offerService = OfferService();

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
      await _offerService.declineOffer(offerId: offerId);
      if (!mounted) return;

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Offer declined'),
          duration: Duration(seconds: 2),
        ),
      );

      await _fetchFarmerOffers();
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to decline offer. Please try again.'),
          duration: Duration(seconds: 2),
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

    setState(() {
      _processingOfferIds.add(offerId);
    });

    try {
      await _offerService.acceptOffer(offerId: offerId);
      await _offerService.createTransactionFromOffer(offerId: offerId);

      if (!mounted) return;

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Offer accepted successfully'),
          duration: Duration(seconds: 2),
        ),
      );

      await _fetchFarmerOffers();
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to accept offer. Please try again.'),
          duration: Duration(seconds: 2),
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

    final latestLot = _offers.isNotEmpty ? _offers.first['lots'] as Map<String, dynamic>? : null;
    final summaryCrop = latestLot?['crop']?.toString() ?? 'Crop Produce';
    final summaryQty = _formatQuantity(latestLot?['quantity']);
    final summaryQuality = latestLot?['quality']?.toString() ?? 'Standard';
    final summaryLocation = latestLot?['location']?.toString() ?? 'Local Mandi';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Buyer Offers'),
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
                                child: const Text('Retry'),
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
                                          '${_offers.length} Offers',
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
                            'Received Offers',
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
                                  Icon(
                                    Icons.gavel_outlined,
                                    size: 56,
                                    color: AppColors.outline,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'No buyer offers received yet',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Offers submitted by prospective buyers will appear here.',
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
                            final lot = offer['lots'] as Map<String, dynamic>?;
                            final profile = offer['profiles'] as Map<String, dynamic>?;

                            final buyerName = profile?['name']?.toString() ?? 'Verified Buyer';
                            final buyerLocation = profile?['location']?.toString() ?? lot?['location']?.toString() ?? 'Direct Buyer';
                            final demand = _formatQuantity(offer['quantity']);
                            final offeredPrice = _formatPrice(offer['offer_price']);
                            final status = _formatStatus(offer['status']);
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
                                    const _OfferSpecRow(
                                      label: 'Est. Logistics Cost',
                                      value: 'Not calculated',
                                      icon: Icons.local_shipping_outlined,
                                    ),
                                    const SizedBox(height: 6),
                                    const _OfferSpecRow(
                                      label: 'Net Realisable Price',
                                      value: 'Not calculated',
                                      icon: Icons.account_balance_wallet_outlined,
                                      isHighlighted: true,
                                    ),
                                    const SizedBox(height: 14),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: OutlinedButton(
                                            onPressed: isProcessing ? null : () => _onDecline(offerId),
                                            child: const Text('Decline'),
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
                                                : const Text('Accept Offer'),
                                          ),
                                        ),
                                      ],
                                    ),
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