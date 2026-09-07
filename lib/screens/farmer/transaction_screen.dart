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
      final data = await _transactionService.getFarmerTransactions();
      if (!mounted) return;
      setState(() {
        _transactions = data;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Failed to load transactions. Please try again.';
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

  String _formatPricePerQtl(dynamic rawPrice) {
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

  String _capitalizeStatus(String status) {
    if (status.isEmpty) return 'Pending';
    return status[0].toUpperCase() + status.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions & Dispatches'),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchTransactions,
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
                                    'No confirmed transactions yet',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'When you accept buyer offers, confirmed deals will appear here.',
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
                            final lot = tx['lots'] as Map<String, dynamic>?;

                            final txId = tx['id']?.toString() ?? 'N/A';
                            final buyerId = tx['buyer_id']?.toString() ?? 'Unknown';
                            final crop = lot?['crop']?.toString() ?? 'Produce';
                            final quantity = _formatQuantity(tx['quantity']);
                            final agreedPrice = _formatPricePerQtl(tx['agreed_price']);
                            final totalAmount = _formatCurrency(tx['total_amount']);
                            final rawStatus = tx['status']?.toString().toLowerCase().trim() ?? 'confirmed';
                            final isConfirmed = rawStatus == 'confirmed';

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Column(
                                children: [
                                  // Transaction Details Card
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
                                                  'Transaction #$txId',
                                                  style: theme.textTheme.titleMedium?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 4,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: isConfirmed
                                                      ? AppColors.primaryContainer
                                                      : AppColors.tertiaryContainer,
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                                child: Text(
                                                  _capitalizeStatus(rawStatus),
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                    color: isConfirmed
                                                        ? AppColors.primary
                                                        : AppColors.tertiary,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const Divider(height: 24, color: AppColors.outlineVariant),
                                          _DetailRow(
                                            label: 'Buyer',
                                            value: 'Buyer ID: $buyerId',
                                          ),
                                          const SizedBox(height: 8),
                                          _DetailRow(label: 'Crop', value: crop),
                                          const SizedBox(height: 8),
                                          _DetailRow(label: 'Quantity', value: quantity),
                                          const SizedBox(height: 8),
                                          _DetailRow(label: 'Agreed Price', value: agreedPrice),
                                          const SizedBox(height: 8),
                                          _DetailRow(label: 'Total Amount', value: totalAmount),
                                          const SizedBox(height: 8),
                                          const _DetailRow(label: 'Transport Cost', value: 'Not arranged'),
                                          const Padding(
                                            padding: EdgeInsets.symmetric(vertical: 8),
                                            child: Divider(color: AppColors.outlineVariant),
                                          ),
                                          _DetailRow(
                                            label: 'Net Amount',
                                            value: totalAmount,
                                            isBold: true,
                                            valueColor: AppColors.primary,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 12),

                                  // Status Timeline Card
                                  Card(
                                    margin: const EdgeInsets.symmetric(horizontal: 16),
                                    child: Padding(
                                      padding: const EdgeInsets.all(18),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Fulfillment Status',
                                            style: theme.textTheme.titleMedium?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          _TimelineStep(
                                            stepNumber: '1',
                                            title: 'Deal Confirmed',
                                            subtitle: isConfirmed ? 'Offer accepted & confirmed' : 'Awaiting confirmation',
                                            isCompleted: isConfirmed,
                                            isLast: false,
                                          ),
                                          const _TimelineStep(
                                            stepNumber: '2',
                                            title: 'Transport Arranged',
                                            subtitle: 'Vehicle dispatch & logistics pending',
                                            isCompleted: false,
                                            isLast: false,
                                          ),
                                          const _TimelineStep(
                                            stepNumber: '3',
                                            title: 'Delivery Completed',
                                            subtitle: 'Quality inspection & weighment at warehouse',
                                            isCompleted: false,
                                            isLast: false,
                                          ),
                                          const _TimelineStep(
                                            stepNumber: '4',
                                            title: 'Payment Processing',
                                            subtitle: 'Direct bank transfer initiation',
                                            isCompleted: false,
                                            isLast: false,
                                          ),
                                          const _TimelineStep(
                                            stepNumber: '5',
                                            title: 'Payment Received',
                                            subtitle: 'Direct settlement into registered account',
                                            isCompleted: false,
                                            isLast: true,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 16),

                                  // Open Logistics & Fulfillment Button
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
                                              builder: (context) => const LogisticsScreen(),
                                            ),
                                          );
                                        },
                                        child: const Text(
                                          'Open Logistics & Fulfillment',
                                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 12),

                                  // View Payment Details Button
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
                                              builder: (context) => const PaymentDetailsScreen(),
                                            ),
                                          );
                                        },
                                        child: const Text(
                                          'View Payment Details',
                                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final Color? valueColor;

  const _DetailRow({
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
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted ? AppColors.primary : AppColors.outlineVariant,
                ),
                child: Center(
                  child: isCompleted
                      ? const Icon(
                          Icons.check,
                          size: 16,
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
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
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