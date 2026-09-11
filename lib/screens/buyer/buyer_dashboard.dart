import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../localization/language_scope.dart';
import '../../services/demand_service.dart';
import '../../services/lot_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/language_toggle_button.dart';
import '../notifications_screen.dart';
import 'browse_lots_screen.dart';
import 'buyer_lot_details_screen.dart';
import 'my_offers_screen.dart';
import 'post_demand_screen.dart';

class BuyerDashboard extends StatefulWidget {
  const BuyerDashboard({super.key});

  @override
  State<BuyerDashboard> createState() => _BuyerDashboardState();
}

class _BuyerDashboardState extends State<BuyerDashboard> {
  final DemandService _demandService = DemandService();
  final LotService _lotService = LotService();

  int _activeDemandCount = 0;
  bool _isLoadingDemands = true;

  List<Map<String, dynamic>> _directLots = [];
  bool _isLoadingLots = true;
  String? _lotsErrorMessage;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    await Future.wait([
      _loadActiveDemandCount(),
      _loadDirectFarmerLots(),
    ]);
  }

  Future<void> _loadActiveDemandCount() async {
    try {
      final currentUserId = Supabase.instance.client.auth.currentUser?.id;
      final demands = await _demandService.getActiveDemands();
      final userActiveDemands = demands.where((d) {
        return currentUserId == null || d['buyer_id']?.toString() == currentUserId;
      }).toList();

      if (!mounted) return;
      setState(() {
        _activeDemandCount = userActiveDemands.length;
        _isLoadingDemands = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoadingDemands = false;
      });
    }
  }

  Future<void> _loadDirectFarmerLots() async {
    setState(() {
      _isLoadingLots = true;
      _lotsErrorMessage = null;
    });

    try {
      final activeLots = await _lotService.getActiveLots();
      final validLots = activeLots.where((lot) {
        final id = lot['id']?.toString().trim() ?? '';
        final status = (lot['status']?.toString() ?? 'active').toLowerCase().trim();
        return id.isNotEmpty && (status == 'active' || status.isEmpty);
      }).toList();

      if (!mounted) return;
      setState(() {
        _directLots = validLots;
        _isLoadingLots = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _lotsErrorMessage = 'Failed to load farmer opportunities: $e';
        _isLoadingLots = false;
      });
    }
  }

  double _parseDouble(dynamic val) {
    if (val == null) return 0.0;
    if (val is num) return val.toDouble();
    return double.tryParse(val.toString()) ?? 0.0;
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back',
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.tr('greeting_morning'),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.onPrimary.withValues(alpha: 0.85),
              ),
            ),
            Text(
              context.tr('role_buyer'),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        actions: [
          const LanguageToggleButton(isLightSurface: false),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            tooltip: context.tr('notifications_title'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadDashboardData,
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 16),
            children: [
              // Mandi Market Rates Banner
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
                            'Procurement Index',
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
                              'Active Market',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '₹2,450',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '/ quintal benchmark (Wheat)',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Direct procurement saves up to 8% on intermediary Mandi handling and commission charges.',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),

              // Action Card: Post Commodity Demand
              Card(
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () async {
                    final result = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PostDemandScreen(),
                      ),
                    );
                    if (result == true) {
                      _loadActiveDemandCount();
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.campaign_outlined,
                            color: AppColors.primary,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Post Commodity Demand',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  if (!_isLoadingDemands)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryContainer,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        '$_activeDemandCount Active',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Broadcast your required quantity, target price & delivery location',
                                style: theme.textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 16,
                          color: AppColors.outline,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Action Card: Browse Farmer Lots
              Card(
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const BrowseLotsScreen(),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.secondaryContainer,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.travel_explore_rounded,
                            color: AppColors.secondary,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Browse Farmer Produce Lots',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 16,
                          color: AppColors.outline,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Action Card: My Submitted Offers
              Card(
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MyOffersScreen(),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.tertiaryContainer,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.local_offer_outlined,
                            color: AppColors.tertiary,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'My Submitted Offers',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Track pending bids, accepted deals & farmer counter-proposals',
                                style: theme.textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 16,
                          color: AppColors.outline,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Direct Farmer Opportunities Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Direct Farmer Opportunities',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const BrowseLotsScreen(),
                          ),
                        );
                      },
                      child: const Text('View All'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              if (_isLoadingLots)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_lotsErrorMessage != null)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: Text(
                      _lotsErrorMessage!,
                      style: theme.textTheme.bodySmall?.copyWith(color: AppColors.error),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              else if (_directLots.isEmpty)
                Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Center(
                      child: Text(
                        'No active farmer lots listed currently.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                )
              else
                ..._directLots.take(4).map((lot) {
                  final realLotId = lot['id'].toString();
                  final rawCrop = lot['crop']?.toString() ?? 'Produce';
                  final rawQuantity = lot['quantity']?.toString() ?? '0';
                  final rawQuality = lot['quality']?.toString() ?? 'Standard';
                  final rawAskingPrice = lot['asking_price']?.toString() ?? '0';
                  final rawLocation = lot['location']?.toString() ?? 'Not specified';

                  final formattedQuantity = _formatQuantity(lot['quantity']);
                  final formattedPrice = _formatPrice(lot['asking_price']);

                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BuyerLotDetailsScreen(
                              lotId: realLotId,
                              crop: rawCrop,
                              quantity: rawQuantity,
                              quality: rawQuality,
                              askingPrice: rawAskingPrice,
                              location: rawLocation,
                              distance: '',
                            ),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  rawCrop,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  formattedPrice,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Volume: $formattedQuantity • $rawQuality',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ),
                                Text(
                                  rawLocation,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: AppColors.outline,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}