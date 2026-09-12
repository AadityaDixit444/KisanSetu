import 'package:flutter/material.dart';
import '../../services/logistics_service.dart';
import '../../services/transaction_service.dart';
import '../../theme/app_colors.dart';
import '../../localization/language_scope.dart';
import '../../widgets/language_toggle_button.dart';
import 'transport_options_screen.dart';

class LogisticsScreen extends StatefulWidget {
  const LogisticsScreen({super.key});

  @override
  State<LogisticsScreen> createState() => _LogisticsScreenState();
}

class _LogisticsScreenState extends State<LogisticsScreen> {
  final TransactionService _transactionService = TransactionService();
  final LogisticsService _logisticsService = LogisticsService();

  bool _isLoading = true;
  String? _errorMessage;
  List<Map<String, dynamic>> _confirmedTransactions = [];
  final Map<String, Map<String, dynamic>?> _logisticsMap = {};

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final transactions = await _transactionService.getFarmerTransactions();
      final confirmed = transactions.where((tx) {
        final status = tx['status']?.toString().toLowerCase().trim() ?? '';
        return status == 'confirmed';
      }).toList();

      final Map<String, Map<String, dynamic>?> logisticsResults = {};
      for (final tx in confirmed) {
        final txId = tx['id']?.toString() ?? '';
        if (txId.isNotEmpty) {
          try {
            final logistics = await _logisticsService.getLogisticsForTransaction(
              transactionId: txId,
            );
            logisticsResults[txId] = logistics;
          } catch (_) {
            logisticsResults[txId] = null;
          }
        }
      }

