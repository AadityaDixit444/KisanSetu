import 'package:flutter/material.dart';
import '../../services/demand_service.dart';
import '../../theme/app_colors.dart';
import '../../localization/language_scope.dart';
import '../../widgets/language_toggle_button.dart';
import 'demand_lot_selection_screen.dart';

class DemandBoardScreen extends StatefulWidget {
  const DemandBoardScreen({super.key});

  @override
  State<DemandBoardScreen> createState() => _DemandBoardScreenState();
}

class _DemandBoardScreenState extends State<DemandBoardScreen> {
  final DemandService _demandService = DemandService();

  bool _isLoading = true;
  String? _errorMessage;
  List<Map<String, dynamic>> _demands = [];

  @override
  void initState() {
    super.initState();
    _fetchActiveDemands();
  }

  Future<void> _fetchActiveDemands() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final demands = await _demandService.getActiveDemands();
      if (!mounted) return;
      setState(() {
        _demands = demands;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Failed to load active buyer demands: $e';
        _isLoading = false;
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

  String _formatDate(dynamic dateString) {
    if (dateString == null) return 'Open timeline';
    try {
      final parsed = DateTime.parse(dateString.toString());
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      final day = parsed.day.toString().padLeft(2, '0');
      return '$day ${months[parsed.month - 1]} ${parsed.year}';
    } catch (_) {
      return dateString.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('buyer_demand_board_title')),
        actions: [
          const Center(widthFactor: 1, child: LanguageToggleButton(isLightSurface: false)),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: context.tr('refresh_demands'),
            onPressed: _fetchActiveDemands,
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchActiveDemands,
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
                                onPressed: _fetchActiveDemands,
                                child: Text(context.tr('common_retry')),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : _demands.isEmpty
                      ? ListView(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
                          children: [
                            Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.campaign_outlined,
                                    size: 56,
                                    color: AppColors.outline,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    context.tr('no_active_buyer_demands'),
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    context.tr('direct_purchase_reqs_desc'),
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
                          itemCount: _demands.length,
                          itemBuilder: (context, index) {
                            final demand = _demands[index];
                            final crop = demand['crop']?.toString() ?? 'Produce';
                            final quantity = _formatQuantity(demand['quantity']);
                            final quality = demand['quality']?.toString() ?? 'Standard';
                            final targetPrice = _formatPrice(demand['target_price']);
                            final location = demand['location']?.toString() ?? 'Not specified';
                            final requiredBy = _formatDate(demand['required_by']);
                            final rawStatus = demand['status']?.toString().toLowerCase().trim() ?? 'active';
                            final isActive = rawStatus == 'active';

                            return Card(
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            crop,
                                            style: theme.textTheme.titleMedium?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: isActive
                                                ? AppColors.primaryContainer
                                                : AppColors.outlineVariant,
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            isActive ? 'Active Demand' : rawStatus.toUpperCase(),
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: isActive
                                                  ? AppColors.primary
                                                  : AppColors.onSurfaceVariant,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Divider(height: 20, color: AppColors.outlineVariant),
                                    _DemandDetailRow(
                                      icon: Icons.scale_rounded,
                                      label: 'Required Quantity',
                                      value: quantity,
                                    ),
                                    const SizedBox(height: 8),
                                    _DemandDetailRow(
                                      icon: Icons.verified_outlined,
                                      label: 'Quality Grade',
                                      value: quality,
                                    ),
                                    const SizedBox(height: 8),
                                    _DemandDetailRow(
                                      icon: Icons.currency_rupee_rounded,
                                      label: 'Target Buying Price',
                                      value: targetPrice,
                                      valueColor: AppColors.primary,
                                      isBold: true,
                                    ),
                                    const SizedBox(height: 8),
                                    _DemandDetailRow(
                                      icon: Icons.location_on_outlined,
                                      label: 'Destination / Warehouse',
                                      value: location,
                                    ),
                                    const SizedBox(height: 8),
                                    _DemandDetailRow(
                                      icon: Icons.calendar_today_outlined,
                                      label: 'Required By',
                                      value: requiredBy,
                                    ),
                                    if (isActive) ...[
                                      const SizedBox(height: 14),
                                      SizedBox(
                                        width: double.infinity,
                                        height: 40,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => DemandLotSelectionScreen(
                                                  demandId: demand['id'].toString(),
                                                  crop: crop,
                                                  requiredQuantity: _parseDouble(demand['quantity']),
                                                  quality: quality,
                                                  targetPrice: _parseDouble(demand['target_price']),
                                                  location: location,
                                                ),
                                              ),
                                            );
                                          },
                                          child: Text(
                                            context.tr('respond_to_demand_btn'),
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
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

class _DemandDetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isBold;
  final Color? valueColor;

  const _DemandDetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isBold = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.outline),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: isBold ? 15 : 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: valueColor ?? AppColors.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}