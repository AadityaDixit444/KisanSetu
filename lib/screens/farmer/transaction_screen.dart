import 'package:flutter/material.dart';
import '../../services/transaction_service.dart';
import '../../theme/app_colors.dart';
import 'logistics_screen.dart';
import 'payment_details_screen.dart';

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({super.key});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  final TransactionService _transactionService = TransactionService();

  bool _isLoading = true;
  String? _errorMessage;
  List<Map<String, dynamic>> _transactions = [];
  final Set<String> _updatingTxIds = {};

  @override
  void initState() {
    super.initState();
    _fetchTransactions();
  }

  Future<void> _fetchTransactions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await _transactionService.getFarmerTransactions();
      if (!mounted) return;
      setState(() {
        _transactions = results;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Failed to load transactions: $e';
        _isLoading = false;
      });
    }
  }

  double _parseDouble(dynamic val) {
    if (val == null) return 0.0;
    if (val is num) return val.toDouble();
    return double.tryParse(val.toString().replaceAll(RegExp(r'[^0-9.-]'), '')) ?? 0.0;
  }

  String _formatPrice(dynamic rawPrice) {
    final val = _parseDouble(rawPrice);
    if (val % 1 == 0) {
      return '₹${val.toInt().toString().replaceAllMapped(RegExp(r'(\d+?)(?=(\d\d)+(\d)(?!\d))(\.\d+)?'), (m) => '${m[1]},')}/qtl';
    }
    return '₹${val.toStringAsFixed(2)}/qtl';
  }

  String _formatCurrency(dynamic rawAmount) {
    final val = _parseDouble(rawAmount);
    return '₹${val.toInt().toString().replaceAllMapped(RegExp(r'(\d+?)(?=(\d\d)+(\d)(?!\d))(\.\d+)?'), (m) => '${m[1]},')}';
  }

  String _formatQuantity(dynamic rawQty) {
    final val = _parseDouble(rawQty);
    return val % 1 == 0 ? '${val.toInt()} qtl' : '$val qtl';
  }

  int _getTimelineStep(String status) {
    final s = status.toLowerCase().trim();
    if (s == 'completed' || s == 'delivered') {
      return 4;
    }
    if (s == 'in_transit' || s == 'dispatched') {
      return 3;
    }
    if (s == 'pickup_scheduled') {
      return 2;
    }
    if (s == 'ready_for_dispatch' || s == 'confirmed' || s == 'escrow_pending' || s == 'escrow_funded' || s == 'paid') {
      return 1;
    }
    return 0;
  }

  String? _getNextDispatchStatus(String currentStatus) {
    switch (currentStatus.toLowerCase().trim()) {
      case 'ready_for_dispatch':
      case 'confirmed':
        return 'pickup_scheduled';
      case 'pickup_scheduled':
        return 'in_transit';
      case 'in_transit':
      case 'dispatched':
        return 'delivered';
      default:
        return null;
    }
  }

  String _getActionLabel(String nextStatus) {
    switch (nextStatus) {
      case 'pickup_scheduled':
        return 'Schedule Pickup';
      case 'in_transit':
        return 'Mark In Transit';
      case 'delivered':
        return 'Confirm Delivery';
      default:
        return 'Update Status';
    }
  }

  Future<void> _handleUpdateDispatchStatus(String txId, String nextStatus) async {
    if (_updatingTxIds.contains(txId)) return;

    setState(() {
      _updatingTxIds.add(txId);
    });

    try {
      await _transactionService.updateDispatchStatus(
        transactionId: txId,
        newStatus: nextStatus,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Dispatch status updated to ${nextStatus.replaceAll('_', ' ')}'),
          backgroundColor: AppColors.primary,
        ),
      );

      await _fetchTransactions();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update status: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _updatingTxIds.remove(txId);
        });
      }
    }
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
        title: const Text('Transactions & Dispatches'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
            onPressed: _fetchTransactions,
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchTransactions,
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
                  ? ListView(
                      padding: const EdgeInsets.all(24),
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
                                onPressed: _fetchTransactions,
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : _transactions.isEmpty
                      ? ListView(
                          padding: const EdgeInsets.all(24),
                          children: [
                            Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const SizedBox(height: 48),
                                  const Icon(
                                    Icons.receipt_long_outlined,
                                    size: 64,
                                    color: AppColors.outline,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No Transactions Found',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'When buyer offers are accepted, deal contracts, escrow status, and dispatches will appear here.',
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
                          itemCount: _transactions.length,
                          itemBuilder: (context, index) {
                            final tx = _transactions[index];
                            final lotData = tx['lots'] as Map<String, dynamic>? ?? {};

                            final txId = tx['id']?.toString() ?? '';
                            final crop = tx['crop']?.toString() ?? lotData['crop']?.toString() ?? 'Produce';
                            final quantity = _formatQuantity(tx['quantity']);
                            final agreedPrice = _formatPrice(tx['agreed_price']);
                            final totalAmount = _formatCurrency(tx['total_amount']);

                            final dispatchStatus = tx['dispatch_status']?.toString() ??
                                tx['status']?.toString() ??
                                'ready_for_dispatch';
                            final statusDisplay = dispatchStatus.replaceAll('_', ' ').toUpperCase();

                            final location = lotData['location']?.toString() ?? 'Not specified';
                            final quality = lotData['quality']?.toString() ?? 'Standard';

                            final currentStep = _getTimelineStep(dispatchStatus);
                            final nextStatus = _getNextDispatchStatus(dispatchStatus);
                            final isUpdating = _updatingTxIds.contains(txId);

                            return Card(
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: Padding(
                                padding: const EdgeInsets.all(18),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          crop,
                                          style: theme.textTheme.titleLarge?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: AppColors.primaryContainer,
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            statusDisplay,
                                            style: const TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.primary,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'ID: $txId',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: AppColors.outline,
                                        fontFamily: 'monospace',
                                      ),
                                    ),
                                    const Divider(height: 24, color: AppColors.outlineVariant),
                                    _DetailItem(label: 'Agreed Price', value: agreedPrice),
                                    const SizedBox(height: 8),
                                    _DetailItem(label: 'Quantity', value: quantity),
                                    const SizedBox(height: 8),
                                    _DetailItem(label: 'Quality Grade', value: quality),
                                    const SizedBox(height: 8),
                                    _DetailItem(label: 'Depot Location', value: location),
                                    const SizedBox(height: 8),
                                    _DetailItem(
                                      label: 'Total Amount',
                                      value: totalAmount,
                                      isBold: true,
                                      valueColor: AppColors.primary,
                                    ),
                                    const SizedBox(height: 20),
                                    Text(
                                      'Fulfillment Timeline',
                                      style: theme.textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    _FulfillmentTimeline(currentStep: currentStep),
                                    if (nextStatus != null) ...[
                                      const SizedBox(height: 18),
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton.icon(
                                          onPressed: isUpdating
                                              ? null
                                              : () => _handleUpdateDispatchStatus(txId, nextStatus),
                                          icon: isUpdating
                                              ? const SizedBox(
                                                  width: 16,
                                                  height: 16,
                                                  child: CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    color: AppColors.onPrimary,
                                                  ),
                                                )
                                              : const Icon(Icons.arrow_forward_rounded, size: 18),
                                          label: Text(_getActionLabel(nextStatus)),
                                        ),
                                      ),
                                    ],
                                    const SizedBox(height: 14),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: OutlinedButton(
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => const PaymentDetailsScreen(),
                                                ),
                                              );
                                            },
                                            child: const Text('Escrow Details'),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: ElevatedButton(
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => const LogisticsScreen(),
                                                ),
                                              );
                                            },
                                            child: const Text('Logistics'),
                                          ),
                                        ),
                                      ],
                                    ),
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