      if (!mounted) return;
      setState(() {
        _confirmedTransactions = confirmed;
        _logisticsMap.clear();
        _logisticsMap.addAll(logisticsResults);
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Failed to load logistics information. Please try again.';
        _isLoading = false;
      });
    }
  }

  String _formatCurrency(dynamic amount) {
    if (amount == null) return '₹0';
    final val = amount is num ? amount.toDouble() : double.tryParse(amount.toString()) ?? 0.0;
    return '₹${val.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d+?)(?=(\d\d)+(\d)(?!\d))(\.\d+)?'),
          (match) => '${match[1]},',
        )}';
  }

  String _formatQuantity(dynamic rawQty) {
    if (rawQty == null) return '0 qtl';
    final val = rawQty is num ? rawQty.toDouble() : double.tryParse(rawQty.toString()) ?? 0.0;
    return val % 1 == 0 ? '${val.toInt()} qtl' : '$val qtl';
  }

  String _formatDate(dynamic dateString) {
    if (dateString == null) return 'Not scheduled';
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
        title: Text(context.tr('logistics_fulfillment_title')),
        actions: const [
          Center(widthFactor: 1, child: LanguageToggleButton(isLightSurface: false)),
          SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchData,
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
                                onPressed: _fetchData,
                                child: Text(context.tr('common_retry')),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : _confirmedTransactions.isEmpty
                      ? ListView(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
                          children: [
                            Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.local_shipping_outlined,
                                    size: 56,
                                    color: AppColors.outline,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    context.tr('no_confirmed_deals'),
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    context.tr('logistics_tracking_desc'),
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
                          itemCount: _confirmedTransactions.length,
                          itemBuilder: (context, index) {
                            final tx = _confirmedTransactions[index];
                            final txId = tx['id']?.toString() ?? '';
                            final lot = tx['lots'] as Map<String, dynamic>?;

                            final crop = lot?['crop']?.toString() ?? 'Crop Produce';
                            final quantity = _formatQuantity(tx['quantity']);
                            final quality = lot?['quality']?.toString() ?? 'Standard';
                            final lotLocation = lot?['location']?.toString() ?? 'Farm Location';
                            final buyerId = tx['buyer_id']?.toString() ?? 'Unknown';

                            final logistics = _logisticsMap[txId];
                            final hasLogistics = logistics != null;
                            final logisticsStatus = logistics?['status']?.toString().toLowerCase().trim();
                            final isArranged = logisticsStatus == 'arranged';

                            final vehicleType = logistics?['vehicle_type']?.toString() ?? 'Not arranged';
                            final transportCost = hasLogistics
                                ? _formatCurrency(logistics['transport_cost'])
                                : 'Not arranged';
                            final pickupLocation = logistics?['pickup_location']?.toString() ?? lotLocation;
                            final deliveryLocation = logistics?['delivery_location']?.toString() ?? 'Not specified';
                            final pickupDate = _formatDate(logistics?['pickup_date']);

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Section Header for multiple transactions
                                  if (_confirmedTransactions.length > 1)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                      child: Text(
                                        context.trWithArgs('deal_number_header', {'number': '${index + 1}', 'crop': crop, 'qty': quantity}),
                                        style: theme.textTheme.titleSmall?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.onSurfaceVariant,
                                        ),
                                      ),
                                    ),

                                  // Shipment Overview Card
                                  Card(
                                    margin: const EdgeInsets.symmetric(horizontal: 16),
                                    child: Padding(
                                      padding: const EdgeInsets.all(18),
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
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 4,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: isArranged
                                                      ? AppColors.primaryContainer
                                                      : AppColors.tertiaryContainer,
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                                child: Text(
                                                  isArranged ? 'Transport Arranged' : 'Not Arranged',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                    color: isArranged
                                                        ? AppColors.primary
                                                        : AppColors.tertiary,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            context.trWithArgs('qty_quality_summary', {'qty': quantity, 'quality': quality}),
                                            style: theme.textTheme.bodyMedium?.copyWith(
                                              color: AppColors.onSurfaceVariant,
                                            ),
                                          ),
                                          const Divider(height: 24, color: AppColors.outlineVariant),
                                          _LogisticsRow(
                                            icon: Icons.tag_rounded,
                                            label: 'Transaction ID',
                                            value: txId,
                                          ),
                                          const SizedBox(height: 10),
                                          _LogisticsRow(
                                            icon: Icons.person_outline_rounded,
                                            label: 'Buyer ID',
                                            value: buyerId,
                                          ),
                                          const SizedBox(height: 10),
                                          _LogisticsRow(
                                            icon: Icons.local_shipping_outlined,
                                            label: 'Assigned Vehicle',
                                            value: vehicleType,
                                          ),
                                          const SizedBox(height: 10),
                                          _LogisticsRow(
                                            icon: Icons.currency_rupee_rounded,
                                            label: 'Transport Cost',
                                            value: transportCost,
                                          ),
                                          const SizedBox(height: 10),
                                          _LogisticsRow(
                                            icon: Icons.calendar_today_outlined,
                                            label: 'Pickup Date',
                                            value: pickupDate,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 12),

                                  // Route & Distance Card
                                  Card(
                                    margin: const EdgeInsets.symmetric(horizontal: 16),
                                    child: Padding(
                                      padding: const EdgeInsets.all(18),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            context.tr('transit_route'),
                                            style: theme.textTheme.titleMedium?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 14),
                                          _RouteStopRow(
                                            label: 'Pickup Origin',
                                            location: pickupLocation,
                                            icon: Icons.radio_button_checked,
                                            iconColor: AppColors.primary,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(left: 11),
                                            child: Container(
                                              width: 2,
                                              height: 24,
                                              color: AppColors.outlineVariant,
                                            ),
                                          ),
                                          _RouteStopRow(
                                            label: 'Delivery Destination',
                                            location: deliveryLocation,
                                            icon: Icons.location_on,
                                            iconColor: AppColors.tertiary,
                                          ),
                                          const Divider(height: 24, color: AppColors.outlineVariant),
                                          _LogisticsRow(
                                            icon: Icons.straighten_outlined,
                                            label: 'Calculated Distance',
                                            value: context.tr('not_calculated'),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 12),

                                  // Delivery Progress Timeline Card
                                  Card(
                                    margin: const EdgeInsets.symmetric(horizontal: 16),
                                    child: Padding(
                                      padding: const EdgeInsets.all(18),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            context.tr('delivery_progress'),
                                            style: theme.textTheme.titleMedium?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          const _TimelineStep(
                                            stepNumber: '1',
                                            title: 'Deal Confirmed',
                                            subtitle: 'Transaction status is confirmed',
                                            isCompleted: true,
                                            isLast: false,
                                          ),
                                          _TimelineStep(
                                            stepNumber: '2',
                                            title: 'Transport Arranged',
                                            subtitle: isArranged
                                                ? 'Vehicle booked for scheduled pickup'
                                                : 'Pending carrier arrangement',
                                            isCompleted: isArranged,
                                            isLast: false,
                                          ),
                                          const _TimelineStep(
                                            stepNumber: '3',
                                            title: 'Pickup Completed',
                                            subtitle: 'Produce collected and dispatch initiated',
                                            isCompleted: false,
                                            isLast: false,
                                          ),
                                          const _TimelineStep(
                                            stepNumber: '4',
                                            title: 'Delivery Completed',
                                            subtitle: 'Weighment & quality clearance at warehouse',
                                            isCompleted: false,
                                            isLast: true,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 16),

                                  // Action Button
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    child: SizedBox(
                                      width: double.infinity,
                                      height: 48,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => TransportOptionsScreen(
                                                transactionId: txId,
                                              ),
                                            ),
                                          );
                                        },
                                        child: Text(
                                          isArranged ? 'View Transport Options' : 'Arrange Transport',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
        ),
      ),
    );
  }
}

class _LogisticsRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _LogisticsRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.outline),
        const SizedBox(width: 10),
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
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}

class _RouteStopRow extends StatelessWidget {
  final String label;
  final String location;
  final IconData icon;
  final Color iconColor;

  const _RouteStopRow({
    required this.label,
    required this.location,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: iconColor),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                location,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TimelineStep extends StatelessWidget {
  final String stepNumber;
  final String title;
  final String subtitle;
  final bool isCompleted;
  final bool isLast;

  const _TimelineStep({
    required this.stepNumber,
    required this.title,
    required this.subtitle,
    required this.isCompleted,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted ? AppColors.primary : AppColors.outlineVariant,
                ),
                child: Center(
                  child: isCompleted
                      ? const Icon(
                          Icons.check,
                          size: 15,
                          color: AppColors.onPrimary,
                        )
                      : Text(
                          stepNumber,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: isCompleted ? AppColors.primary : AppColors.outlineVariant,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isCompleted ? AppColors.onSurface : AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}