class _DetailItem extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final Color? valueColor;

  const _DetailItem({
    required this.label,
    required this.value,
    this.isBold = false,
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
            fontSize: isBold ? 15 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: valueColor ?? AppColors.onSurface,
          ),
        ),
      ],
    );
  }
}

class _FulfillmentTimeline extends StatelessWidget {
  final int currentStep;

  const _FulfillmentTimeline({required this.currentStep});

  final List<String> _steps = const [
    'Deal Agreed',
    'Ready for Dispatch',
    'Pickup Scheduled',
    'In Transit',
    'Delivered & Paid',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(_steps.length, (index) {
        final isCompleted = index <= currentStep;
        final isLast = index == _steps.length - 1;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompleted ? AppColors.primary : AppColors.surfaceVariant,
                    border: Border.all(
                      color: isCompleted ? AppColors.primary : AppColors.outline,
                      width: 2,
                    ),
                  ),
                  child: isCompleted
                      ? const Icon(
                          Icons.check,
                          size: 12,
                          color: AppColors.onPrimary,
                        )
                      : null,
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 24,
                    color: index < currentStep ? AppColors.primary : AppColors.outlineVariant,
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  _steps[index],
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isCompleted ? FontWeight.w600 : FontWeight.normal,
                    color: isCompleted ? AppColors.onSurface : AppColors.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}